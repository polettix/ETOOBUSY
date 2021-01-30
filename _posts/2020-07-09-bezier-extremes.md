---
title: Extremes for Bézier curves
type: post
tags: [ bézier, maths ]
series: Bézier curves
comment: true
date: 2020-07-09 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Using [Derivatives for Bézier curves][] to find the extreme candidates
> useful for the bounding box.

In our quest to find the *bounding box* for [Bézier curves][] (i.e. the
minimum area rectangle that has sides parallel to the coordinate axes
and that fully contains the curve) we did a step ahead in [Derivatives
for Bézier curves][], because we found a way to easily find out the
parameters of the derived polynomial.

Why the derivation? From calculus, we know that all values of $t$ where
the derivative of a function is zero are *candidate* positions for
either a minimum or a maximum. Hence, it suffices to find where the
derivative components are equal to zero and we will have candidate
values of the parameter $t$ to find the extreme points for either axes.
We will of course also make sure that these values of $t$ are
*admissible* (i.e. fall in the regular $[0,1]$ interval for it) and also
check the values at the two sides of the interval for $t$ itself.

We left [Derivatives for Bézier curves][] with this formula to calculate
the coefficients of the polynomials for the derivative in the two axes:

$$
M_{D,n} \cdot \hat{P}
$$

As anticipated, these matrices can be pre-calculated and used when
necessary upon the specific set of control points $\hat{P}$, which of
course depends on the specific Bézier curve we are considering.

The generic solution would involve finding the zeros of a polynomial
of any degree. For quadratic and cubic Béziers, instead, we are lucky
because it's very easy to find the roots.

# Quadratic Bézier curves

For *quadratic Bézier curves* this means using the following matrix:

$$
M_{D,2} = M_1 \cdot D_2
    = \begin{bmatrix}
        1 & 0 \\
        -1 & 1
    \end{bmatrix} \cdot 2 \cdot \begin{bmatrix}
        -1 & 1 & 0 \\
        0 & -1 & 1
    \end{bmatrix} \\
M_{D,2} = 2 \cdot \begin{bmatrix}
       -1 &  1 & 0 \\
        1 & -2 & 1
    \end{bmatrix}
$$

Multiplying this matrix by the matrix $\hat{P}$ obtained putting the
three control points as row vectors we end up with the following:

$$
\begin{bmatrix}
    \mathbf{q} \\
    \mathbf{m}
\end{bmatrix}
= \begin{bmatrix}
   q_x & q_y \\
   m_x & m_y
\end{bmatrix}
= 2 \cdot \begin{bmatrix}
    - \mathbf{P}_1 + \mathbf{P}_2 \\
    \mathbf{P}_1 - 2 \cdot \mathbf{P}_2 + \mathbf{P}_3
\end{bmatrix}
$$

The two row vectors $\mathbf{q}$ and $\mathbf{m}$ represent the
intercept and the angular coefficient of the derivatives for the two
components over the X and Y axes. Hence, it is trivial to find the two
candidates for the bounding box:

$$
t_x = - \frac{q_x}{m_x} \\
t_y = - \frac{q_y}{m_y} \\
$$

# Cubic Bézier curves

For *cubic Bézier curves* we have instead:

$$
M_{D,3} = M_2 \cdot D_3
    = \begin{bmatrix}
         1 &  0 & 0 \\
        -2 &  2 & 0 \\
         1 & -2 & 1 
    \end{bmatrix} \cdot 3 \cdot \begin{bmatrix}
        -1 & 1 & 0 & 0 \\
        0 & -1 & 1 & 0 \\
        0 & 0 & -1 & 1
    \end{bmatrix} \\
M_{D,3} = 3 \cdot \begin{bmatrix}
      -1 &  1 &  0 & 0 \\
       2 & -4 &  2 & 0 \\
      -1 &  3 & -3 & 1 \\
    \end{bmatrix}
$$

Again, we can multiply by the matrix of the control points and obtain:

$$
\begin{bmatrix}
    \mathbf{c} \\
    \mathbf{b} \\
    \mathbf{a}
\end{bmatrix}
= \begin{bmatrix}
   c_x & c_y \\
   b_x & b_y \\
   a_x & a_y
\end{bmatrix}
= 3 \cdot \begin{bmatrix}
    - \mathbf{P}_1 + \mathbf{P}_2 \\
    2 \cdot (\mathbf{P}_1 - 2 \cdot \mathbf{P}_2 + 1 \cdot \mathbf{P}_3) \\
    - \mathbf{P}_1 + 3 \cdot \mathbf{P}_2 -3 \cdot \mathbf{P}_3 + \mathbf{P}_4
\end{bmatrix}
$$

Here, the three row vectors $\mathbf{a}$, $\mathbf{b}$, and $\mathbf{c}$
hold the parameters for the second-degree equations that allow us to
find the zeros in the two dimensions X and Y. Note that $\mathbf{b}$
can be easily divided by $2$, so we can find the roots as follows:

$$
t_{x,12} = \frac{- \frac{b_x}{2} \pm \sqrt{\left(\frac{b_x}{2} \right)^2 - a_x \cdot c_x}}{a_x} \\
t_{y,12} = \frac{- \frac{b_y}{2} \pm \sqrt{\left(\frac{b_y}{2} \right)^2 - a_y \cdot c_y}}{a_y}
$$

[Bézier curves]: {{ '/2020/07/06/bezier-curves' | prepend: site.baseurl }}
[Derivatives for Bézier curves]: {{ '/2020/07/08/bezier-derivatives' | prepend: site.baseurl }}
[A Primer on Bézier Curves]: https://pomax.github.io/bezierinfo/
