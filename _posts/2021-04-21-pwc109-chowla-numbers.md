---
title: PWC109 - Chowla Numbers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#109][]. Enjoy!

# The challenge

> Write a script to generate first 20 Chowla Numbers, named after,
> Sarvadaman D. S. Chowla, a London born Indian American mathematician.
> It is defined as:
>
>     C(n) = (sum of divisors of n) - 1 - n

# The questions

The first question is a picky one... *the definition above isn't really
correct, is it?!?* I mean, if we apply it to $n = 1$, technically
speaking we get $-1$, so it's a *good approximation*.

Hence, I'll refer to the definition in [Rosetta code][]:

>  The chowla number of $n$ is (as defined by Chowla's function):
>  - the sum of the divisors of $n$ excluding unity and $n$
>  - where $n$ is a positive integer

Then I guess we should start counting from $n = 1$ for taking the first
$20$ elements, right?

# The solution

I was a bit surprised when I found out that it's possible to code a very
compact solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'sum';

sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }

sub chowla_number ($n) { sum(grep { gcd($n, $_) == $_ } 2 .. $n - 1) // 0 }

say join ', ', map { chowla_number($_) } 1 .. 20;
```

It's tremendously inefficient but fits within the number of columns I
use as limit for coding subs as one-liners 🙄 Moreover... it's only 20
items, right?

Stay safe!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#109]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-109/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-109/#TASK1
[Perl]: https://www.perl.org/
[Rosetta code]: http://rosettacode.org/wiki/Chowla_numbers
