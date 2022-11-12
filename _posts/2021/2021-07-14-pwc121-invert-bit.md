---
title: PWC121 - Invert Bit
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#121][]. Enjoy!

# The challenge

> You are given integers 0 <= `$m` <= 255 and 1 <= `$n` <= 8.
>
> Write a script to invert `$n` bit from the end of the binary
> representation of `$m` and print the decimal representation of the new
> binary number.
>
> **Example**
>
>     Input: $m = 12, $n = 3
>     Output: 8
>     
>     Binary representation of $m = 00001100
>     Invert 3rd bit from the end = 00001000
>     Decimal equivalent of 00001000 = 8
>     
>     Input $m = 18, $n = 4
>     Output: 26
>     
>     Binary representation of $m = 00010010
>     Invert 4th bit from the end = 00011010
>     Decimal equivalent of 00011010 = 26

# The questions/assumptions

From the examples, it seems that *from the end of the binary
representation* means that we start from the least significant bit and
move towards the most significant bit. This will be our assumption.

It's interesting that input `$n` starts from 1, meaning *first*. As an
amateur programmer, I'm used to seeing the first item to get an *index*
of 0, but of course it's just a matter of knowing what is what.

# The solution

This bit munching is becoming a trend!

To address this challenge we can put to good use an old friend, i.e. the
*exclusive or* (XOR) operator. In a nutshell, it takes two input bits,
and tells us if they differ (giving out a 1) or are equal (giving out a
0). This is the so-called *truth table* for this operator:

```
         A
     | 0 | 1 |
  ---+---+---+
   0 | 0 | 1 |
B ---+---+---+
   1 | 1 | 0 |
  ---+---+---+
```

Now, let's consider the effect of...

- *fixing B to 0*: we see that the output is the same as A;
- *fixing B to 1*: we see that the output is the inverse of A.

This means that we can apply our XOR operator to a whole bunch of bits,
making sure that the value we XOR our input with has 0 in the positions
of bits that we want to preserve, and 1 where we want to invert to bit.

So, for example, if we want to invert the third bit of the input value
12, we can apply XOR with a value that has all 0 except in the third
bit, where we put 1:

```
 12 -----> 00001100
       XOR 00000100
           --------
  8 <----- 00001000
```

Now we are left with the task of finding the right *mask* to apply the
XOR operator. As we are required to invert one single bit, it will be
like the example above, i.e. all 0 except for 1 in one single position.

This can be done with the help of another *bitwise* operator, i.e. the
*shift left* operator (let's call it SHL). It takes two numbers, the
first is the starting value, the second is the number of positions that
its bits have to be shifted to the left (appending 0 in the least
significant positions).

So, for example, if we start from 1 (i.e. `00000001`) and shift it 2
times to the left we obtain 4 (i.e. `00000100`).

If you're wondering... yes, shifting to the left is the same as
multiplying by powers of 2.

Now we have all ingredients for our bit inversion recipe:

```
$m XOR (1 SHL ($n - 1))
```

We have to use `$n - 1` because our starting point (i.e. 1, a.k.a.
`00000001`) already has 1 in the *first* position, so it needs no
shifting.

Let's get to the code then, [Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
subset IntByte of Int where 0 <= * <= 255;
subset BitNum  of Int where 1 <= * <= 8;
sub invert-bit (IntByte:D $m, BitNum:D $n) { $m +^ (1 +< ($n - 1)) }

put "m=12 n=3 -> " ~ invert-bit(12, 3);
put "m=18 n=4 -> " ~ invert-bit(18, 4);
```

The XOR operator is `+^` and the shift operator is `+<`, so the solution
is the direct translation of our generic recipe above.

[Perl][] now, with its own operator XOR (`^`) and SHL (`<<`):

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub invert_bit ($m, $n) { $m ^ (1 << --$n) }
say "m=12 n=3 -> " . invert_bit(12, 3);
say "m=18 n=4 -> " . invert_bit(18, 4);
```

As we have seen a few times in the past, we lose the *simplicity* to
have input parameters validation in a *declarative* way. That's life.

On the other hand. though, input parameters in [Perl][]'s (still
experimental) signatures are copies of the original values, so we can
pre-decrement `$n` instead of subtracting 1 and spare a whopping 4
characters!!!

Well... enough is enough, stay safe everyone!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#121]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-121/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-121/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
