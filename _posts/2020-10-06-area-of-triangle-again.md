---
title: Area of a triangle, again
type: post
tags: [ maths, geometry, computational geometry, perl ]
comment: true
date: 2020-10-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> How the triangle's area should be really calculated.

In [Area of a triangle][] I described a way to calculate the area of a
triangle with a formula that I "derived myself" - in the sense that I
wanted to solve that problem and used my past maths knowledge. This is
what I ended up with:

$$
S = \frac{
        \sqrt{
            (\vec{v}\cdot\vec{v})\cdot(\vec{w}\cdot\vec{w})
            - (\vec{v}\cdot\vec{w})\cdot(\vec{v}\cdot\vec{w})
        }
    }{2}
$$

It turns out that the world consistently beats (most of) us, so I found
[Area of Triangles and Polygons][] that provides this instead:

$$
S' = \frac{v_x \cdot w_y - v_y \cdot w_x}{2} \\
S = |S'|
$$

This is so amazing and superior:

- no square roots, how cool can that be?
- the result is *signed*, which gives us an idea of whether $\vec{v}$ is
  on the "right" or the "left" of $\vec{w}$, which might come handy.

Awesome! So... code time again (I also played a bit with the inputs to
cut one line out):

```perl
sub triangle_area {
    my ($v_x, $v_y) = ($_[1][0] - $_[0][0], $_[1][1] - $_[0][1]);
    my ($w_x, $w_y) = ($_[2][0] - $_[0][0], $_[2][1] - $_[0][1]);
    return ($v_x * $w_y - $v_y * $w_x) / 2;
}
```

[Area of a triangle]: {{ '/2020/10/01/area-of-triangle/' | prepend: site.baseurl }}
[Area of Triangles and Polygons]: http://geomalgorithms.com/a01-_area.html
