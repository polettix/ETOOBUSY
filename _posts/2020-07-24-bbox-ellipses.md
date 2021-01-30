---
title: 'SVG path bounding box: arcs of ellipses'
type: post
tags: [ maths, perl, svg, bounding box, bézier ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-24 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Let's take a look at the bounding box for arcs of ellipses, at the
> very last!

In the previous post [Ellipses (for SVG): transformation
implementation][] we saw the implementation of a function to turn the
representation of an arc of ellipse inside a SVG path (based on the two
endpoints and other parameters) to a more *tractable* representation
(the *parametric representation*, in particular) for finding the
*bounding box*.

So, we have a representation (from [Ellipses (for SVG): parameter and angles][]):

$$
x(t) = C_x + cos(\phi) \cdot r_x \cdot cos(t) - sin(\phi) \cdot r_y \cdot sin(t) \\
y(t) = C_y + sin(\phi) \cdot r_x \cdot cos(t) + cos(\phi) \cdot r_y \cdot sin(t)
$$

and we also have all the needed parameters, including a contiguous range
for the parameter $t$... we can move on towards the bounding box!

# Maxima and minima

As before with Bézier curves 
(see [SVG path bounding box: quadratic Bézier curves][]
and [SVG path bounding box: cubic Bézier curves][])
we can treat the two axes independently and use the derivatives to find
the candidate values of $t$ that might yield us maxima or minima in the
required interval.

The two derivatives are:

$$
\dot{x}(t) = - cos(\phi) \cdot r_x \cdot sin(t) - sin(\phi) \cdot r_y \cdot cos(t) \\
\dot{y}(t) = - sin(\phi) \cdot r_x \cdot sin(t) + cos(\phi) \cdot r_y \cdot cos(t)
$$

Finding the zero for the $X$ coordinate means finding $t$ such that:

$$
cos(\phi) \cdot r_x \cdot sin(t) = - sin(\phi) \cdot r_y \cdot cos(t)
$$

We can find this with the help of [`atan2`][]:

$$
t_{x,1} = atan2(-sin(\phi) \cdot r_y, cos(\phi) \cdot r_x)
$$

Note that there is also another candidate that is spaced $\pi$ apart:

$$
t_{x,2} = t_{x,1} + \pi
$$

Both these two candidates also have equivalents that are spaced by
multiples of $2\pi$, of course. We should find the two equivalents that
are closer to $t_{begin}$ and greater than it, then check if the
actually fall in the $[t_{begin}, t_{end}]$ interval; if any of them
does, then it must be considered for the bounding box evaluation.

Similar equations and reasoning can be done for the $Y$ axis, of course.

# Implementation

On to the implementation:

```text
 1 sub ellipse_bb ($C, $R, $phi, $t_start, $t_end) {
 2    my %retval = (min => {}, max => {});
 3    my $pi2 = 2 * PI;
 4    $_ -= floor($_ / $pi2) * $pi2 for ($t_start, $t_end);
 5    $t_end += $pi2 if $t_end < $t_start;
 6 
 7    # align to a sane range, might be improved...
 8    my ($Rx, $Ry, $cosp, $sinp) = ($R->{x}, $R->{y}, cos($phi), sin($phi));
 9    for my $axis (qw< x y >) {
10       my @candidates = ($t_start, $t_end);
11       my $theta = atan2(-$Ry * $sinp, $Rx * $cosp);
12       for (1 .. 2) {
13          $theta -= floor($theta / $pi2) * $pi2; # normale
14          $theta += $pi2 if $theta < $t_start;  # try to fit in range
15          push @candidates, $theta if $theta < $t_end;
16          $theta += PI; # prepare for 2nd iteration
17       }
18 
19       for my $theta (@candidates) {
20          my $v = $C->{$axis} +
21             $Rx * $cosp * cos($theta) +
22             $Ry * $sinp * sin($theta);
23          $retval{min}{$axis} //= $retval{max}{$axis} //= $v;
24          if    ($v < $retval{min}{$axis}) { $retval{min}{$axis} = $v }
25          elsif ($v > $retval{max}{$axis}) { $retval{max}{$axis} = $v }
26       }
27 
28       ($cosp, $sinp) = (-$sinp, $cosp); # prepare for y-iteration
29    }
30    return \%retval;
31 }
```

Lines 3 through 5 re-normalize the interval putting $t_{begin}$ inside
$[0, 2\pi[$ and $t_{end}$ *immediately* after it.

The two axes are treated separately (line 9), just like we did for
Bézier curves. Our candidates for finding the minima and maxima start
with our endpoints (line 10), then we calculate $t_1$ using [`atan2`][]
(line 11) and establish whether it or its $\pi$-spaced sibling fall in
the interval (lines 12 through 17).

Lines 19 through 26 take care to evaluate the parametric function in the
candidate values for $t$ and update the bounding box accordingly.

Line 28 is... peculiar. To reuse the same exact formulas of the $X$ axis
also for the $Y$ axis, it's sufficient to do the indicating swapping...
cool, this saves us a lot of cut-and-paste!

# Conclusions

We now have the last missing piece in our quest for the bounding box of
a SVG path... it's been funny, hasn't it?!? 🤓

[Ellipses (for SVG): transformation implementation]: {{ '/2020/07/23/ellipses-in-svg-transformation' | prepend: site.baseurl }}
[Ellipses (for SVG): parameter and angles]: {{ '/2020/07/19/ellipses' | prepend: site.baseurl }}
[SVG path bounding box: quadratic Bézier curves]: {{ '/2020/07/17/bbox-quadratic-bezier' | prepend: site.baseurl }}
[SVG path bounding box: cubic Bézier curves]: {{ '/2020/07/18/bbox-cubic-bezier' | prepend: site.baseurl }}
[`atan2`]: https://en.wikipedia.org/wiki/Atan2
