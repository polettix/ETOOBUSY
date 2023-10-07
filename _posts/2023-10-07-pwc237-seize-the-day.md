---
title: PWC237 - Seize The Day
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-07 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#237][]. Enjoy!

# The challenge

> Given a year, a month, a weekday of month, and a day of week (1 (Mon)
> .. 7 (Sun)), print the day.
>
> **Example 1**
>
>     Input: Year = 2024, Month = 4, Weekday of month = 3, day of week = 2
>     Output: 16
>
>     The 3rd Tue of Apr 2024 is the 16th
>
> **Example 2**
>
>     Input: Year = 2025, Month = 10, Weekday of month = 2, day of week = 4
>     Output: 9
>
>     The 2nd Thu of Oct 2025 is the 9th
>
> **Example 3**
>
>     Input: Year = 2026, Month = 8, Weekday of month = 5, day of week = 3
>     Output: 0
>
>     There isn't a 5th Wed in Aug 2026


# The questions

I have to admit that I had a hard time understanding what *a weekday of
month* means, so I hope I got it right from the examples (i.e. that $n$
means *the $n$-th such day in the specific month*).

Another thing that is not clear is what to return if such a day does not
exist, except that there's an explicit example about it so I get that
printing `0` is fine.

I would also like to know if there are limits that can be assumed on the
dates range, just to avoid pitfalls like when different countries
switched to the Gregorian calendar.

Speaking of which, I assume we're actually talking about the Gregorian
calendar or anything people living in the so-called "west" are used to.

# The solution

We will start with [Raku][], which provides an excellent [Date][] class
out of the box that allows doing intuitive arithmetics with integers
representing days. I'll leave the algorithm to the comments:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int $year, Int $month, Int $weekday_in_month, Int $weekday) {
   my $date = Date.new(year => $year, month => $month, day => 1);

   # how much should we advance to find the first occurrence of the
   # target $weekday?
   my $delta = ($weekday + 7 - $date.day-of-week) % 7;

   # advance that much to land on the first, then additional weeks to
   # land on the target $weekday_in_month
   $date += $delta + ($weekday_in_month - 1) * 7;

   # print the result making sure it's still in the same year & month
   put($date.year == $year && $date.month == $month ?? $date.day !! 0);
}
```

It's still easy to translate this into [Perl][], although we have to
play at a lower level of abstraction if we want to stick with stuff in
CORE (there are excellent libraries but they come with a toll).

So here our dates will be represented by the *epoch* of its mid-day in
Greenwich Mean Time, and all transformations will take into account that
a day has exactly $24 * 3600$ seconds. We are not worried by leap
seconds here, though, because we're anyway focusing on mid-day and we're
not using anything below the day granularity anyway.

Again, I'll leave it to the comments to explain the gory details:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use Time::Local 'timegm_modern';

say seize_the_day(@ARGV);

sub seize_the_day ($year, $month, $weekday_in_month, $weekday) {
   my $date = timegm_modern(0, 0, 12, 1, $month - 1, $year);
   my $date_day_of_week = (gmtime($date))[6];

   # how many days should we advance to find the first occurrence of the
   # target $weekday?
   my $delta = ($weekday + 7 - $date_day_of_week) % 7;

   # advance that many days to land on the first, then additional weeks
   # to land on the target $weekday_in_month.
   $date += ($delta + ($weekday_in_month - 1) * 7) * 24 * 3600;

   # get back the year and month of the date we landed on
   my (undef, undef, undef, $day, $newm, $newy) = gmtime($date);
   $newm += 1; # apply offset for month
   $newy += 1900; # apply offset for year

   # return making sure we're in the same year & month
   return $year == $newy && $month == $newm ? $day : 0;
}
```

This said... stay safe and have a good time!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#237]: https://theweeklychallenge.org/blog/perl-weekly-challenge-237/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-237/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Date]: https://docs.raku.org/type/Date
