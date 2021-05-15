---
title: Double Dobble - easy optimization
type: post
tags: [ maths, dobble, double dobble ]
series: Double Dobble
comment: true
date: 2021-05-15 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> A quick optimization over the quest for [Double Dobble][]
> arrangements.

In previous post [Quest for Double Dobbles][] I described a possible
approach to finding [Double Dobble][]s, with all the limitations.

One observation that allowed me to reduce the search time was that it's
fine to always assume that the first index is $0$. Thanks to the
rotation invariance, we can rotate any arrangement and make it so the
first index is $0$.

It occurred to me that a similar reasoning can be also done to fix the
following index to always be $1$. It works like this:

- the difference $1$ MUST appear exactly twice in a valid arrangement;
- hence, *at least* two indexes MUST be adjacent (modulo $N$);
- if we apply a rotation over this arrangement to put the one *on the
  left* at index $0$, the other one goes into index $1$.

Hence, our iterator for possible combinations becomes this:

```perl
my $it = NestedLoops(
   [
      [0], [1],
      map {
         my $end = $N - 1 - ($k - 1) + $_;
         sub { [($_ + 1) .. $end] },
      } (2 .. $k - 1)
   ]
);
```

which brings us down to ${N - 2} \choose {k - 2}$ possible combination
to look through.

For values of $k$ that indeed have a solution, this is not an
improvement. I mean, if there is a viable arrangement, the variant
starting with $(0, 1, ...)$ will be checked before all the others
anyway.

The optimization comes handy when trying out values of $k$ that *do not*
have a solution:

```shell
$ time perl old-code.pl 8

real	0m17.382s
user	0m17.040s
sys	0m0.096s

$ time perl new-code.pl 8

real	0m4.126s
user	0m4.088s
sys	0m0.008s
```

I suspect that there may be other *low-hanging fruits* to further
enhance the search... who knows?!?

[Quest for Double Dobbles]: {{ '/2021/05/14/double-dobble-search/' | prepend: site.baseurl }}
[Double Dobble]: https://aperiodical.com/2020/05/the-big-lock-down-math-off-match-22/
