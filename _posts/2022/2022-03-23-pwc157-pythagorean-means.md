---
title: PWC157 - Pythagorean Means
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#157][]. Enjoy!

# The challenge

> You are given a set of integers.
>
> Write a script to compute all three `Pythagorean Means` i.e
> **Arithmetic Mean**, **Geometric Mean** and **Harmonic Mean** of the
> given set of integers. Please refer to wikipedia [page][] for more
> informations.
>
> **Example 1:**
>
>     >Input: @n = (1,3,5,6,9)
>     >Output: AM = 4.8, GM = 3.9, HM = 2.8
>
> **Example 2:**
>
>     >Input: @n = (2,4,6,8,10)
>     >Output: AM = 6.0, GM = 5.2, HM = 4.4
>
> **Example 3:**
>
>     >Input: @n = (1,2,3,4,5)
>     >Output: AM = 3.0, GM = 2.6, HM = 2.2


# The questions

One initial question would be about the ranges of the input:

- how many numbers will we be getting?
- is there a maximum?
- is there a minimum?

Then a question about the expected result: should that be an integer as
the inputs? (The examples seem to indicate that no, it should not be).

Last, why not... are they going to be sorted?

# The solution

This seems an excellent puzzle to prompt for studying numerical
analysis. Alas, this would anyway prevent me from doing two things I
love: being lazy and reinventing wheels.

Hence, I'll be ignoring any consideration and just code the functions in
the most straightforward way I can think of. Let's start with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @inputs = @args ?? @args !! (1, 3, 5, 6, 9);
   @inputs.say;
   "AM = %.1f, GM = %.1f, HM = %.1f\n".printf(
      arithmetic-mean(@inputs),
      geometric-mean(@inputs),
      harmonic-mean(@inputs)
   );
}

sub arithmetic-mean (@n) { @n.sum / @n.elems }
sub geometric-mean  (@n) { ([*] @n).abs ** (1 / @n.elems) }
sub harmonic-mean   (@n) { 1 / arithmetic-mean(@n.map: 1 / *) }
```

I love how the hyperoperation `[*]` addresses the product nicely for the
`geometric-mean` function. The harmonic mean is the reciprocal of the
arithmetic mean of the reciprocals... and it's coded like that!

The translation into [Perl][] is amazingly matching, thanks to
[List::Util][] which is in CORE and just a `use` away:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util qw< sum product >;

my @inputs = @ARGV ? @ARGV : (1, 3, 5, 6, 9);
printf "AM = %.1f, GM = %.1f, HM = %.1f\n",
  arithmetic_mean(@inputs),
  geometric_mean(@inputs),
  harmonic_mean(@inputs);

sub arithmetic_mean (@n) { sum(@n) / @n }
sub geometric_mean  (@n) { abs(product(@n)) ** (1 / @n) }
sub harmonic_mean   (@n) { 1 / arithmetic_mean(map { 1 / $_ } @n) }
```

I was lucky to look in the docs for `product` and actually find it
there! Otherwise, I would probably have coded the `geometric_mean` in
terms of `reduce` (in [List::Util][]):

```perl
...
use List::Util 'reduce';
sub gmalt (@n) { (reduce {$a * $b} @n) ** (1 / @n) }
```

I think the version with `product` is more readable though, so I'll
stick with it.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#157]: https://theweeklychallenge.org/blog/perl-weekly-challenge-157/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-157/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[page]: https://en.wikipedia.org/wiki/Pythagorean_means
[List::Util]: https://metacpan.org/pod/List::Util
