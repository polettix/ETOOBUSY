---
title: 'SVG path bounding box: cubic Bézier curves'
type: post
tags: [ maths, perl, svg, bounding box, bézier ]
comment: true
date: 2020-07-18 07:00:00 +0200
mathjax: mathjax
published: true
---

**TL;DR**

> SVG path bounding box for cubic Bézier curves.

I guess you saw it coming.

After describing the [SVG path bounding box: quadratic Bézier curves][],
it's about time to move on to the cubic Bézier curves:

```perl
 1 sub cubic_bezier_bb ($P0, $P1, $P2, $P3) {
 2    my %retval = (min => {}, max => {});
 3    for my $axis (qw< x y >) {
 4       my ($p0, $p1, $p2, $p3) = map { $_->{$axis} } ($P0, $P1, $P2, $P3);
 5       my ($a_, $b2_, $c_) = (    # a, c divided by 3, b divided by -6
 6          -$p0 + 3 * $p1 - 3 * $p2 + $p3,
 7          $p0 - 2 * $p1 + $p2,
 8          -$p0 + $p1
 9       );
10       my @candidates = (0, 1);
11       my $det = $b2_**2 - $a_ * $c_;    # (b/2)^2 - ac
12       if (abs($det) > THRESHOLD && abs($a_) > THRESHOLD) {
13          my $sdet = sqrt($det);
14          for my $s ($sdet, -$sdet) {
15             my $t = (-$b2_ + $s) / $a_;
16             push @candidates, $t if 0 <= $t && $t <= 1;
17          }
18       } ## end if (abs($det) > THRESHOLD...)
19       for my $pt (@candidates) {
20          my $mt = 1 - $pt;
21          my $v =
22            $mt**3 * $p0 +
23            3 * $mt**2 * $pt * $p1 +
24            3 * $mt * $pt**2 * $p2 +
25            $pt**3 * $p3;
26          $retval{min}{$axis} //= $retval{max}{$axis} //= $v;
27          if    ($v < $retval{min}{$axis}) { $retval{min}{$axis} = $v }
28          elsif ($v > $retval{max}{$axis}) { $retval{max}{$axis} = $v }
29       } ## end for my $pt (@candidates)
30    } ## end for my $axis (qw< x y >)
31    return \%retval;
32 } ## end sub cubic_bezier_bb
```

There is nothing *really* different from the previous post, actually: we
still go through the axes separately (line 3) and take all relevant
values in that direction (line 4), only we work with different
parameters for the derivative, that is now a second-degree equation with
parameters $a$, $b$, and $c$ (lines 5 to 9).

As before, we're not using the *actual* values that would come from the
relevant equation:

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

We're disregarding the $3$ (we're after the zeros, so it can be canceled
out) and we're also using the *simplified* form for the roots of a
second-degree polynomial, so we're leveraging $\frac{b}{2}$, which is
easily calculated because the formula for $b$ above has a factor 2 that
can be ignored:

$$
t_{\pm} = \frac{-\frac{b}{2} \pm \sqrt{\left(\frac{b}{2}\right)^2 - a \cdot c}}{a}
$$

Just to be paranoid, we take into account possible numerical
instabilities and ignore the solution if the determinant is too low
(lines 11 and 12); otherwise, it's pretty much the same approach as that
for [quadratic curves][SVG path bounding box: quadratic Bézier curves].

[SVG path bounding box: quadratic Bézier curves]: {{ '/2020/07/17/bbox-quadratic-bezier' | prepend: site.baseurl }}
