---
title: 'SVG path bounding box: segments'
type: post
tags: [ perl, svg, bounding box ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where I start looking into the SVG path bounding box... starting
> simple.

For the simple case of a segment, we can go directly to the code:

```perl
 1 sub segment_bb ($P0, $P1) {
 2    my %r = (min => {}, max => {});
 3    for my $d (qw< x y >) {
 4       my ($p0, $p1) = ($P0->{$d}, $P1->{$d});
 5       ($r{min}{$d}, $r{max}{$d}) = ($p0 < $p1) ? ($p0, $p1) : ($p1, $p0);
 6    }
 7    return \%r;
 8 }
```

Although simple, this sets the stage also for future posts on more
complicated stuff.

The function expects to receive the two endpoints of the segments,
$\mathbf{P}_0$ and $\mathbf{P}_1$. They are represented as anonymous
hashes that have a `x` and a `y` key - probably not the most efficient
of representations... but whatever.

The algorithm is straightforward: for each of the two axes, we take the
corresponding values from the input points and assign them to the
minimum and the maximum. This results in a bounding box with the shape
of an anonymous hash with two keys (`min` and `max`), each represented
as a point with `x` and `y`.

And that's it for this!
