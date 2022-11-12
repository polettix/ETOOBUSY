---
title: PWC128 - Minimum Platforms
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-02 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#128][].
> Enjoy!

# The challenge

> You are given two arrays of arrival and departure times of trains at a
> railway station.
>
> Write a script to find out the minimum number of platforms needed so
> that no train needs to wait.
>
> **Example 1:**
>
>     Input: @arrivals   = (11:20, 14:30)
>            @departutes = (11:50, 15:00)
>     Output: 1
>     
>         The 1st arrival of train is at 11:20 and this is the only train at the
>         station, so you need 1 platform.
>         Before the second arrival at 14:30, the first train left the station at
>         11:50, so you still need only 1 platform.
>
> **Example 2:**
>
>     Input: @arrivals   = (10:20, 11:00, 11:10, 12:20, 16:20, 19:00)
>            @departutes = (10:30, 13:20, 12:40, 12:50, 20:20, 21:20)
>     Output: 3
>     
>         Between 11:00 and 12:20, there would be at least 3 trains at the station,
>         so we need minimum 3 platforms.

# The questions

There are a few questions about the challenge:

- are we talking about what happens during one day that is eventually
  repeated in the following days?
    - We will assume that yes, the description is what happens each day
- Should we assume that the arrivals and departures are sorted?
    - We will assume that they are not and do the sorting ourselves
- Should we assume that arrivals happen before departures in any given
  day? In other terms, are trains allowed to pass midnight in the
  station?
    - We will assume that trains might arrive before midnight and leave
      after midnight.
- What is the guard time after a departure to consider a platform free
  for a new arrival?
    - We will assume that there is an environment variable telling us
      how many minutes we should wait after a departure to consider the
      platform as *free*.

# The solution

We will keep a counter of how many *virtual trains* are in the station
at any given moment.

Why *virtual* instead of... *real*? Well, this is just a trick related
to when we start counting, as we will see shortly.

Each time is transformed into the corresponding *number of minutes since
last midnight*, so that we can easily use integer arithmetics. Thus, we
transform the input arrays and also sort each of them according to this
number, in ascending order:

```raku
sub minimum-platforms (@arrivals, @departures) {
   sub pre-massage (@input) {
      @input.map(
         {
            my ($h, $m) = .split: /\:/;
            $h * 60 + $m;
         }
      ).sort;
   }
   my @sorted-arrivals = pre-massage(@arrivals);
   my @sorted-departures = pre-massage(@departures);
```

Next, we will need to compare the arrival times with the departure
times, and act accordingly. In particular, arrival events will increase
our need for platforms, and departures will decrease it.

Or is it? Well, as my Railways Engineers will surely object, it's not
that simple. A train arriving one minute immediately after a departure
*cannot* reuse the same platform, for security reasons (what if the
departing train is a little late? What if the arriving train is ahead of
the schedule?). Hence, we have to account for some `freeup-window` that
takes this into account:

```raku
constant \freeup-window = +(%*ENV<FREEUP_WINDOW> // 10);
```

To compare the two arrays means comparing their *first* values, removing
either of them as we go. What if we are out of elements from one of the
two arrays? In this case we will consider a *fake* time `beyond-last`,
which we are sure to happen beyond any possible last valid event time.
To do this, we consider someting at the 30th hour in the day... plus
some:

```raku
constant \beyond-last = 30 * 60 + freeup-window;
```

We are ready to start our quest into the two arrays then:

```raku
while (@sorted-arrivals || @sorted-departures) {
   my $arrival = @sorted-arrivals ?? @sorted-arrivals[0] !! beyond-last;
   my $departure = @sorted-departures ?? @sorted-departures[0] !! beyond-last;
```

As anticipated, these two candidates are compared to see which one acts
first. From what we discussed, any arrival happening before the first
departure time *plus* the `freeup-window` is assumed to *happen first*,
at least from the point of view of calculating our needs for platforms:

```raku
if $arrival <= $departure + freeup-window {
   ++$present;
   $max = $present if $present > $max;
   @sorted-arrivals.shift;
}
else {
   --$present;
   $min = $present if $present < $min;
   @sorted-departures.shift;
}
```

As we can see, we're using a few variables, which are initialized as
follows:

```raku
my ($present, $min, $max) = (0, 0, 0);
```

They track the following quantities:

- `$present` tracks the number of *virtual* trains that are present at a
  given time. We start from `0`, but this is arbitrary: we don't
  actually know how many trains we have from the previous day. For this
  reason, we might have that the first event is a departure, which
  *decreases* the number of trains (setting `$present` to a negative
  value), which makes for the trains to be *virtual*;
- `$min` is the minimum value that `$present` can have. Its absolute
  value tracks the number of trains that carry over from one day to the
  next one;
- `$max` is the maximum value that `$present` can have.

The value we are after is the difference `$max - $min`. In other terms,
if we initialize `$present` to the absolute value of `$min`, at the end
of the analysis we end up with `$min = 0` and `$max` holding the
maximum value of trains that are `$present` at the same time in the
station.

Here's the whole program:

```raku
#!/usr/bin/env raku
use v6;

constant \freeup-window = +(%*ENV<FREEUP_WINDOW> // 10);

sub minimum-platforms (@arrivals, @departures) {
   sub pre-massage (@input) {
      @input.map(
         {
            my ($h, $m) = .split: /\:/;
            $h * 60 + $m;
         }
      ).sort;
   }
   my @sorted-arrivals = pre-massage(@arrivals);
   my @sorted-departures = pre-massage(@departures);

   constant \beyond-last = 30 * 60 + freeup-window; # 30th hour in the day... :)
   my ($present, $min, $max) = (0, 0, 0);
   while (@sorted-arrivals || @sorted-departures) {
      my $arrival = @sorted-arrivals ?? @sorted-arrivals[0] !! beyond-last;
      my $departure = @sorted-departures ?? @sorted-departures[0] !! beyond-last;
      if $arrival <= $departure + freeup-window {
         ++$present;
         $max = $present if $present > $max;
         @sorted-arrivals.shift;
      }
      else {
         --$present;
         $min = $present if $present < $min;
         @sorted-departures.shift;
      }
   }
   return $max - $min;
}

sub MAIN ($arrivals = '10:20 11:00 11:10 12:20 16:20 19:00 22:00 22:10 22:20 22:30',
          $departures = '08:00 08:30 10:15 10:30 10:50 13:20 12:40 12:50 20:20 22:25') {
   put minimum-platforms($arrivals.split(/\s+/), $departures.split(/\s+/));
}
```

There might be many other additional ways to cope with this, instead of
*virtual trains*:

- from a purely naming perspective, instead of `$present` we might just
  rename the variable as `$variation-since-midnight`, marking how this
  is actually something that can go negative as well as positive;
- otherwise, we might make sure that `$present` never goes negative, and
  increase `$max` every time `$present` is at `0` and we need to
  decrease it.

These are equivalent to our approach though... so we adopt the *virtual*
approach because it's funny!

The [Perl][] translation is straightforward, with the due modifications
on how containers are used/accessed, the ternary operator etc. Here is
the translation of the whole program:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use constant freeup_window => $ENV{FREEUP_WINDOW} // 10;

sub minimum_platforms ($arrivals, $departures) {
   my $pre_massage = sub (@input) {
      sort { $a <=> $b } map {
         my ($h, $m) = split m{:}mxs;
         $h * 60 + $m;
      } @input;
   };
   my @sorted_arrivals = $pre_massage->($arrivals->@*);
   my @sorted_departures = $pre_massage->($departures->@*);
   my $beyond_last = 30 * 60 + freeup_window;
   my ($present, $min, $max) = (0, 0, 0);
   while (@sorted_arrivals || @sorted_departures) {
      my $arrival = @sorted_arrivals ? $sorted_arrivals[0] : $beyond_last;
      my $departure = @sorted_departures ? $sorted_departures[0] : $beyond_last;
      if ($arrival <= $departure + freeup_window) {
         ++$present;
         $max = $present if $present > $max;
         shift @sorted_arrivals;
      }
      else {
         --$present;
         $min = $present if $present < $min;
         shift @sorted_departures;
      }
   }
   return $max - $min;
}

my $arrivals = shift(@ARGV)
   // '10:20 11:00 11:10 12:20 16:20 19:00 22:00 22:10 22:20 22:30';
my $departures = shift(@ARGV)
   // '08:00 08:30 10:15 10:30 10:50 13:20 12:40 12:50 20:20 22:25';
say minimum_platforms([split m{\s+}mxs, $arrivals], [split m{\s+}mxs, $departures]);
```

With this... goodbye everybody, and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#128]: https://theweeklychallenge.org/blog/perl-weekly-challenge-128/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-128/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
