---
title: PWC082 - Common Factors
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#082][]. Enjoy!

# The challenge

> You are given 2 positive numbers `$M` and `$N`. Write a script to list all
> common factors of the given numbers.

# The questions

One question that popped in my mind was: *is this stemming from the recent
challenge Common Base String?* My solution required finding all possible
factors at a certain point, so...

Rite questions would be about what to do in corner cases: lack or wrong
inputs (e.g. strings or floating point values, negative values, etc.)

Last, a question might be about whether the output should comply to a
specific sorting or not. Apart, of course, confirmation about the output
interface (the round parentheses, distancing, ...).

# The solution

It might be possible to address this with a totally brute force approach
but... there's an evident property that can be used in this case.

Whatever factor the two inputs might have in common, it will also have
to be a factor of their *greatest common divisor* (which is the higher
factor that they have in common, by the way).

Hence, instead of comparing factors of the two inputs, it's easier to
find their greatest common divisor and find all of *its* factors.

To address the first issue, Euclid's algorithm is the perfect tool (we
already saw it in [The extended Euclid's algorithm][]) and can fit in a
single line:

```perl
sub gcd ($A, $B) { ($A, $B) = ($B % $A, $A) while $A; return $B }
```

Finding all of its factor can now be addressed with a O(N) linear
approach, somehow brute-force-ish:

```perl
sub common_factors ($A, $B) {
   my $gcd = gcd($A, $B);
   grep { !($gcd % $_) } 1 .. int($gcd / 2), $gcd;
}
```

We go through all *possible* candidates, keeping only those that are
really divisors of the greatest common divisor. These candidates are
`1`, the greatest common divisor itself, as well as any value between
`1` up to one half of the greatest common divisor (there cannot be a
factor that is greater than this).

An interesting side effect of the range up to the one half of the
greatest common divisor is that when this value is `1`, the integer
rounding `int($gcd / 2)` is equal to `0` and the range is empty, leaving
only `$gcd` (i.e. `1`) in the list fed to `grep`. This means that `1`
will only appear once in the output, which is good!

The full solution, should you want to play with it, is the following:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub gcd ($A, $B) { ($A, $B) = ($B % $A, $A) while $A; return $B }

sub common_factors ($A, $B) {
   my $gcd = gcd($A, $B);
   grep { !($gcd % $_) } 1 .. int($gcd / 2), $gcd;
}

my $M = shift || 12;
my $N = shift || 18;
say '(', join(', ', common_factors($M, $N)), ')';
```

This is it for today, stay tuned for the other task!

[The extended Euclid's algorithm]: {{ '/2020/01/08/extended-euclid/' | prepend: site.baseurl }}
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#082]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-082/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-082/#TASK1
