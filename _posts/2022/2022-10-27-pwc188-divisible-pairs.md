---
title: PWC188 - Divisible Pairs
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-10-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#188][]. Enjoy!

# The challenge

> You are given list of integers `@list` of size `$n` and divisor `$k`.
>
> Write a script to find out count of pairs in the given list that
> satisfies the following rules.
>
>     The pair (i, j) is eligible if and only if
>     a) 0 <= i < j < len(list)
>     b) list[i] + list[j] is divisible by k
>
> **Example 1**
>
>     Input: @list = (4, 5, 1, 6), $k = 2
>     Output: 2
>
> **Example 2**
>
>     Input: @list = (1, 2, 3, 4), $k = 2
>     Output: 2
>
> **Example 3**
>
>     Input: @list = (1, 3, 4, 5), $k = 3
>     Output: 2
>
> **Example 4**
>
>     Input: @list = (5, 1, 2, 3), $k = 4
>     Output: 2
>
> **Example 5**
>
>     Input: @list = (7, 2, 4, 5), $k = 4
>     Output: 1

# The questions

It would be interesting to understand what's the allowed range for `$k`
and for the list size `$n`.

# The solution

The sum of two items will be divisible by `$k` if and only if their
rests modulo `$k` sum to either 0 or `$k` itself. The first happens for
class 0 by itself, the others... well, if their sum is `$k`. We'll call
these pairs complementary, so 0 is its own complementary, as well as `$k
/ 2` for even values of `$k`.

If we have a number $N$ of self-complementary values, the amount of
pairs they contribute to the total count will be the same as the number
of handshakes among $N$ people, i.e. $\frac{N \cdot (N - 1)}{2}$.

Otherwise, if the two rest classes are different, the number of items
they contribute will be the product of the number of elements in the two
sets. Each item in one set will be paired with eeach item in the other
set, because it will come either before, or after them in the list.

So, all in all, this is the implementation:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   put divisible-pairs(2, [4, 5, 1, 6]);
   put divisible-pairs(4, [7, 2, 4, 5]);
   put divisible-pairs(4, [7, 2, 6, 10, 1, 5, 3]);
}

sub divisible-pairs ($k, @list) {
   my %rest-for;
   for @list -> $e { %rest-for{$e % $k}++ }
   sub handshakes ($n) { (($n * ($n - 1)) / 2).Int }
   my $n = handshakes(%rest-for{0} // 0);
   for 1 .. $k / 2 -> $i {
      my $j = $k - $i;
      $n += $j == $i ?? handshakes(%rest-for{$i} // 0)
         !! (%rest-for{$i} // 0) * (%rest-for{$j} // 0);
   }
   return $n;
}
```

In [Perl][] terms...

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say divisible_pairs(2, 4, 5, 1, 6);
say divisible_pairs(4, 7, 2, 4, 5);
say divisible_pairs(4, 7, 2, 6, 10, 1, 5, 3);

sub divisible_pairs ($k, @list) {
   my %rest_for;
   $rest_for{$_ % $k}++ for @list;
   my $handshakes = sub ($n) { int($n * ($n - 1) / 2) };
   my $n = $handshakes->($rest_for{0} // 0);
   for my $i (1 .. $k / 2) {
      my $j = $k - $i;
      $n += $j == $i ? $handshakes->($rest_for{$i} // 0)
         : ($rest_for{$i} // 0) * ($rest_for{$j} // 0);
   }
   return $n;
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#188]: https://theweeklychallenge.org/blog/perl-weekly-challenge-188/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-188/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
