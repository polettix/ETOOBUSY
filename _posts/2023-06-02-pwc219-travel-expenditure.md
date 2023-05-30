---
title: PWC219 - Travel Expenditure
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-02 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#219][].
> Enjoy!

# The challenge

> You are given two list, @costs and @days.
>
> The list @costs contains the cost of three different types of travel cards
> you can buy.
>
> For example @costs = (5, 30, 90)
>
>     Index 0 element represent the cost of  1 day  travel card.
>     Index 1 element represent the cost of  7 days travel card.
>     Index 2 element represent the cost of 30 days travel card.
>
> The list @days contains the day number you want to travel in the year.
>
> For example: @days = (1, 3, 4, 5, 6)
>
>     The above example means you want to travel on day 1, day 3, day 4, day 5 and day 6 of the year.
>
> Write a script to find the minimum travel cost.
>
> **Example 1:**
>
>     Input: @costs = (2, 7, 25)
>            @days  = (1, 5, 6, 7, 9, 15)
>     Output: 11
>
>     On day 1, we buy a one day pass for 2 which would cover the day 1.
>     On day 5, we buy seven days pass for 7 which would cover days 5 - 9.
>     On day 15, we buy a one day pass for 2 which would cover the day 15.
>
>     So the total cost is 2 + 7 + 2 => 11.
>
> **Example 2:**
>
>     Input: @costs = (2, 7, 25)
>            @days  = (1, 2, 3, 5, 7, 10, 11, 12, 14, 20, 30, 31)
>     Output: 20
>
>     On day 1, we buy a seven days pass for 7 which would cover days 1 - 7.
>     On day 10, we buy a seven days pass for 7 which would cover days 10 - 14.
>     On day 20, we buy a one day pass for 2 which would cover day 20.
>     On day 30, we buy a one day pass for 2 which would cover day 30.
>     On day 31, we buy a one day pass for 2 which would cover day 31.
>
>     So the total cost is 7 + 7 + 2 + 2 + 2 => 20.

# The questions

One question might be how many days we might consider maximum. There's a
reference to *... in the year*, so I guess it can go from 1 to 366 maximum.

# The solution

A basic brute force makes it for the examples:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my @days = @ARGV;
my @costs = splice @days, 0, 3;
say travel_expenditure(\@costs, @days);

sub travel_expenditure ($costs, @days) {
   state $spans = [1, 7, 30];
   return 0 unless @days;
   my $min;
   for my $i (0 .. 2) {
      my ($first, @pool) = @days;
      shift @pool while @pool && $pool[0] < $first + $spans->[$i];
      my $cost = $costs->[$i] + __SUB__->($costs, @pool);
      $min = $cost if (! defined($min)) || ($cost < $min);
   }
   return $min;
}
```

I like it because I get to use the mythical `__SUB__`. Anyway, this solution
takes a bit too long (well, I don't know how much, actually) when dealing
with the full 366 days, although [Memoize][] can come to the rescue and save
the day in a few milliseconds.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use Memoize;
no warnings 'recursion';

my @days = @ARGV;
my @costs = splice @days, 0, 3;
memoize('travel_expenditure');
say travel_expenditure(\@costs, @days);

sub travel_expenditure ($costs, @days) {
   state $spans = [1, 7, 30];
   return 0 unless @days;
   my $min;
   for my $i (0 .. 2) {
      my ($first, @pool) = @days;
      shift @pool while @pool && $pool[0] < $first + $spans->[$i];
      my $cost = $costs->[$i] + travel_expenditure($costs, @pool);
      $min = $cost if (! defined($min)) || ($cost < $min);
   }
   return $min;
}
```

The [Raku][] version has caching baked in, directly:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@days is copy) {
   put travel-expenditure(@days.splice(0, 3), @days);
}

sub travel-expenditure (@costs, @days) {
   state @spans = 1, 7, 30;
   state %cache;
   return 0 unless @days;
   my $key = @days.join(',');
   %cache{$key} //= (@costs Z @spans).map(-> ($cost, $span) {
      my ($first, @pool) = @days;
      @pool.shift while @pool && @pool[0] < $first + $span;
      $cost + samewith(@costs, @pool);
   }).min;
}
```

If you want to travel more... this will probably still work, altough it
might syphon more memory. I arrived up to 5 full years... and it didn't
complain. If you can travel more, you have time to find a more efficient
solution!

Stay safe!



[The Weekly Challenge]: https://theweeklychallenge.org/
[#219]: https://theweeklychallenge.org/blog/perl-weekly-challenge-219/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-219/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
