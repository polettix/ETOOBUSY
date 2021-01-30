---
title: 'Ellipses (for SVG): parameter values'
type: post
tags: [ maths, svg ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> After the center (see [Ellipses (for SVG): finding the center][]),
> it's time to find the values for $t$ that represent our arc of
> ellipse.

Last post was a bit of a roller-coaster to find the center of the
ellipse. Now we're going to find the parameters values, but this is
definitely easier at this point.

If we go back to the translated-then-rotated representation, i.e. the
one centered in $\mathbf{C'}$, we can easily translate the origin on the
center and obtain:

$$
\mathbf{P''_1} = (x''_1, y''_1) = (x'_1 - C'_x, y'_1 - C'_y) \\
\mathbf{P''_2} = (x''_2, y''_2) = (-x'_1 - C'_x, -y'_1 - C'_y) \\
$$

Remember: in the first translation, the origin was put in the midpoint
of $\mathbf{P}_1$ and $\mathbf{P}_2$, so they happen to have opposite
coordinate values.

These are all known quantities at this point. To find the respective
values of $t$, we remember that this is the angle of the point
corresponding to re-normalizing the ellipse back to a unitary circle,
so for $t_1$ we have:

$$
cos(t_1) = \frac{x''_1}{r_x} = \frac{x'_1 - C'_x}{r_x} \\
sin(t_1) = \frac{y''_1}{r_y} = \frac{y'_1 - C'_y}{r_y}
$$

This will allow us to find the right value of $t_1$. Many programming
languages provide the [`atan2`][] function, which takes *two* parameters
(in the $Y'$ and $X'$ direction, in our case) and avoids infinites, so
we can calculate $t_1$ as:

$$
t_1 = atan2(\frac{y'_1 - C'_y}{r_y}, \frac{x'_1 - C'_x}{r_x})
$$

Of course the `atan2` function does not complain if we scale both
arguments by the same factor, so we can use the equivalent expression:

$$
t_1 = atan2(r_x \cdot (y'_1 - C'_y), r_y \cdot (x'_1 - C'_x))
$$

The same goes for $t_2$, of course:

$$
t_2 = atan2(r_x \cdot (-y'_1 - C'_y), r_y \cdot (-x'_1 - C'_x))
$$

Now we have that $t_1$ and $t_2$ are values in the interval $]-\pi, \pi]$,
and we have to:

- establish which comes first and which second (based on which arc of
  the ellipse we are interested into);
- find an equivalent *contiguous* range.

This is basically finding $t_{begin}$ and $t_{end}$. We can do like
this:

- initialize $t_{begin} = t_1$ and $t_{end} = t_2$;
- make sure that $t_{begin}$ is not greater $t_{end}$. To do this, we
  subtract $2\pi$ from $t_{begin}$ if it is greater than $t_{end}$:

$$
t_{begin} > t_{end} \Rightarrow t_{begin} \leftarrow t_{begin} - 2\pi
$$


- at this point, we can campute $\delta = t_{end} - t_{begin}$ and
  assign to $t_{begin}$ the value of $t_{end}$ in either of the
  following cases:
    - $\delta \le \pi$ (i.e. it's the *short* arc of ellipse) but $f_A =
      1$ (i.e. we need the long one), OR
    - $\delta > \pi$ (i.e. it's the *long* arc of ellipse) but $f_A = 0$
      (i.e. we need the short one).
- shift $t_{begin}$ in a range we like (e.g. $[0, 2\pi[$), if we want;
- last, re-calculate $t_{end} = t_{begin} + \delta$

Now we have a contiguos interval $[t_{begin}, t_{end}]$ that allows us
sweep the whole arc.

> The sweeping in this interval might make your *pen* start from the
> end point $\mathbf{P}_2$ and go back to $\mathbf{P}_1$. As we are
> eventually interested into the bounding box, anyway, this is not an
> issue here.

Problem solved... theoretically, stay tuned for the implementation!

[Ellipses (for SVG): finding the center]: {{ '/2020/07/21/ellipses-in-svg-center' | prepend: site.baseurl }}
[`atan2`]: https://en.wikipedia.org/wiki/Atan2
