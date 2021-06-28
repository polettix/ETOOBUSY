---
title: PWC119 - Swap Nibbles
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-30 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#119][]. Enjoy!

# The challenge

> You are given a positive integer `$N`.
>
> Write a script to swap the two nibbles of the binary representation of
> the given number and print the decimal number of the new binary
> representation.
>
>> A nibble is a four-bit aggregation, or half an octet.
>
> To keep the task simple, we only allow integer less than or equal to 255.
>
> **Example**
>
>     Input: $N = 101
>     Output: 86
>     
>     Binary representation of decimal 101 is 1100101 or as 2 nibbles (0110)(0101).
>     The swapped nibbles would be (0101)(0110) same as decimal 86.
>     
>     Input: $N = 18
>     Output: 33
>     
>     Binary representation of decimal 18 is 10010 or as 2 nibbles (0001)(0010).
>     The swapped nibbles would be (0010)(0001) same as decimal 33.

# The questions

I've become increasingly lazy at finding out questions for challenges,
as Colin Crain's review remind me almost weekly. As an example, there
was *a lot* of space for interpretation in challenge [Number
Sequence][], but I just assumed that we were talking about increasing
sequences. I'm not sure I would stick to my solution in hindsight.

Anyway, this challenge seems to be pretty tight in the requirements.
We're talking about positive integers whose value is less than or equal
to 255, which means that it's possible to consider a binary
representation with exactly two nibbles for each valid candidate.

Of course we might argue that the definition of *nibble* leaves some
interpretation to irritating people like me, because aggregation does
not necessarily imply adjacency or alignment to multiples of 4 bits. So,
for sake of irritating the reader, I'll go on and say that, in my
interpretation:

- inputs are always considered as fitting a full octet, represented in
  binary as a sequence of exactly 8 bits
- the sequence can be divided into two nibbles, one including the first
  four bits of the sequence, the other including the last four bits.

I wonder what I'm leaving out!

# The solution

This can be addressed with bit fiddling only:

```raku
#!/usr/bin/env raku
use v6;
sub swap-nibbles (Int:D $N where 0 < $N <= 255) { $N +& 0x0F +< 4 +| $N +> 4 }
my @inputs = @*ARGS ?? @*ARGS !! < 101 18 >;
swap-nibbles(+$_).put for @inputs;
```

Thanks to the precedence rules, the expression does not need
parentheses, although this goes at the expense of readability. This is
probably a more maintainable version:

```
(
    ($N +& 0x0F)   # isolate the least-significant nibble
    +< 4           # shift it 4 bits to the left, i.e. in the position
)                  # of the other nibble
+|                 # then "or" this with
($N +> 4)          # the most-significant nibble moved 4 bits to the
                   # right, i.e. in the position of the other nibble
```

There is no need to mask the higher nibble before moving it onto the
lower one, because the input constraints on `$N` already exclude
that there's no bit set beyond the high nibble, and the shift to the
right will ditch the lower nibble.

On with the [Perl][] equivalent, more or less:

```perl
#!/usr/bin/env perl
use v5.24;
sub swap_nibbles { ($_[0] & 0x0F) << 4 | $_[0] >> 4 }
my @inputs = @ARGV ? @ARGV : qw< 101 18 >;
say swap_nibbles($_) for @inputs;
```

We're losing signatures and input validation here, which is fair for
making the point of a challenge but would probably need to be
highlighted in an interview!

I also find it interesting that the operators precedence is slightly
different here than in [Raku][], and we need to force the masking
operation `$_[0] & 0x0F` to happen before the shift to the left
(otherwise, `perl` would interpret it as `$_[0] & (0x0F << 4)`, i.e.
`$_[0] & 0xF0`, i.e. *keep the high nibble as it is!*).

Well, I guess it's everything for this challenge task!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#119]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-119/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-119/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Number Sequence]: https://theweeklychallenge.org/blog/perl-weekly-challenge-116/#TASK1
