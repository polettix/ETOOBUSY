---
title: PWC086 - Pair Difference
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#086][]. Enjoy!

# The challenge

> You are given an array of integers `@N` and an integer `$A`. Write a
> script to find find if there exists a pair of elements in the array whose
> difference is `$A`. Print `1` if exists otherwise `0`.

# The questions

Not many questions on this one, apart the ritual ones on input validation.
It might be interesting to know whether the input list `@N` is ordered
though, because it might change our approach to the solution.

# The solution

I can't think of a way in which this puzzle does not have a $O(n^2)$
complexity with respect to the number of elements in array `@N`. *In
general* each pair of items should be checked against `$A`.

It can be observed, though, that if the array is sorted e.g. in ascending
order, it's possible to do some pruning. As an example, consider this
situation:

```
$A = 7;
@N = (1 2 3 1000 2000 3000 3004 3007 5000 6000);
```

When we start taking the `1` and check it against the `1000` (with a
difference of `999`), it's clear that any element after that will yield
something bigger. Considering that `999` is *already* bigger than `7`, it
makes no sense to seach further for a companion to `1` and we can proceed
with the following candidate (`2` in the example). In this specific
arrangement, items `5000` and `6000` are never considered actually, because
the search will stop at the `3000` with `3007` pair.

Anyway, this still is $O(n^2)$ so, as I was saying at the beginning... I
can't think of anything better. Maybe sorting the input array is overkill:
it does not make the complexity worse (it's $O(n \cdot log2(n))$ after all)
but knowing if it's already sorted... is worth a question anyway.

Ok so for the general case without sorting this is what I came up with:

```
 1 sub pair_difference ($A, @N) {
 2    $A = -$A if $A < 0;
 3    for my $i (0 .. $#N - 1) {
 4       for my $j ($i + 1 .. $#N) {
 5          return 1 if abs($N[$i] - $N[$j]) == $A;
 6       }
 7    }
 8    return 0;
 9 }
```

It's really as simple as this: iterate over all possible *distinct* pairs
(lines 3 and 4 make sure of this), take the absolute value of their
difference, and compare it against the absolute value of the input `$A`.
Stop as soon as you find a match (line 5 has an immediate `return`), go on
to the end otherwise.

The full script for playing is the following:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub pair_difference ($A, @N) {
   $A = -$A if $A < 0;
   for my $i (0 .. $#N - 1) {
      for my $j ($i + 1 .. $#N) {
         return 1 if abs($N[$i] - $N[$j]) == $A;
      }
   }
   return 0;
}

sub main ($A = 7, @N) { say pair_difference($A, @N) }

main(@ARGV);
```

I know... I should settle with a definitive way of doing these scripts!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#086]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-086/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-086/#TASK1
[Perl]: https://www.perl.org/
