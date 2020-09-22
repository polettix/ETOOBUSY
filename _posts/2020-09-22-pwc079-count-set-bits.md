---
title: PWC079 - Count Set Bits
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-09-22 21:16:44 +0200
mathjax: true
published: true
---

**TL;DR**

> Where we solve [Perl Weekly Challenge][] [#079][] [task #1][].

Let's try to adopt a systematic approach!

# The challenge

It's stated in a simple *yet somehow vague* form, like always:

> You are given a positive number `$N`. Write a script to count the
> total numbrer of set bits of the binary representations of all numbers
> from `1` to `$N` and return `$total_count_set_bit % 1000000007`.

# The questions

A few questions that one might ask during an interview:

- what should we do with incorrect values? (E.g. throw an error, return
  a specific output value, ...)
- is the input number representable as an integer in the target
  language? (E.g. in Perl we might start from a *string* that contains
  an integer that is too long to be represented as such internally, at
  least without the help of [Math::BigInt][]).
- is there a maximum value that can be fed as input `$N`?

# The solution

There is a *quick and dirty* solution that addresses the problem with
brute force:

```perl
sub count_bits_brute_force ($N, $m = 1000000007) {
   my $n_bits = 0;
   $n_bits = ($n_bits + (sprintf('%b', $_) =~ tr/1/1/)) % $m
      for 1 .. $N;
   return $n_bits;
}
```

It's a pretty straightforward translation of the input challenge: we
iterate over all integers from `1` to the input `$N` and count the bits
at each iteration, accumulating their count in `$n_bits` making sure
that we perform the modulus operation at each iteration. This is
necessary because the count might well exceed the maximum integer value
we can represent (whatever it is), simply because the count of set bits
for the maximum integer value will be way above it (hence, it's not
representable directly).

OK, that works but it's not that good: the iteration goes with $O(N)$
*and* each step goes with something that might arguably be about
$O(log(N))$, because the number of bits we get transforming `$N` in
binary representation is proportional to $log(N)$. Urgh.

As it is, anyway, it's a pretty decent solution to start with:

- it's so simple that it's quickly coded and hardly bugged
- it provides us a reference for checking more sophisticated solutions

so it does its job! Additionally, on my virtual machine it behaves in
*human time* for inputs up about ten million, so depending on the
boundaries of the problem (see the questions) it might solve the problem
and let us move ahead.

But... let's assume that we want to actually have a function that works
in reasonable time for any integer input that our programming language
can support natively. It's time to call the math to the rescue.

One insight is that all numbers of the type $2^k-1$ are very easily
calculated. Their binary representation is a sequence of $k$ `1`s, and
below them they have all possible sequences of $k$ bits. Yes, we can
also count the sequence of `$k` `0`s, because it does not alter our
calculation (as it does not contain any `1`).

Why are $2^k$ numbers easy? Simply because in this case we have to
consider the *whole* grid of possible arrangements of $k$ bits, which
gives us a total of $k \cdot 2^k$ bits. It's easy to see that half of
them will be `0` and the other half will be `1`, so the number we are
after in this case will be $k \cdot 2^{k-1}$. Easy!

Let's see this at work:

```
3 --> 11 --> 4 bits
      10
      01
      00
```

In this case, we have $k = 2$ and $k \cdot 2^{k-1} = 2 \cdot 2^1 = 4$.

Another example:

```
7 --> 111 --> 12 bits
      110
      101
      100
      011
      010
      001
      000
```

In this case we have $k = 3$ and $k \cdot 2^{k-1} = 3 \cdot 2^2 = 12$.

What happens *in general*? The representation of a number in binary form
will have the most significant bit set to `1`, followed by a sequence of
$k$ bits that can be either `0` or `1`:

```
1xxx...xxx
```

When we count backwards from `$N`, we will hit a point where this most
significant bit will turn to `0` and all the remaining bits will be `1`:

```
1xxx...xxx )
...         > section A
1000...000 )

0111...111 )
...         > section B
0000...000 )
```

It's easy to see that *section B* is the same as what we calculated
before, i.e. $2^k-1$, so we know how many `1`s we have (i.e. $k \cdot
2^{k-1}$).

Let's move to *section A*. The first observation is that the most
significant bit is always `1`, and it repeats for a number of times that
is $X = N - (2^k - 1) = (N - 2^k) + 1$.

At this point, we have to evaluate how many `1`s are present in *section
A* but *excluding* the leading `1`. It's easy to see that it's the same
number of `1` that appear in the solution to the problem for $X - 1$, so
we can just repeat the process!

This leads us to the following code:

```perl
 1 sub count_bits ($n, $m = 1000000007) {
 2    my $mask     = 1;
 3    my $mask_bit = 0;
 4    while (($n & ~$mask) > $mask) { # scan for highest set bit
 5       $mask <<= 1;
 6       $mask_bit++;
 7    }
 8    my $n_bits = 0;
 9    while ($n) {
10       while (($n & $mask) == 0) {    # scan for next high bit
11          $mask_bit--;
12          $mask >>= 1;
13       }
14       $n &= ~$mask;    # this makes $n less than half of itself
15       $n_bits = ($n_bits + 1 + $n + $mask_bit * ($mask >> 1) % $m) % $m;
16    } ## end while ($n)
17    return $n_bits;
18 } ## end sub count_bits
```

At the beginning (lines 2 to 7) we find out the position of the most
significant bit in `$n` (that is our input $N$) both as a one-bit mask
`$mask` and as a bit position `$mask_bit`, which represents our $k$.

When ready, we initialize our count to `0` (line 8) and start looping
until `$n` becomes `0`, which mean that we don't have to look for
further `1`s.

Lines 10 through 13 take care to move the `$mask`/`$mask_bit` pair onto
the most significant bit of the current value of `$n`, going *down*
because `$n` is decremented at each loop. As a matter of fact, the
operation in line 14 is the same as doing $N = N - 2^k$, preparing for
the following iteration.

Line 15 does the calculation of the bits in this iteration: the `1 + $n`
part represents the leading `1`s and the `$mask_bit * ($mask >> 1)`
represents the $k \cdot 2^{k - 1}$ part. The most critical operations
are performed modulo `$m` as requested to avoid overflows.

I think this is it!



[task #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-079/#TASK1
[#079]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-079/
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
