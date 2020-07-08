---
title: Derivatives of Bézier curves
type: post
tags: [ bézier, maths ]
comment: true
date: 2020-07-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> It's easy to calculate derivatives of [Bézier curves][] (they're other
> Bézier curves).

In [Bézier curves][] we got a look at a great resource for learning
about these curves: [A Primer on Bézier Curves][].

It includes hints on how to calculate the bounding box (parallel to the
coordinate axes), leveraging the derivatives. Good! Although... I found
it a bit too dispersive to follow.

Main take-aways:

- the derivative of an $n$-degree Bézier curve is an $n-1$-degree Bézier
  curve;
- it's easy to find the control point from the $n$ to the $n-1$ degree
  derivative;
- if you need the derivatives to find the zero-crossing for the maxima
  and minima, there's a very quick way to do it with matrices.

The first bullet is explained thoroughly in the linked article, so I
will not bother you here.

The other two bullets are somehow complementary. Either you need the
derivative *per-se*, or most probably you need it to find the zeroes for
the maxima and minima within the boundary for the parameter $t$ (which
is why, in my opinion, there's no need to bother with the second
derivative).

The second bullet can be summarized as follows (again, see the article
for the details). The $i$-th control point $Q_i$ of the derivative can
be found from the control points of the starting $n$-degree Bézier curve
as follow:

$$ Q_i = n \cdot (P_{i+1} - P_i)$$

for $i$ that spans from $1$ to $n$ (because the derivative has one
degree less, hence one control point less).

This can be expressed in matrix form:

$$ \hat{Q} = D_n \cdot \hat{P} $$

where $D_n$ is a $n \times (n+1)$ matrix that expresses the difference
between two consecutive items, diagonally:

$$
D_n = n \cdot \begin{bmatrix}
-1 & 1 & 0 & \cdots & 0 & 0 & 0 \\
0 & -1 & 1 & \cdots & 0 & 0 & 0 \\
\vdots & \vdots & \vdots & \ddots & \cdots & \cdots & \cdots \\
0 & 0 & 0 & \vdots & -1 & 1 & 0 \\
0 & 0 & 0 & \vdots & 0 & -1 & 1
\end{bmatrix}
$$

This can be pre-combined with the matrix for the $n-1$-degree Bézier
curve, which yields:

$$
M_{D,n} = M_{n-1} \cdot D_n
$$

and this matrix can be used to find the parameters for the parametric
components in the X and Y axes *by multiplying it directy times the
control points of the original Bézier curve:

$$
M_{D,n} \cdot \hat{P}
$$

Hence the whole thing boils down to:

- pre-calculate $M_{D,n}$ for the values of $n$ we are interested into
  (usually 2 and 3), once and for all;
- multiply it times the control points matrix $\hat{P}$, yielding a $n
  \times 2$ matrix whose columns are the two derivatives for the X and Y
  axes
- zero them and find the *candidate* extremes for the bounding box.

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


[Bézier curves]: {{ '/2020/07/06/bezier-curves' | prepend: site.baseurl }}
[A Primer on Bézier Curves]: https://pomax.github.io/bezierinfo/
