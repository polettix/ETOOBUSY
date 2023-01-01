---
title: PWC169 - Achilles Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#169][].
> Enjoy!

# The challenge

> Write a script to generate first `20 Achilles Numbers`. Please
> checkout [wikipedia][] for more information.
>
>> An Achilles number is a number that is powerful but imperfect (not a
>> perfect power). Named after Achilles, a hero of the Trojan war, who
>> was also powerful but imperfect.
>
>> A positive integer n is a powerful number if, for every prime factor
>> p of n, p^2 is also a divisor.
>
>> A number is a perfect power if it has any integer roots (square root,
>> cube root, etc.).
>
> For example 36 factors to (2, 2, 3, 3) - every prime factor (2, 3)
> also has its square as a divisor (4, 9). But 36 has an integer square
> root, 6, so the number is a perfect power.
>
> But 72 factors to (2, 2, 2, 3, 3); it similarly has 4 and 9 as
> divisors, but it has no integer roots. This is an Achilles number.
>
> **Output**
>
>     72, 108,  200,  288,  392,  432,  500,  648,  675,  800,  864, 968, 972, 1125, 1152, 1323, 1352, 1372, 1568, 1800

# The questions

I'm very hurried these days so a meta-question only: *can we peek at the
solution*? I admit that I did indeed peek, discovered that it was not
involving big numbers, and resolved to use a very, very lazy approach!

# The solution

As customary, for the second half of the weekly
challenge I'll start with [Perl][]. I've alrady told that I'm in a
hurry so my soluition has spaces for improvements. It works, anyway.

The idea is to check the powers of each prime that dives the target
number:

- it must be greater than one
- the overall *greatest common divisor* across all powers must be 1,
  i.e. these powers are co-primes (otherwise there would be an integer
  root).

So here we are, again with the help of [ntheory][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use ntheory qw< factor_exp >;

my $count = shift // 20;
my @achilles;
my $candidate = 72;
while (@achilles < $count) {
   push @achilles, $candidate if is_achilles($candidate);
   ++$candidate;
}
say join ', ', @achilles;

sub is_achilles ($n) {
   my $gcd;
   for my $pair (factor_exp($n)) {
      my $power = $pair->[1];
      return 0 if $power == 1;
      $gcd = $gcd ? gcd($gcd, $power) : $power;
   }
   return $gcd == 1;
}

sub gcd ($A, $B) { ($A, $B) = ($B % $A, $A) while $A; return $B }
```

The translation to [Raku][] is done in a hurry as well, reusing the
factorization function [from here][] and implementing the aggregation
function `factor_exp` to give the same result as the one in [ntheory][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $count where * > 0 = 20) {
   my @achilles;
   my $candidate = 72;
   while @achilles < $count {
      @achilles.push: $candidate if is-achilles($candidate);
      ++$candidate;
   }
   put @achilles.join(', ');
}

sub is-achilles ($n) {
   my $gcd;
   for factor_exp($n) -> ($p, $power) {
      return False if $power == 1;
      $gcd = $gcd ?? gcd($gcd, $power) !! $power;
   }
   return $gcd == 1;
}

sub gcd ($A is copy, $B is copy) {
   ($A, $B) = ($B % $A, $A) while $A;
   return $B;
}

sub factor_exp (Int $n) {
   my @retval = [0, 0],;
   for factors($n) -> $p {
      if $p == @retval[*-1][0] { @retval[*-1][1]++ }
      else                     { @retval.push: [$p, 1] }
   }
   @retval.shift;
   return @retval;
}

sub factors (Int $remainder is copy) {
   return 1 if $remainder <= 1;
   state @primes = 2, 3, 5, -> $n is copy {
      repeat { $n += 2 } until $n %% none @primes ... { $_ * $_ >= $n }
      $n;
   } ... *;
   gather for @primes -> $factor {
      if $factor * $factor > $remainder {
         take $remainder if $remainder > 1;
         last;
      }

      # How many times can we divide by this prime?
      while $remainder %% $factor {
         take $factor;
         last if ($remainder div= $factor) === 1;
      }
   }
}
```

I know that there must be a better solution... but not today!

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#169]: https://theweeklychallenge.org/blog/perl-weekly-challenge-169/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-169/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia]: https://en.wikipedia.org/wiki/Achilles_number
[ntheory]: https://metacpan.org/pod/ntheory
[from here]: https://examples.raku.org/categories/best-of-rosettacode/prime-decomposition.html
