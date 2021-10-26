---
title: PWC136 - Two Friendly
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#136][].
> Enjoy!

# The challenge

> You are given 2 positive numbers, `$m` and `$n`.
>
> Write a script to find out if the given two numbers are `Two
> Friendly`.
>
>> Two positive numbers, m and n are two friendly when gcd(m, n) = 2 ^ p
>> where p > 0. The greatest common divisor (gcd) of a set of numbers is
>> the largest positive number that divides all the numbers in the set
>> without remainder.
>
> **Example 1**
>
>     Input: $m = 8, $n = 24
>     Output: 1
>
>     Reason: gcd(8,24) = 8 => 2 ^ 3
>
> **Example 2**
>
>     Input: $m = 26, $n = 39
>     Output: 0
>
>     Reason: gcd(26,39) = 13
>
> **Example 3**
>
>     Input: $m = 4, $n = 10
>     Output: 1
>
>     Reason: gcd(4,10) = 2 => 2 ^ 1

# The questions

I'm assuming that *number* here means *integer*, right?

Apart from this... nothing more to ask!

# The solution

We'll start with [Raku][], over-engineering a bit a cryptic solution.
Yes! Both cryptic *and* over-engineered!

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($m = 8, $n = 24) { put two-friendly($m, $n) ?? 1 !! 0 }
subset Pint of Int where * > 0;
sub two-friendly (Pint:D $m, Pint:D $n) { positive-power2(gcd($m, $n)) }
sub positive-power2 ($x) { $x > 1 && is-power2($x) }
multi sub is-power2 (1) { True }
multi sub is-power2 ($x where * <= 0) { False }
multi sub is-power2 ($x where * %% 2) { is-power2($x +> 1) }
multi sub is-power2 ($x) { False }
sub gcd ($A is copy, $B is copy) { ($A, $B) = $B % $A, $A while $A; $B }
```

The over-engineering is about using `multi` sub to cope with the
different cases. I wanted to go for a solution where each function fit
in a single line, but also to exercise some muscle memory that these
*functional* cases can be addressed with `multi` instead of
`if/then/else` or chaining conditions.

So we put [Raku][] at work by first figuring out the best case, even
adding a case that makes things a bit ambiguous: what if our input is
*both* negative and exactly divisible by 2? Anyway, this is a moot
question in this case, because `is-power2` is only called with positive
integers in our program, so the sub about `$x` being negative is there
only for documentation.

In some sense, the [Perl][] translation also simplifies things, because
it's still possible to stick to the one-liner functions while moving to
a more traditional "complex" boolean condition in `is_power2`:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say two_friendly(@ARGV ? @ARGV[0, 1] : (8, 24)) ? 1 : 0;
sub two_friendly ($m, $n) { positive_power2(gcd($m, $n)) }
sub positive_power2 ($x) { $x > 1 && is_power2($x) }
sub is_power2 ($x) { $x == 1 || $x > 0 && !($x % 2) && is_power2($x >> 1) }
sub gcd ($A, $B) { ($A, $B) = ($B % $A, $A) while $A; $B }
```

I know, I know... we're also losing input validation, but why spoil such
a compact amass of characters and steal a lot of people the delight to
bash [Perl][]? 🙄

Stay safe everybody!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#136]: https://theweeklychallenge.org/blog/perl-weekly-challenge-136/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-136/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
