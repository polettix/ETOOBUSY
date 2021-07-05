---
title: PWC120 - Swap Odd/Even bits
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#120][]. Enjoy!

# The challenge

> You are given a positive integer `$N` less than or equal to 255.
>
> Write a script to swap the odd positioned bit with even positioned bit
> and print the decimal equivalent of the new binary representation.
>
> **Example**
>
>     Input: $N = 101
>     Output: 154
>     
>     Binary representation of the given number is 01 10 01 01.
>     The new binary representation after the odd/even swap is 10 01 10 10.
>     The decimal equivalent of 10011010 is 154.
>     
>     Input: $N = 18
>     Output: 33
>     
>     Binary representation of the given number is 00 01 00 10.
>     The new binary representation after the odd/even swap is 00 10 00 01.
>     The decimal equivalent of 100001 is 33.

# The questions

Asking questions in this challenge is actually nit-picking a lot. Or
maybe not.

I would only object that it's not entirely clear which odd-positioned
bit should be swapped with which even-positioned bit. From here, it's
easy to e.g. say that we're swapping 0 with 7, 1 with 6, 2 with 5, etc.

So the question is: should pairing consider that, considering a binary
representation where the position of the least significant bit in the
byte is 0, the bit in position $2k$ should be swapped with the bit in
position $2k + 1$?

Another question is: should we swap *all* pairs of odd/even bits? The
first example seems to imply that this is indeed the case, because every
bit changes.

# The solution

Let's look at the bit numbering for our octet:

```
7   5   3   1
  6   4   2   0
```

To swap each pair of odd/even bits, we have to move all odd bits to the
right and all even bits to the left:

```
  7   5   3   1
6   4   2   0
```

This is easily accomplished using the *bit shift* operators, widely
available in many languages. For [Perl][] we have `>>` and `<<`
respectively, for [Raku][] we have `+>` and `+<` (respectively).

How to isolate the odd bits from the even bits, then? This can be done
by *masking* the input with values that force the unwanted bits to 0:

```
1 0 1 0 1 0 1 0  <- 170 (decimal)

0 1 0 1 0 1 0 1  <-  85 (decimal)
```

Again, masking is usually available in many languages by means of the
AND operator (`&` in [Perl][], `+&` in [Raku][]).

Last, we re-assemble the two parts together. This is done using the OR
operator on the two parts (`|` in [Perl][] and `+|` in [Raku][]).

Let's get to the solutions then.

[Raku]:

```raku
#!/usr/bin/env raku
use v6;
sub soeb (Int:D $N where 0 < * <= 255) {$N +& 170 +> 1 +| $N +& 85 +< 1}
put soeb(+$_) for @*ARGS ?? @*ARGS !! <101 18>
```

It's easy to account for "non-negative integers below or equal to 255"
by changing the `0 < * <= 255` into `0 <= * <= 255`.

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
sub soeb { ($_[0] & 170) >> 1 | ($_[0] & 85) << 1 }
say soeb($_) for @ARGV ? @ARGV : qw< 101 18 >;
```

I know... we're losing the check on the input parameter here, but I
guess it's fine for this challenge.

Stay safe everyone!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#120]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-120/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-120/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
