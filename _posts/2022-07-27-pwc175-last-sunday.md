---
title: PWC175 - Last Sunday
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#175][]. Enjoy!

# The challenge

> Write a script to list `Last Sunday` of every month in the given year.
>
> For example, for year 2022, we should get the following:
>
>     2022-01-30
>     2022-02-27
>     2022-03-27
>     2022-04-24
>     2022-05-29
>     2022-06-26
>     2022-07-31
>     2022-08-28
>     2022-09-25
>     2022-10-30
>     2022-11-27
>     2022-12-25

# The questions

I always get shivers when I see a challenge involving dates (or times)
with such a broad span. *In the given year* screams for a question about
which limits should (or *could*) be assumed.

In the same vein, I'd also ask *where* should we anchor the answer to.

I'm no expert about dates and times, but Socratically I know that I
*don't know* enough and I'll probably never will. I got alive through a
single read of [UTC is enough for everyone ...right?][zhtalk] and that
convinced me to avoid date and time stuff (at least with a broad span)
as much as possible.

Hence, I'll assume that whatever applies to Roma (Italy) since the
seventies should be correct, everything else is nice to have. Anyway...
these are test challenges, not production stuff right?!?

# The solution

As usual, we'll start with [Raku][], which supports [Date][] handling
natively. I'll blindly assume that it's fine for the constraints I've
set in the questions!

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $year = 2022) { .put for sundays-in($year) }

sub sundays-in (Int:D $year) {
   my $year-start = Date.new(:$year);

   # find the first sunday in the year
   my $cursor = $year-start;
   $cursor++ while $cursor.day-of-week % 7;

   # find all last sundays in the year
   return gather loop {

      # we will compare a candidate sunday against the next one
      my $candidate = $cursor;
      $cursor += 7;

      # a jump in the month for the "next" sunday means that our
      # $candidate was the last one in its month, so take it
      take $candidate if $cursor.month != $candidate.month;

      # a jump in the year means we've taken the last one in the
      # requested year, so we can just say goodbye
      last if $cursor.year > $candidate.year;
   };
}
```

The approach is the following:

- find the *first* Sunday in the target year, this will be our starting
  point (initializing variable `$cursor`);
- loop to do the same:
    - advance the cursor ahead one week (assuming that 7 days are one
      week);
    - compare whether this advanced date stepped onto the next month
      with respect to the starting value
    - if advanced, the previous value is a *Last Sunday* and gets
      `take`n
    - stop when the year of the new value is the next one (we have it
      January of the next year).

I still cross my finger thinking of applying this to *any year*.

In [Perl][], we can leverage the venerable [DateTime][] but otherwise
more or less translate the solution from [Raku][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use DateTime;

my $year = shift // 2022;
say for sundays_in($year);

sub sundays_in ($year) {
   my $year_start = DateTime->new(
      year => $year,
      month => 1,
      day  => 1,
      hour => 12,
      time_zone => 'floating',
   );

   # find the first sunday in the year
   my $cursor = $year_start->clone;
   $cursor->add(days => 1) while $cursor->day_of_week % 7;

   # find all last sundays in the year
   my @retval;
   while ($cursor->year == $year) {

      # we will compare a candidate sunday against the next one
      my $candidate = $cursor->clone;
      $cursor->add(days => 7);

      # a jump in the month for the "next" sunday means that our
      # $candidate was the last one in its month, so take it
      push @retval, $candidate->ymd('-')
         if $cursor->month != $candidate->month;
   }
   return @retval;
}
```

I know I said something about being valid for Roma (Italy), but this is
only because I know that nothing specific has happened since the
seventies in the last century. To be on the safe side (e.g. for leap
stuff) I'm setting in the middle of the day at 12 o'clock.

So there we have, all the *Last Sunday*s in a year, in a hopefully
working solution!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#175]: https://theweeklychallenge.org/blog/perl-weekly-challenge-175/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-175/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[zhtalk]: https://zachholman.com/talk/utc-is-enough-for-everyone-right
[Date]: https://docs.raku.org/type/Date
[DateTime]: https://metacpan.org/pod/DateTime
