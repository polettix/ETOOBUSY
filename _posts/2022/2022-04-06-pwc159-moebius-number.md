---
title: PWC159 - Moebius Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-04-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#159][].
> Enjoy!

# The challenge

> You are given a positive number `$n`.
>
> Write a script to generate the `Moebius Number` for the given number.
> Please refer to wikipedia [page][] for more informations.
>
> **Example 1:**
>
>     Input: $n = 5
>     Output: -1
>
> **Example 2:**
>
>     Input: $n = 10
>     Output: 1
>
> **Example 3:**
>
>     Input: $n = 20
>     Output: 0

# The questions

This challenge is a sibling of [PWC150 - Square-free Integer][], with
the exception that this time we're told that we have to consider only
*positive* numbers. I mean... *integer numbers*, right?

# The solution

We're adapting the solution from [PWC150 - Square-free Integer][], just
to remain on the *lazy* side:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say $_, ' ', moebius_number($_) for (@ARGV ? @ARGV : (1 .. 10));

sub moebius_number ($n) {
   return 0 unless $n % 4;
   ($n, my $n_divisors) = $n % 2 ? ($n, 0) : ($n / 2, 1);
   my $divisor = 3;
   while ($n >= $divisor) {
      if ($n % $divisor == 0) {
         ++$n_divisors;
         $n /= $divisor;
         return 0 unless $n % $divisor;
      }
      $divisor += 2; # go through odd candidates only
   }
   return 1 - 2 * ($n_divisors % 2);
}
```

And the same goes for [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put $_, ' ', möbius-number($_) for @args}

sub möbius-number ($n is copy) {
   return 0 if $n %% 4;
   ($n, my $n-divisors) = $n %% 2 ?? (($n / 2).Int, 1) !! ($n, 0);
   my $divisor = 3;
   while $n >= $divisor {
      if $n %% $divisor {
         ++$n-divisors;
         $n = ($n / $divisor).Int;
         return 0 if $n %% $divisor;
      }
      $divisor += 2; # go through odd candidates only
   }
   return 1 - 2 * ($n-divisors % 2);
}
```

The case for divisibility by 2 is handled specially just to be able to
increment the `$divisor` variable by 2 instead of by 1. Apart from this,
we're sticking to the definition in the [Wikipedia page][page],
returning 0 whenever we find a square in the divisors, or using the
even/odd count of prime factors to figure out the right value to return.

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#159]: https://theweeklychallenge.org/blog/perl-weekly-challenge-159/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-159/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[page]: https://en.wikipedia.org/wiki/M%C3%B6bius_function
[PWC150 - Square-free Integer]: {{ '/2022/02/03/pwc150-square-free-integer/' | prepend: site.baseurl }}
