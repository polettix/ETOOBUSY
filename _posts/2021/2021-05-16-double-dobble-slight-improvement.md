---
title: Double Dobble - slight improvement
type: post
tags: [ maths, dobble, double dobble ]
series: Double Dobble
comment: true
date: 2021-05-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Chipping away some more time in the search for [Double Dobble][]
> arrangements!

After writing [Double Dobble - easy optimization][], my brain remained
thinking if there was any *further* low-hanging fruit to gather. I mean,
I know that I haven't exploited the symmetry in the solutions... but
it's mainly because my *gut feeling* is that it would take a lot of time
and I'm not sure how much this might improve the situation.

On the other hand... low hanging fruits are so sweet! 🙄

And there it is!

Just like any valid arrangement MUST contain two indexes that are
adjacent, then it MUST *also* contain two indexes that are two-spaced
apart, thanks to the *double-dobble-ness* nature of the problem.

Confused? Let's see...

The difference of $2$ must occur twice, just like any other difference.
Fact is, anyway, that it's a difference of *any index* with respect to
*any other index*. So, for example, the following arrangement contains
one delta of $2$ even if there are no two-spaced indexes:

$$(0, 1, 2, ...)$$

You see? Index $2$ is spaced from index $0$ by... $2$ spaces.

But.

We're looking for [Double Dobble][]s, right? This means that the
difference of $2$ MUST occur somewhere else. Now there are two cases:

- there are indeed two indexes that are spaced by two, like $(..., x, x
  + 2, ...)$ - yay!

- we have a new triplet like $(..., x, x + 1, x + 2)$. This cannot
  happen in a *valid* arrangement for [Double Dobble][], because it
  would imply that the distance-by-$1$ occurs *four times*:

$$
1 - 0 = 1
2 - 1 = 1
(x + 1) - x = 1
(x + 2) - (x + 1) = 1
$$

So... the spacing-by-$2$ MUST indeed occur! New iterator definition for
us:

```perl
my $it = NestedLoops(
   [
      [0], [2],
      map {
         my $end = $N - 1 - ($k - 1) + $_;
         sub { [($_ + 1) .. $end] },
      } (2 .. $k - 1)
   ]
);
```

Not only this brings us down to ${N - 3} \choose {k - 2}$ for
*exhaustive searches*:

```shell
$ time perl old-code.pl 8

real	0m4.126s
user	0m4.088s
sys	0m0.008s

$ time perl new-code 8

real	0m3.379s
user	0m3.368s
sys	0m0.004s
```

but it might also help finding valid arrangements when they are
possible:

```shell
$ time perl old-code.pl 9
(0 1 3 7 17 24 25 29 35)

real	0m28.675s
user	0m28.544s
sys	0m0.068s

$ time perl new-code 9
(0 2 3 5 9 19 26 27 31)

real	0m4.260s
user	0m4.220s
sys	0m0.016s
```

Not bad!

Last, I tried to actually implement a *sieve* to pre-cache the result
for all possible variants of a specific sequence. Well... either I
didn't code it well, or the amount of work required to do this
generate-then-cache is comparable with the work to do a straight check
on a new sequence, because the times I got (up to generating all
possible arrangements with $k = 9$) were *slightly* worse than the
results above.

Stay safe!

[Double Dobble - easy optimization]: {{ '/2021/05/15/double-dobble-easy-optimization/' | prepend: site.baseurl }}
