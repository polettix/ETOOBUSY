---
title: PWC183 - Date Difference
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#183][].
> Enjoy!

# The challenge

> You are given two dates, `$date1` and `$date2` in the format
> `YYYY-MM-DD`.
>
> Write a script to find the difference between the given dates in terms
> on `years` and `days` only.
>
> **Example 1**
>
>     Input: $date1 = '2019-02-10'
>            $date2 = '2022-11-01'
>     Output: 3 years 264 days
>
> **Example 2**
>
>     Input: $date1 = '2020-09-15'
>            $date2 = '2022-03-29'
>     Output: 1 year 195 days
>
> **Example 3**
>
>     Input: $date1 = '2019-12-31'
>            $date2 = '2020-01-01'
>     Output: 1 day
>
> **Example 4**
>
>     Input: $date1 = '2019-12-01'
>            $date2 = '2019-12-31'
>     Output: 30 days
>
> **Example 5**
>
>     Input: $date1 = '2019-12-31'
>            $date2 = '2020-12-31'
>     Output: 1 year
>
> **Example 6**
>
>     Input: $date1 = '2019-12-31'
>            $date2 = '2021-12-31'
>     Output: 2 years
>
> **Example 7**
>
>     Input: $date1 = '2020-09-15'
>            $date2 = '2021-09-16'
>     Output: 1 year 1 day
>
> **Example 8**
>
>     Input: $date1 = '2019-09-15'
>            $date2 = '2021-09-16'
>     Output: 2 years 1 day

# The questions

Why on earth are we mixing *years and days* without giving a proper
specification about what we're expecting back?

OK, we're going to assume that the following is correct:

- advance date1 for as many years as the difference in years between the
  two dates
- if the landing date1 does not exist (Feb 29th in a non-leap year) go
  back one day
- if the landing date1 comes after date2, go back one year
- count the number of days

# The solution

I **hate** this kind of date processing stuff, *especially* for such
under-specified situations. If there's anything I learned is that any
serious date business MUST be done with the right library, and this is
definitely something that a library does not help with.

In addition, I generally **hate** having to deal with date fiddling.

Last, I **hate** having to **hate**.

So I'm doing this only for [manwar][], who is a nice person.

For this reason, this is my [Perl][] solution:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Time::Local 'timegm';
use Test::More;

my @tests = qw<

   2019-02-10 2022-11-01 3 264
   2020-09-15 2022-03-29 1 195
   2019-12-31 2020-01-01 0 1
   2019-12-01 2019-12-31 0 30
   2019-12-31 2020-12-31 1 0
   2019-12-31 2021-12-31 2 0
   2020-09-15 2021-09-16 1 1
   2019-09-15 2021-09-16 2 1

   2019-02-28 2020-02-27 0 364
   2019-02-28 2020-02-28 1 0
   2019-02-28 2020-02-29 1 1
   2019-02-28 2020-03-01 1 2
   2019-03-01 2020-02-28 0 364
   2019-03-01 2020-02-29 0 365
   2019-03-01 2020-03-01 1 0

   2020-02-28 2021-02-27 0 365
   2020-02-28 2021-02-28 1 0
   2020-02-28 2021-03-01 1 1
   2020-02-29 2021-02-28 0 365
   2020-02-29 2021-03-01 1 1

>;

while (@tests) {
   my ($date1, $date2, $exp_years, $exp_days) = splice @tests, 0, 4;
   my ($got_years, $got_days) = years_and_days($date1, $date2);
   is $got_years, $exp_years, "($date1 vs $date2) years OK";
   is $got_days, $exp_days, "($date1 vs $date2) days OK";
}

done_testing();

sub years_and_days ($date1, $date2) {
   my %parts_of;
   for my $date ($date1, $date2) {
      complain($date, 'undefined') unless defined $date;
      my @pts = $date =~ m{\A ([1-9]\d{3})-(\d\d)-(\d\d) \z}mxs
         or complain($date, 'no match');
      complain($date, 'too low') unless $pts[0] > 1585;
      $_ += 0 for @pts;
      $parts_of{$date} = {
         year => $pts[0],
         in_year => sprintf('%02d-%02d', $pts[1], $pts[2]),
         month => $pts[1],
         day => $pts[2],
      };
      date_exists($parts_of{$date}) or complain($date, 'inexistent');
      # OK, the date is valid
   }

   complain($date2, 'too early') if $date2 lt $date1;
   ($date1, $date2) = @parts_of{$date1, $date2};

   # first rought evaluation of years between
   my $years = $date2->{year} - $date1->{year};
   my $days = undef;

   # if the "in year" day of the first date comes before the corresponding
   # in the second one, just count the days in between
   if ($date1->{in_year} le $date2->{in_year}) {
      set_year($date1, $date2->{year});
      $days = days_diff($date1, $date2);
   }

   # otherwise we have to "lend a year" and calculated days across the
   # change of the year by setting the first date in the previous year
   else {
      --$years;
      set_year($date1, $date2->{year} - 1);
      $days = days_diff($date1, $date2);
   }

   return ($years, $days);
}

sub epc ($d) { timegm(30, 30, 12, $d->{day}, $d->{month} - 1, $d->{year}) }
sub date_exists ($date) { eval { epc($date); 1 } }

sub set_year ($date, $year) {
   $date->{year} = $year;

   # We might land a valid starting Feb 29th onto an invalid Feb 29th so we
   # might have to adjust
   $date->@{qw< day in_year >} = (28, '02-28') unless date_exists($date);

   return $date;
}

sub days_diff ($date1, $date2) {
   my $epoch1 = epc($date1);
   my $epoch2 = epc($date2);
   return int(($epoch2 + 3600 - $epoch1) / (24 * 3600));
}

sub complain ($date, $reason) {
   die "invalid date: $reason\n" unless defined $date;
   die "invalid date '$date': $reason\n";
}
```

No [Raku][] this time, because I don't want to lose the `-Ofun`!

Stay safe and... *relaxed*!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#183]: https://theweeklychallenge.org/blog/perl-weekly-challenge-183/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-183/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
