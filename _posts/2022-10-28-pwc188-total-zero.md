---
title: PWC188 - Total Zero
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-10-28 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#188][].
> Enjoy!

# The challenge

> You are given two positive integers `$x` and `$y`.
>
> Write a script to find out the number of operations needed to make
> both `ZERO`. Each operation is made up either of the followings:
>
>     $x = $x - $y if $x >= $y
>
>     or
>
>     $y = $y - $x if $y >= $x (using the original value of $x)
>
> **Example 1**
>
>     Input: $x = 5, $y = 4
>     Output: 5
>
> **Example 2**
>
>     Input: $x = 4, $y = 6
>     Output: 3
>
> **Example 3**
>
>     Input: $x = 2, $y = 5
>     Output: 4
>
> **Example 4**
>
>     Input: $x = 3, $y = 1
>     Output: 3
>
> **Example 5**
>
>     Input: $x = 7, $y = 4
>     Output: 5

# The questions

The wording is very *precise* but anyway clear. My initial *WTF* moment
was about the `$x == $y` case, but the `using the original value...`
part made it clear (for me at least).

As I said, the wording is precise, in that the `either` and the `or` are
interpreted *inclusively*, i.e. there are cases where you can apply both
operations.

# The solution

This challenge started crying **EUUUUUCLIIIIIID** since the first mental
attempt at calculating the result for the first example.

Why Euclid? Well, the operations that I thought I would apply were very
close to the typical algorithm for calculating the Greatest Common
Divisor between two positive integers. Which, by the way, is [this][]:

```perl
sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }
```

OK, back to the challenge. Let's first put it recursively and very
similar to how it's described:

- if `$y == $x`, return 1 (in one step they both go to 0)
- otherwise, subtract the lower one from the higher one and recurse.

The repeated subtractions are clearly a distraction. If I subtract `$x`
from `$y`, and I end up with a greater `$y`, I know that I have to
continue subtracting `$x`. Hence, as long as `$y` keeps greater than
`$x`, we will subtract `$x`. That is, we divide `$y` by `$x` and this is
the number of operations that we do, counting them.

Well, well, not *necessarily* so fast. There are two cases:

- `$y` is *not* a multiple of `$x`. We will end up with an integer
  number of subtractions (i.e. `int($y / $x)`) and we will be left with
  `0 < $y < $x`. Rinse, repeat.

- `$y` is a multiple of `$x`, i.e. `$y = $n * $x`. In this case, we have
  to carry `$n - 1` operations with `$y > $x`, then a final operation
  because the remaining `$y` is equal to `$x`. This is `$n` operations
  in total.

Where does this bring us to? Here:

- if `$y == $n * $x`, return `$n` (this includes the old case about `$y
  == $x`, right?)

- otherwise, calculate `$n = int($y / $x)` and `$r = $y % $x`, then
  return `$n` plus the recursion over `$x` and `$r`. 

This is where the Euclid algorithm starts to pop up, because it's
basically the same thing, *except* that the return value is different
(i.e. it's not the sum of the integer divisions, but the final non-zero
rest).

So, here's an iterative implementation:

```perl
sub total_zero ($A, $B, $n = 0) {
   ($A, $B, $n) = ($B % $A, $A, $n + int($B / $A)) while $A;
   return $n;
}
```

I'm cheating a bit by declaring variable `$n` directly in the signature,
sparing a line. It's a game, right?

Here's the [Raku][] version:

```raku
sub total-zero ($A is copy, $B is copy, $n is copy = 0) {
   ($A, $B, $n) = $B % $A, $A, $n + ($B / $A).Int while $A;
   return $n;
}
```

I hope I was clear enough... otherwise ring a bell!

Stay safe!




[The Weekly Challenge]: https://theweeklychallenge.org/
[#188]: https://theweeklychallenge.org/blog/perl-weekly-challenge-188/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-188/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[this]: https://github.com/polettix/cglib-perl/blob/master/Numbers.pm#L9
