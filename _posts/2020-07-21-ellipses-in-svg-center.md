---
title: 'Ellipses (for SVG): finding the center'
type: post
tags: [ maths, svg ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Our first step will be finding the ellipse's center from the SVG
> representation of the ellipse.

As anticipated, [Appendix B][] of the proposed standard already contains
all needed maths for our purposes, we'll just elaborate a bit to explain
a few passages. In particular, we will start from [Conversion from
endpoint to center parametrization][].

The first move is to translate our coordinates system to the *midpoint*
between our known points $\mathbf{P}_1$ and $\mathbf{P}_2$. Why does
this simplify the equations?

After the translation, the two points will be at opposite ends of the
new origin. For this reason, their coordinates will be equal in absolute
value, and opposite in sign. This basically means dealing with two less
values (there's only some fiddling with signs) and get way simpler
equations.

After this translation, a rotation is performed to set a new coordinates
system that as the new $X'$ axis parallel to the *x* direction in the
ellipse. This means that our new coordinates system is rotated by $\phi$
with respect to the old one. Note that this rotation does not change the
relative position of $\mathbf{P}_1$ and $\mathbf{P}_2$: they still land
on opposite places with respect to the origin, so the property in the
previous paragraph are preserved.

After this translation-then-rotation, we end up with the following new
coordinates for the two points:

$$
x'_1 = -x'_2 =  cos(\phi) \cdot \frac{x_1 - x_2}{2} + sin(\phi)\frac{y_1 - y_2}{2} \\
y'_1 = -y'_2 = - sin(\phi) \cdot \frac{x_1 - x_2}{2} + cos(\phi)\frac{y_1 - y_2}{2} \\
$$

These two points belong to the ellipse, so they have to fit in any of
the representation. Let's use the implicit one and put the values for
the new point $\mathbf{P}'_1$, considering that our ellipse is
centered in $\mathbf{C}'$ in the new coordinate system (we will go back
later, don't worry!):

$$
\frac{(x'_1 - C'_x)^2}{r_x^2} + \frac{(y'_1 - C'_y)^2}{r_y^2} = 1
$$

Let's multiply both ends by $r_x^2\cdot r_y^2$ and expand the two
squares on the numerators of the fractions:

$$
  r_y^2 \cdot {x'_1}^2 - 2 \cdot r_y^2 \cdot x'_1 \cdot C'_x + r_y^2 \cdot {C'_x}^2
+ r_x^2 \cdot {y'_1}^2 - 2 \cdot r_x^2 \cdot y'_1 \cdot C'_y + r_x^2 \cdot {C'_y}^2
= r_x^2 \cdot r_y^2
$$

Let's not proceed for $\mathbf{P}_2$:

$$
\frac{(-x'_1 - C'_x)^2}{r_x^2} + \frac{(-y'_1 - C'_y)^2}{r_y^2} = 1 \\
\frac{(x'_1 + C'_x)^2}{r_x^2} + \frac{(y'_1 + C'_y)^2}{r_y^2} = 1
$$

They are the same equations as before, only with a change of sign, so we
get:

$$
  r_y^2 \cdot {x'_1}^2 + 2 \cdot r_y^2 \cdot x'_1 \cdot C'_x + r_y^2 \cdot {C'_x}^2
+ r_x^2 \cdot {y'_1}^2 + 2 \cdot r_x^2 \cdot y'_1 \cdot C'_y + r_x^2 \cdot {C'_y}^2
= r_x^2 \cdot r_y^2
$$

How about subtracting the first expansion from te one above? A lot of
terms cancel out, leaving us with:

$$
  4 \cdot r_y^2 \cdot x'_1 \cdot C'_x + 4 \cdot r_x^2 \cdot y'_1 \cdot C'_y = 0  \\
          r_y^2 \cdot x'_1 \cdot C'_x +         r_x^2 \cdot y'_1 \cdot C'_y = 0  \\
    C'_y = -\frac{r_y^2}{r_x^2} \cdot \frac{x'_1}{y'_1} \cdot C'_x  \\
    {C'_y}^2 = \frac{r_y^4}{r_x^4} \cdot \frac{ {x'_1}^2}{ {y'_1}^2} \cdot {C'_x}^2
$$

Now we can substitute this in any of the two starting equations and get
a second-degree equation in $C'_x$ only:

$$
  r_y^2 \cdot {x'_1}^2 - 2 \cdot r_y^2 \cdot x'_1 \cdot C'_x + r_y^2 \cdot {C'_x}^2
+ r_x^2 \cdot {y'_1}^2 - 2 \cdot r_x^2 \cdot y'_1 \cdot C'_y + r_x^2 \cdot {C'_y}^2
= r_x^2 \cdot r_y^2 \\

  r_y^2 \cdot {x'_1}^2 - 2 \cdot r_y^2 \cdot x'_1 \cdot C'_x + r_y^2 \cdot {C'_x}^2
+ r_x^2 \cdot {y'_1}^2 + 2 \cdot r_y^2 \cdot x'_1 \cdot C'_x + 
        r_y^2 \cdot \frac{r_y^2}{r_x^2} \cdot \frac{ {x'_1}^2 }{ {y'_1}^2 } {C'_x}^2 
= r_x^2 \cdot r_y^2 \\


  r_y^2 \cdot \left(\frac{r_x^2\cdot{y'_1}^2 + r_y^2\cdot{x'_1}^2}{r_x^2\cdot{y'_1}^2} \right) \cdot {C'_x}^2
= r_x^2 \cdot r_y^2 - (r_x^2\cdot{y'_1}^2 + r_y^2\cdot{x'_1}^2) \\

{C'_x}^2
= \frac{r_x^2 \cdot r_y^2 - (r_x^2\cdot{y'_1}^2 + r_y^2\cdot{x'_1}^2)}{r_x^2\cdot{y'_1}^2 + r_y^2\cdot{x'_1}^2}
    \cdot \frac{r_x^2}{r_y^2} \cdot {y'_1}^2 \\

{C'_x}^2
= \left(\frac{1}{\left( \frac{x'_1}{r_x} \right)^2 + \left( \frac{y'_1}{r_y} \right)^2 } - 1 \right)
    \cdot \left( \frac{r_x}{r_y} \cdot y'_1 \right)^2
$$

Similarly, we find the following for ${C'_y}^2$:

$$
{C'_y}^2
= \left(\frac{1}{\left( \frac{x'_1}{r_x} \right)^2 + \left( \frac{y'_1}{r_y} \right)^2 } - 1 \right)
    \cdot \left( \frac{r_y}{r_x} \cdot x'_1 \right)^2
$$

We have to take a square root at this point... is it safe?


# Ensuring that the solution is Real

Let's call:

$$
\Lambda = \left( \frac{x'_1}{r_x} \right)^2 + \left( \frac{y'_1}{r_y} \right)^2
$$

We can easily see that values of $\Lambda$ greater than $1$ will give us
trouble, because our squared coordinates for the center would become
*negative*, yielding non-Real values for the center's coordinates.

At this point, the standard tells us to *enlarge* the ellipse (keeping
the aspect ratio) until it's necessary, i.e. until our $\Lambda$ goes
down to exactly $1$. This means multiplying both $r_x$ and $r_y$ by a
factor $k so that the following applies:

$$
1 = \left( \frac{x'_1}{k \cdot r_x} \right)^2 + \left( \frac{y'_1}{k \cdot r_y} \right)^2 \\
k^2 = \left( \frac{x'_1}{r_x} \right)^2 + \left( \frac{y'_1}{r_y} \right)^2 = \Lambda \\
k = \sqrt{\Lambda} \\
r_x \leftarrow \sqrt{\Lambda} \cdot r_x \\
r_y \leftarrow \sqrt{\Lambda} \cdot r_y \\
$$

which is exactly what is suggested in section [Correction of
out-of-range radii][]. This might happen, most probably, due to some
numerical approximation, so the value of the correction should not be
too big.

> **CAVEAT** the group of transformations above only applies when
> $\Lambda > 1$, it should be ignored otherwise!

# The much sought result

Let's calculate (again):

$$
\Lambda = \left( \frac{x'_1}{r_x} \right)^2 + \left( \frac{y'_1}{r_y} \right)^2
$$

After the check in the previous section, we're now sure that $\Lambda
\le 1 $, so it's safe to take the square roots.

For reasons that are left as a simple exercise for the reader (i.e. I'm
too bored to look at), we have to take opposite signs for the two
coordinates, i.e.:

$$
C'_x = \pm \sqrt{\frac{1}{\Lambda} - 1} \cdot \frac{r_x}{r_y} \cdot y'_1 \\
C'_y = \mp \sqrt{\frac{1}{\Lambda} - 1} \cdot \frac{r_y}{r_x} \cdot x'_1
$$

Whether we have to take the upper or the lower sign depends on the
*flags*. In particular, if $f_A \ne f_S$ then we take the upper sign
(positive for the $X$ coordinate, negative for the $Y$ coordinate),
otherwise we take the lower one.

The last thing to do is to go back to our original coordinates system,
i.e. revert the rotation and then the translation. We obtain:

$$
C_x = \frac{x_1 + x_2}{2} + cos(\phi) \cdot C'_x - sin(\phi) \cdot C'_y \\
C_y = \frac{y_1 + y_2}{2} + sin(\phi) \cdot C'_x + cos(\phi) \cdot C'_y
$$

So... we are done with the center, next time we will address the
parameters - but it will be easier.

*Hopefully*.

[Appendix B]: https://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
[Conversion from endpoint to center parametrization]: https://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
[Correction of out-of-range radii]: https://www.w3.org/TR/SVG/implnote.html#ArcCorrectionOutOfRangeRadii
