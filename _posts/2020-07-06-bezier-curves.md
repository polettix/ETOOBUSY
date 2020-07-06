---
title: Bézier curves
type: post
tags: [ maths, bézier ]
comment: true
date: 2020-07-06 19:23:37 +0200
mathjax: true
published: true
---

**TL;DR**

> Where I re-discover a useful source for information, and that
> contributions might get lost.

For reasons that will hopefully be clear in a few days, I'm taking
(again) a look at [Bézier curves][]. There's an excellent resource about
them online, namely [A Primer on Bézier Curves][].

But... wait a minute! I already knew this place from before, because...
I actually [contributed to it][] about five years ago (I still have an
[oline version of the old site][old-site]). Alas, in the meantime it
underwent some re-writing, and it seems that my old contribution got
lost 🤔

The contribution was actually a minor one, but it was enough to tickle
the not-so-little nit-picker in me at the time. In section [Splitting
curves using matrices][] there is:

> [...] the new end point is a mixture that looks oddly similar to a
> Bernstein polynomial of degree two

and my point is that *the new end point **is** a Bernstein polynomial*.

The key in this insight is that $z$ is actually the free variable in the
parametric equations, which ranges in $[0,1]$. For this reason, $(z-1)$
is better expressed as $-(1-z)$, because it gives you an immediate view
of what's the real sign of the expression.

For this reason, then, the following expression:

$$ z^2 \cdot P_3 - 2 \cdot z \cdot (z-1) \cdot P_2 + (z - 1)^2 \cdot P_1 $$

is best put as:

$$ (1-z)^2 \cdot P_1 + 2 \cdot (1-z) \cdot z \cdot P_2 + z^2 \cdot P_3 $$

which also reveals its... **Bernstein** nature.

So there you have it... **I know** (where to find info on) **Bézier
curves**! (And now you do too).

[Bézier curves]: https://en.wikipedia.org/wiki/B%C3%A9zier_curve
[A Primer on Bézier Curves]: https://pomax.github.io/bezierinfo/
[contributed to it]: https://github.com/Pomax/bezierinfo/pull/64
[Splitting curves using matrices]: https://pomax.github.io/bezierinfo/#matrixsplit
[old-site]: https://github.polettix.it/bezierinfo/
