---
title: PWC187 - Days Together
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-10-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#187][]. Enjoy!

# The challenge

> Two friends, `Foo` and `Bar` gone on holidays seperately to the same
> city. You are given their schedule i.e. `start date` and `end date`.
>
> To keep the task simple, the date is in the form `DD-MM` and all dates
> belong to the same calendar year i.e. between `01-01` and `31-12`.
> Also the year is `non-leap year` and both dates are inclusive.
>
> Write a script to find out for the given schedule, how many days they
> spent together in the city, if at all.
>
> **Example 1**
>
>     Input: Foo => SD: '12-01' ED: '20-01'
>            Bar => SD: '15-01' ED: '18-01'
>
>     Output: 4 days
>
> **Example 2**
>
>     Input: Foo => SD: '02-03' ED: '12-03'
>            Bar => SD: '13-03' ED: '14-03'
>
>     Output: 0 day
>
> **Example 3**
>
>     Input: Foo => SD: '02-03' ED: '12-03'
>            Bar => SD: '11-03' ED: '15-03'
>
>     Output: 2 days
>
> **Example 4**
>
>     Input: Foo => SD: '30-03' ED: '05-04'
>            Bar => SD: '28-03' ED: '02-04'
>
>     Output: 4 days

# The questions

Well... no questions asked. Really. Nice job!

# The solution

The algorithm will be the following:

- first we turn each date into a day number within the year, as an
  integer counting the number of days since the last day of the previous
  year (i.e. January 1st is day number 1);
- then we find out when the overlapping slot should start and end
- then we calculate the width of the interval.

To turn each date into a day index we can just... count. Each month has
its own number of days, but the constraints are clear so we can assign
an exact number of days to each month, and we can thus easily calculate
the index up to the start of any month and then just add the day number.

The start of the overlapping interval, if any, will be the *maximum*
between the two lower ends of the input intervals. The end will be the
*minimum* of the upper ends.

The length... will be their difference, plus one day because both dates
are inclusive by the rules. If the number ends up with being less than
zero, we just assume zero because there's no overlapping. This is the
same as taking the *maximum* between 0 and the difference plus one.

So... after much talking, let's move on to [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($foo = '12-01 20-01', $bar = '15-01 18-01') {
   my @foo = $foo.split(/\s+/);
   my @bar = $bar.split(/\s+/);
   put days-together(@foo, @bar);
}

sub days-together (@foo, @bar) {
   my $start = (@foo[0], @bar[0]).map({date-to-index($_)}).max;
   my $stop  = (@foo[1], @bar[1]).map({date-to-index($_)}).min;
   return (0, $stop - $start + 1).max;
}

sub date-to-index ($date) {
   state @days-upto = days-upto();
   my ($d, $m) = $date.split(/\-/).map: * + 0;
   return @days-upto[$m - 1] + $d;
}

sub days-upto {
   my $sum = 0;
   <0 31 28 31 30 31 30 31 31 30 31 30 31>.map: $sum += *;
}
```

And [Perl][] is much like the same:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util qw< min max >;

my $foo = [ split m{\s+}mxs, shift // '12-01 20-01' ];
my $bar = [ split m{\s+}mxs, shift // '15-01 18-01' ];
say days_together($foo, $bar);

sub days_together ($foo, $bar) {
   my $start = max(map { date_to_index($_->[0]) } ($foo, $bar));
   my $stop  = min(map { date_to_index($_->[1]) } ($foo, $bar));
   return max(0, $stop - $start + 1);
}

sub date_to_index ($date) {
   state $days_upto = [ days_upto() ];
   my ($d, $m) = map { $_ + 0 } split m{-}mxs, $date;
   return $days_upto->[$m - 1] + $d;
}

sub days_upto {
   my $sum = 0;
   map { $sum += $_ } qw< 0 31 28 31 30 31 30 31 31 30 31 30 31 >;
}
```

Stay safe everybody!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#187]: https://theweeklychallenge.org/blog/perl-weekly-challenge-187/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-187/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
