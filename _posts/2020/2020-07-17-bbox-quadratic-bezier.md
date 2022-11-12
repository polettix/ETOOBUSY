---
title: 'SVG path bounding box: quadratic Bézier curves'
type: post
tags: [ maths, perl, svg, bounding box, bézier ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-17 07:00:00 +0200
mathjax: mathjax
published: true
---

**TL;DR**

> SVG path bounding box for quadratic Bézier curves.

I guess that at this point the previous posts about Bézier curves start
to make a little more sense (e.g. [Extremes for Bézier curves][]), as
they provide the essential maths for calculating the bounding box.

Without further ado, here's the code:

```perl
 1 sub quadratic_bezier_bb ($P0, $P1, $P2) {
 2    my %retval = (min => {}, max => {});
 3    for my $axis (qw< x y >) {
 4       my ($p0, $p1, $p2) = map { $_->{$axis} } ($P0, $P1, $P2);
 5       my ($m_, $q_) = ($p0 - 2 * $p1 + $p2, -$p0 + $p1);
 6       my @candidates = (0, 1);
 7       if (abs($m_) > THRESHOLD) {
 8          my $t = -$q_ / $m_;
 9          push @candidates, $t if 0 <= $t && $t <= 1;
10       }
11       for my $pt (@candidates) {
12          my $mt = 1 - $pt;
13          my $v  = $mt**2 * $p0 + 2 * $pt * $mt * $p1 + $pt**2 * $p2;
14          $retval{min}{$axis} //= $retval{max}{$axis} //= $v;
15          if    ($v < $retval{min}{$axis}) { $retval{min}{$axis} = $v }
16          elsif ($v > $retval{max}{$axis}) { $retval{max}{$axis} = $v }
17       } ## end for my $pt (@candidates)
18    } ## end for my $axis (qw< x y >)
19    return \%retval;
20 } ## end sub quadratic_bezier_bb
```

The calculations are split across the X and Y axes (line 3). We first
grab all relevant coordinate values (line 4) and calculate the
associated parameters for the first derivative.

This derivative is a line, hence we calculate the *usual* parameters $m$
and $q$. Well, not *exactly* because we are neglecting a factor of $2$
from the relevant formula:

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

This is why the variables are named `$m_` and `$q_` - they're not the
real $m$ and $q$! But ignoring the $2$ is not of real harm here, because
we eventually divide them (line 8) so the two $2$ would cancel out
anyway.

Of course we consider the possible value of the parameter $t$ only if
it's within the allowed range $[0, 1]$ (line 9), then proceed to
evaluate the Bézier quadratic curve for the axis (line 13) over all
candidates, i.e. the range extremes and this possible candidate. The
rest is all about keeping the maximum and minimum (lines 15 and 16).

The output format is compatible with what described in previous posts,
so it can be used for merging with other bounding boxes as explained
in [SVG path bounding box: merge multiple boxes][].

And I guess it's everything for today!

[Extremes for Bézier curves]: {{ '/2020/07/09/bezier-extremes' | prepend: site.baseurl }}
[SVG path bounding box: merge multiple boxes]: {{ '/2020/07/15/bbox-merging' | prepend: site.baseurl }}
