---
title: PWC113 - Represent Integer
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-19 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#113][]. Enjoy!

# The challenge

> You are given a positive integer `$N` and a digit `$D`.
>
> Write a script to check if `$N` can be represented as a sum of
> positive integers having `$D` at least once. If check passes print 1
> otherwise 0.
> 
> *Example**
> 
>     Input: $N = 25, $D = 7
>     Output: 0 as there are 2 numbers between 1 and 25 having the digit 7 i.e. 7 and 17. If we add up both we don't get 25.
> 
>     Input: $N = 24, $D = 7
>     Output: 1

# The questions

Well, let's not make too many questions here, because there's a little
loophole... OK, let's just say that we assume that `14` qualifies as
being represented for digit `7` because you get it when you sum `7`
twice. Makes sense?

# The solution

There are some special conditions where we know the answer beforehand:

- values of `$N` less than digit `$D` do not comply;
- values that have digit `$D` inside do comply;
- values where `$N >= 10 * $D` always comply.

Wait... what?!?

If a value $N$ is such that $N > 10 \cdot D$, it means that it can be
expressed as the following sum:

$$
N = 10 \cdot D + K
$$

Now we can consider that $K$ can be expressed in terms of its integer
division by $D$ like follows:

$$
K = q \cdot D + r
$$

with $0 \leq r < D \leq 9$. Hence, we can write $N$ as follows:

$$
N = 10 \cdot D + q \cdot D + r \\
N = q \cdot D + (10 \cdot D + r)
$$

Now, $q \cdot D$ is the same as summing $D$ to itself $q$ times, so it
can be represented in terms of "sum of positive integers having $D$ at
least once".

On the other hand, considering the restrictions on $D$ and $r$, the
value $10 \cdot D + r$ is the two-digits number where the first digit is
$D$ and the last digit is $r$, hence it contains digit $D$ and complies
with the rule.

As a result, $N$ is the sum of two compliant addentds and can thus be
decomposed according to the rules.

For all the rest we will rely on *brute force*, because the rules
expressed above allow us to put a hard limit to the search space:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub represent_integer ($n, $d) {
   return 0 if $n < $d;        # no point in checking this
   return 1 if $n >= 10 * $d;  # q * d + (10 * d + r)  (0 <= r < 9)
   return 1 if $n =~ m{$d}mxs; # match one digit
   $n -= $d;
   while ($n > 0) {
      return 1 if represent_integer($n, $d);
      $n -= 10;
   }
   return 0;
}

my $N = shift || 25;
my $D = shift || 7;
say represent_integer($N, $D) ? 1 : 0;
```

This recursive implementation will not be too much taxing... so it's OK
for this challenge.

Cheers!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#113]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-113/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-113/#TASK1
[Perl]: https://www.perl.org/
