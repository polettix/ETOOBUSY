---
title: All positive integer sums
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-18 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> We start layout out some steps to compute all subsets that lead to
> [Bell numbers][].

In previous post [PWC108 - Bell Numbers][] we used the [Bell triangle][]
to compute the required values for [Bell numbers][]. I guess this saved
the day, but did not provide an answer to a more general question: *what
are all the possible [partitions of a set][] with $N$ distinct
elements?*

In this series, we try to give this *super* challenge a try. (Here,
*super* is just meant as *staying over*, not as being extremely more
challenging).

The general strategy is the following:

- first, find out how big should be the subsets in all possible
  breakdowns. As an example, if we want to partition over $3$ elements,
  we will have the following possible breakdown cardinalities: $(3)$
  (i.e. a single subset with $3$ elements inside), $(2, 1)$ (i.e. one
  subset with $2$ elements, one subset with the remaining $1$), $(1, 1,
  1)$ (i.e. three subsets with $1$ element each).
- then, figure out a way to use this breakdown to generate the actual
  subsets.

In this post, we start looking at the first bullet, which can also be
expressed as:

> In which different ways can I express the positive integer $N$ as a
> sum of other positive integers?

Using $3$ as in the example above, we have:

$$
3 = 3 \\
3 = 2 + 1 \\
3 = 1 + 1 + 1
$$

It is important in this context to realize that $2 + 1$ is the same as
$1 + 2$ for our purposes, so we will just consider the former. In
general, we will express our decomposition using only descending values,
and considering each decomposition only once.

The first way we find for this decomposition relies upon a recursive
approach:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub int_sums_recursive ($N, $max = undef) {
   return ([]) unless $N;
   $max = $N if ! defined($max) || $max > $N;
   my @retval;
   for my $first (reverse 1 .. $max) {
      push @retval, [$first, $_->@*]
         for int_sums_recursive($N - $first, $first);
   }
   return @retval;
}

say "($_->@*)" for int_sums_recursive(shift || 3);
```

At a certain point, the function is required to generate a sequence of
arrangements based on two constraints `$N` and `$max`:

- we have to arrange exactly `$N` elements;
- the maximum amount we can put in a slot is `$max`.

The first value is related to the initial amount that we want to
decompose; the second value guarantees that all generated sequences are
descending (or, at least, not ascending).

To make an example, let's assume that we are calculating all possible
decomposition of $5$ and we are at a point where the first item in the
decomposition is $2$. This means that we still have to arrange $3$
items, whose decomposition would be the following:

$$
3 = 3 \\
3 = 2 + 1 \\
3 = 1 + 1 + 1
$$

as we saw above. In this context, though, the first decomposition would
yield the following in the decomposition of $5$:

$$
... \\
5 = 2 + 3 \\
...
$$

which breaks our requirement of having only not-increasing sequences.
For this reason, in the recursive call for decomposing $3$, we also set
that the *maximum* value to assign to a slot is $2$, so that the first
decomposition is ruled out.

Let's try it out:

```shell
$ perl int-sums.pl 5
(5)
(4 1)
(3 2)
(3 1 1)
(2 2 1)
(2 1 1 1)
(1 1 1 1 1)
```

Seems to work!

[PWC108 - Bell Numbers]: {{ '/2021/04/15/pwc108-bell-numbers/' | prepend: site.baseurl }}
[Bell numbers]: https://en.wikipedia.org/wiki/Bell_number
[Bell triangle]: https://en.wikipedia.org/wiki/Bell_triangle
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
