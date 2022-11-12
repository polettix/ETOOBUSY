---
title: 'Ellipses (for SVG): transformation implementation'
type: post
tags: [ maths, svg, perl, coding ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Let's use the maths for converting from the SVG Path syntax for
> ellipses to the parametric representation, which will allow us to
> eventually calculate the bounding box.

In our previous posts:

- [Ellipses (for SVG): finding the center][]
- [Ellipses (for SVG): parameter values][]

we looked at the math for finding the equations that allow us to express
an arc of ellipse in *parametric representation* (see [Ellipses (for
SVG): parameter and angles][]) starting from what is available in the
SVG path attribute `d` (see [Ellipses (for SVG): mapping to SVG
representation][]).

Implementation time! This function provides us the *parametric
representation* parameters:

```perl
 1 sub ellipse_p2c ($P0, $P1, $R, $xdegs, $fA, $fS) {
 2    my $phi = $xdegs * PI / 180; # turn into radians
 3    my ($sinp, $cosp) = (sin($phi), cos($phi));
 4    my ($x0, $y0, $x1, $y1, $xr, $yr) = map {$_->@{qw< x y >}} ($P0, $P1, $R);
 5    my ($x0t, $y0t) = (($x0 - $x1) / 2, ($y0 - $y1) / 2);
 6    my ($x_0, $y_0) = ($cosp * $x0t + $sinp * $y0t, -$sinp * $x0t + $cosp * $y0t);
 7    my ($x2r, $y2r) = ($xr **2, $yr ** 2);
 8    my $lambda = (($x_0 / $xr)**2 + ($y_0 / $yr)**2);
 9    if ($lambda > 1) { # make it a 1 by expanding $rx and $ry with a factor
10       my $factor = sqrt($lambda);
11       ($xr, $yr) = ($xr * $factor, $yr * $factor);
12       $lambda = 1;
13    }
14    my $cf = sqrt(1 / $lambda - 1);
15    $cf = -$cf if ($fA xor $fS);
16    my ($x_c, $y_c) = (-$cf * $xr * $y_0 / $yr, $cf * $yr * $x_0 / $xr);
17    my ($xc, $yc) = ( # the center, yay!
18       ($x0 + $x1) / 2 + $cosp * $x_c - $sinp * $y_c,
19       ($y0 + $y1) / 2 + $sinp * $x_c + $cosp * $y_c,
20    );
21    my $pi2 = 2 * PI;
22    my ($t_begin, $t_end) = map {
23       atan2($xr * ($_ * $y_0 - $y_c), $yr * ($_ * $x_0 - $x_c));
24    } (1, -1);
25    $t_begin -= $pi2 if $t_begin > $t_end; # now $t_begin < $t_end
26    my $delta = $t_end - $t_begin;
27    $t_begin = $t_end             # swap if...
28       if ($delta <= PI && $fA)   # arc is short but long is required
29       || ($delta > PI && ! $fA); # arc is long but short is required
30    # adjust $t_begin in [0, 2*PI[
31    $t_begin -= floor($t_begin / $pi2) * $pi2;
32    $t_end = $t_begin + $delta;
33    return (
34       {x => $xc, y => $yc}, # center
35       {x => $xr, y => $yr}, # radii, possibly scaled up
36       $phi,                 # ellipse rotation angle
37       $t_begin,             # begining value for parameter t
38       $t_end,               # ending value for parameter t
39    );
40 }
```

Line 2 converts the rotation angle in radians (because it's originally
in degrees), so no big deal. Lines 3 and 4 calculate the sine and cosine
of this angle, which will be used extensively during the function.

Line 4 simply *unwraps* our input points $P0$ and $P1$ (corresponding to
$\mathbf{P}_1$ and $\mathbf{P}_2$ respectively, just to confuse things a
bit 🤓) and the two radii. In this function we stick to a convention
where the variable name always starts with the coordinate axis, followed
by what it is for (hence, $r_x$ becomes `$xr`).

Variables `$x_0` and `$y_0` represent the first point in the
translated-then-rotated system (line 6, with a little help from line 5).

Lines 8 through 20 deal with finding the center (see [Ellipses (for
SVG): finding the center][]). In particular, $\Lambda$ is calculated in
line 8 and radii are adjusted if needed (lines 9 through 13).

After line 13, we know that `$lambda` is not greater than $1$ so we can
take the square root in line 14 calculating the *center factor* `$cf`,
i.e. the factor that both $C'_x$ and $C'_y$ have in common. Its sign is
then adjusted according to the values of the flags (line 15).

Last, line 16 calculates $\mathbf{C'}$ and lines 17 through 20 bring it
back to the original coordinate system and give us $\mathbf{C}$.

Lines 21 through 32 deal with calculating the endpoints of the
contiguous interval $[t_{begin}, t_{end}]$ for the parameter (see
[Ellipses (for SVG): parameter values][]). It's basically a
straightforward implementation of the formulas we already discussed,
with the note that $t_{begin}$ (i.e. `$t_begin`) is shifted to live in
the interval $[0, 2\pi[$ (line 31, although this is not strictly
necessary).

This is it... we had to swat a bit for these 40 lines of code!

[Ellipses (for SVG): finding the center]: {{ '/2020/07/21/ellipses-in-svg-center' | prepend: site.baseurl }}
[Ellipses (for SVG): parameter values]: {{ '/2020/07/21/ellipses-in-svg-params' | prepend: site.baseurl }}
[Ellipses (for SVG): parameter and angles]: {{ '/2020/07/19/ellipses' | prepend: site.baseurl }}
[Ellipses (for SVG): mapping to SVG representation]: {{ '/2020/07/20/ellipses-in-svg' | prepend: site.baseurl }}
