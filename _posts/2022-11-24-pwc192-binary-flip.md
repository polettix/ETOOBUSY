---
title: PWC192 - Binary Flip
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#192][]. Enjoy!

# The challenge

> You are given a positive integer, `$n`.
>
> Write a script to find the binary flip.

> **Example 1**
>
>     Input: $n = 5
>     Output: 2
>
>     First find the binary equivalent of the given integer, 101.
>     Then flip the binary digits 0 -> 1 and 1 -> 0 and we get 010.
>     So Binary 010 => Decimal 2.
>
> **Example 2**
>
>     Input: $n = 4
>     Output: 3
>
>     Decimal 4 = Binary 100
>     Flip 0 -> 1 and 1 -> 0, we get 011.
>     Binary 011 = Decimal 3
>
> **Example 3**
>
>     Input: $n = 6
>     Output: 1
>
>     Decimal 6 = Binary 110
>     Flip 0 -> 1 and 1 -> 0, we get 001.
>     Binary 001 = Decimal 1

# The questions

Well well... not much of a definition, but an operative algorithm in the
first example explains it pretty well.

We're assuming that the positive integer `$n` fits in a variable,
whatever the language and the system.

# The solution

The result will always be (strictly) lower than the input. Why? The
leftmost `1` bit in the input is turned onto a `0`, so the resulting
number is lower.

I know that there must be a clever way of doing it, especially in
[Raku][]. I'll stick to the basics, though.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($n = 5) { put binary-flip($n) }

sub binary-flip (Int $n is copy where * > 0) {
   my $mask = 0x01;
   my $result = 0;
   while $n {
      $result +|= $mask unless $n +& 1;
      $n +>= 1;
      $mask +<= 1;
   }
   return $result;
}
```

We're getting bits out from the rightmost part and arranging them in
with an always-doubling mask. Just plain bit handling.

The translation into [Perl][] if pretty straightforward, with less input
checks and slightly different operators:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say binary_flip(shift // 5);

sub binary_flip ($n) {
   my $mask = 0x01;
   my $result = 0;
   while ($n) {
      $result |= $mask unless $n & 0x01;
      $n >>= 1;
      $mask <<= 1;
   }
   return $result;
}
```

I guess this is everything, stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#192]: https://theweeklychallenge.org/blog/perl-weekly-challenge-192/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-192/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
