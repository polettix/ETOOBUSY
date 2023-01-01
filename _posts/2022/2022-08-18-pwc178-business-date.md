---
title: PWC178 - Business Date
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-18 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#178][].
> Enjoy!

# The challenge

> You are given `$timestamp` (date with time) and `$duration` in hours.
>
> Write a script to find the time that occurs `$duration` business hours
> after `$timestamp`. For the sake of this task, let us assume the
> working hours is 9am to 6pm, Monday to Friday. Please ignore timezone
> too.
>
> For example,
>
>     Suppose the given timestamp is 2022-08-01 10:30 and the duration is 4 hours.
>     Then the next business date would be 2022-08-01 14:30.
>
>     Similar if the given timestamp is 2022-08-01 17:00 and the duration is 3.5 hours.
>     Then the next business date would be 2022-08-02 11:30.

# The questions

Assumptions, more than questions:

- it's OK to consider dates after 1980 (just to be on the safe side) but
  before 2036 (again, just to be on the safe side)
- holidays are anyway considered business days - like August 15th is
  normally holiday in Italy, but whatever in 2020 it's Monday so it's a
  business day.

What to do if the input date is valid, but not a business date itself?
I'll assume that we shift to the beginning of the next business day and
start our calculations from there.

# The solution

As in everything dates and time, it's a lot of calculation with that
residual tickling sensation that something might have gone wrong. For
this reason, I usually take very little steps, making sure to avoid leap
second stuff etc.

In [Perl][], this means using `gmtime` and `timegm` (from
[Time::Local][]) to do the heavylifting, making sure to add at most one
day and using hours in the middle of the day to do this. Cross fingers!

So, without further ado:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Time::Local 'timegm';

my $ts       = shift // '2022-08-01 10:30';
my $duration = shift // 4;
say add_bh($ts, $duration);

sub parse_datetime ($dt) {
   my $error = "invalid input timestamp <$dt>\n";
   my ($y, $m, $d, $H, $M) = $dt =~ m{
      \A (\d+) - (\d\d) - (\d\d) \  (\d\d):(\d\d) \z
   }mxs or die $error;
   die $error unless eval {
      timegm(0, $M, $H, $d, $m - 1, $y);
      1;
   };
   return [ $y, $m, $d, $H, $M ];
}

sub add_bh ($timestamp, $duration) {
   state $sod_min =  9 * 60;
   state $eod_min = 18 * 60;
   my $duration_min = int($duration * 60); # in minutes, rounded down

   my $dt = parse_datetime($timestamp);

   # cope with the possibility that the provided timestamp is
   # *outside* the allowed range, move to the beginning of the
   # next business day
   $dt = next_business_day_start($dt) unless is_in_business($dt);
   my $start_min = $dt->[3] * 60 + $dt->[4];

   while ($duration_min > 0) {
      my $available_min = $eod_min - $start_min;
      if ($duration_min >= $available_min) {
         $dt = next_business_day_start($dt);
         $duration_min -= $available_min;
         $start_min = $sod_min;
      }
      else { # we're in the very day!
         my $stop_min = $start_min + $duration_min;
         $dt->[4] = my $M = $stop_min % 60;
         $dt->[3] = ($stop_min - $M) / 60;
         $duration_min = 0;
      }
   }

   return sprintf '%04d-%02d-%02d %02d:%02d', $dt->@*;
}

sub is_in_business ($dt) {
   my ($y, $m, $d, $H, $M) = $dt->@*;
   return if $H < 9 || $H > 17; # 18:00 is out ;)
   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
     gmtime(timegm(0, $M, $H, $d, $m - 1, $y));
   return (0 < $wday && $wday < 6);
} ## end sub is_in_business ($dt)

sub next_business_day_start ($dt) {
   state $day_s = 24 * 60 * 60;
   my ($y, $m, $d) = $dt->@*;
   while ('necessary') {
      my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
         gmtime($day_s + timegm(0, 30, 12, $d, $m - 1, $y));
      $year += 1900;
      ++$mon;
      return [$year, $mon, $mday, 9, 0]
         if 0 < $wday && $wday < 6;
      ($y, $m, $d) = ($year, $mon, $mday);
   }
}
```

To add the duration, we make sure to do the calculations one day at a
time. This is like doing multiplications by summing in a loop, and I'm
happy with this because there are so many corner cases!

In [Raku][] life is slightly easier thanks to the batteries included of
`DateTime`:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN ($ts = '2022-08-01 10:30', $duration = 4) {
   put add-bh($ts, $duration);
}

sub parse_datetime ($dt) {
   my $error = "invalid input timestamp <$dt>\n";
   my $match = $dt ~~ /
      ^ (\d+) '-' (\d\d) '-' (\d\d) ' ' (\d\d) ':' (\d\d) $
   / or die $error;
   my ($y, $m, $d, $H, $M) = $match[0..4].map({0 + $_});
   try {
      CATCH {
         default { die $error }
      }
      return DateTime.new(year => $y, month => $m, day => $d,
         hour => $H, minute => $M);
   }
}

sub is-in-business ($dt) {
   return (
      (9 <= $dt.hour < 18) # 18:00 is out ;)
      &&  (1 <= $dt.day-of-week <= 5)
   );
} ## end sub is_in_business ($dt)

sub next-business-day-start ($dt is copy) {
   loop {
      $dt = $dt.clone(hour => 9, minute => 0).later(day => 1);
      return $dt if (1 <= $dt.day-of-week <= 5);
   }
}

sub add-bh ($timestamp, $duration) {
   state $sod_min =  9 * 60;
   state $eod_min = 18 * 60;
   my $duration_min = ($duration * 60).Int; # in minutes, rounded down

   my $dt = parse_datetime($timestamp);

   # cope with the possibility that the provided timestamp is
   # *outside* the allowed range, move to the beginning of the
   # next business day
   $dt = next-business-day-start($dt) unless is-in-business($dt);
   my $start_min = $dt.hour * 60 + $dt.minute;

   while $duration_min > 0 {
      my $available_min = $eod_min - $start_min;
      if ($duration_min >= $available_min) {
         $dt = next-business-day-start($dt);
         $duration_min -= $available_min;
         $start_min = $sod_min;
      }
      else { # we're in the very day!
         my $stop_min = $start_min + $duration_min;
         my $M = $stop_min % 60;
         my $H = ($stop_min - $M) / 60;
         $dt = $dt.clone(hour => $H, minute => $M);
         $duration_min = 0;
      }
   }

   return '%04d-%02d-%02d %02d:%02d'.sprintf(
      $dt.year, $dt.month, $dt.day, $dt.hour, $dt.minute);
}
```

Apart from using the `DateTime` class, it's the same solution as
[Perl][].

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#178]: https://theweeklychallenge.org/blog/perl-weekly-challenge-178/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-178/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Time::Local]: https://metacpan.org/pod/Time::Local
