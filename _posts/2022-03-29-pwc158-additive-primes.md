---
title: PWC158 - Additive Primes
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-29 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#158][]. Enjoy!

# The challenge

> Write a script to find out all `Additive Primes <= 100`.
>
>> Additive primes are prime numbers for which the sum of their decimal
>> digits are also primes.
>
> **Output**
>
>     2, 3, 5, 7, 11, 23, 29, 41, 43, 47, 61, 67, 83, 89

# The questions

This time I have a little nit-pick on the language used, in that "the
sum" (singular) "are also primes" (plural). Does this mean that this
should go all the way up reaching one digit only? I'll assume not,
because the `89` in the example has decimal digits sum `17`, which is
prime but not additive prime by itself (the sum of its digits being
`8`).

# The solution

The test for an additive prime will be very very straightforward:

- check that the number is prime
- check that the number resulting from the sum of its digits is prime.

Let's start with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $M = 100) {
   (2 .. $M).grep({$_.is-prime && $_.comb.sum.is-prime}).join(', ').put;
}
```

Short and sweet. The check for primality is a built-in `is-prime`;
summing the digits leverages on the fact that the default representation
of `Int`s as strings is in base 10, so it suffices to isolate the
individual digits with `comb` and `sum` them.

The [Perl][] version is more or less on par, with a few more inclusions
for extra batteries (`is_prime` and `sum`):

```perl
#!/usr/bin/env perl
use v5.24;
use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";
use ntheory 'is_prime';
use List::Util 'sum';

my $M = shift // 100;
say join ', ', grep { is_prime($_) && is_prime sum split m{}mxs } 2 .. $M;
```

The primality test is courtesy of [ntheory][], although in this specific
case it's overkill because getting primes up to 100 might be done with a
simple lookup table. Whatever.

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#158]: https://theweeklychallenge.org/blog/perl-weekly-challenge-158/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-158/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ntheory]: https://metacpan.org/pod/ntheory
