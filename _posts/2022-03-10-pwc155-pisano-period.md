---
title: PWC155 - Pisano Period
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#155][].
> Enjoy!

# The challenge

> Write a script to find the period of the `3rd Pisano Period`.
>
>> In number theory, the nth Pisano period, written as π(n), is the
>> period with which the sequence of Fibonacci numbers taken modulo n
>> repeats.
>
> The Fibonacci numbers are the numbers in the integer sequence:
>
>     0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, ...
>
> For any integer n, the sequence of Fibonacci numbers F(i) taken modulo
> n is periodic. The Pisano period, denoted π(n), is the value of the
> period of this sequence. For example, the sequence of Fibonacci
> numbers modulo 3 begins:
>
>     0, 1, 1, 2, 0, 2, 2, 1,
>     0, 1, 1, 2, 0, 2, 2, 1,
>     0, 1, 1, 2, 0, 2, 2, 1, ...
>
> This sequence has period 8, so π(3) = 8.

# The questions

Challenges lately are quite *tight* in their requirements that questions
are hard to think. I mean, if it were a more general question asking for
the $n$th number, I could have asked what the maximum value for $n$
would be...

I know it's 3, I'll assume it's not that big 😄

# The solution

Calculating the period by taking the remainder of the Fibonacci sequence
is the same as calculating each new item in the sequence directly from
the previously calculated reminders. In other terms, if we define:

$$
x_n := \{v: v = x + k \cdot n, k \in \mathbb{Z}\}
$$

that is the usual definition of remainder class modulo $n$, then we have:

$$
(x + y)_n = x_n + y_n
$$

In considering $x_n$, we can take *any* of the values $v$ in the class,
although usually the lowest non-negative value is used for simplicity.

In other terms, we can calculate the modulo operation as soon as we sum
two items, and forget about calculating the *original* Fibonacci
sequence.

This means that sequences MUST be periodic, because any time we end up
with the same pair of consecutive values, the sequence is going to
repeat. With only $n$ possible remainders, there are only $n^2$ possible
pairs of consecutive values, so at a certain point we MUST hit a pair
that we already saw.

Additional demonstrations show that it's OK to take the initial values
in the sequence as the ones to look for periodicity, so we will
concentrate on looking for $0_n$ followed by $1_n$. This is important
because the periodic part might be preceded by some a-periodic head, but
this is not the case here.

Let's look at the [Perl][] code:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say pisano_period(shift // 3);

sub pisano_period ($n) {
   my ($fl, $fh) = (0, 1 % $n);
   my $pp = 0;
   while ('necessary') {
      ($fl, $fh) = ($fh, ($fl + $fh) % $n);
      ++$pp;
      return $pp if $fl == 0 && $fh == 1 % $n;
   }
}
```

The astute reader will have noted that we're doing `1 % $n` while
initializing the two Fibonacci state variables. This is because $n = 1$
is a valid input, and in *that* case the remainder is $0$, not $1$.

We might just as well written this:

```perl
sub pisano_period ($n) {
    return 1 if $n == 1;
    my ($fl, $fh) = (0, 1);
    ...
```

Which leads us to [Raku][], where `multi sub` are a way to deal with
special cases:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Int:D $n = 3) { put pisano-period($n) }

multi sub pisano-period (1)  { return 1 }
multi sub pisano-period ($n) {
   my ($fl, $fh) = 0, 1;
   my $pp = 0;
   loop {
      ($fl, $fh) = $fh, ($fl + $fh) % $n;
      ++$pp;
      return $pp if $fl == 0 && $fh == 1;
   }
}
```

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#155]: https://theweeklychallenge.org/blog/perl-weekly-challenge-155/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-155/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
