---
title: 'Ellipses (for SVG): mapping to SVG representation'
type: post
tags: [ maths, svg ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where map ellipse's parametric representation to the one used in SVG.

In [Ellipses (for SVG): parameter and angles][] we took a quick look at
a few possible representations for an ellipse on the $XY$ plane, namely
the *implicit*, the *explicit* and the *paremetric* representations.

For our bounding box purposes, the best one is the *parametric*, because
it allows us to separate the two coordinates and find maxima and minima
independently. So, that is the representation we are aiming for. This is
also quite useful to represent *arcs of ellipses*, because it suffices
to restrict the parameter $t$ to a suitable interval (as opposed to
considering the full $[0,2\pi[$ range).

Alas, SVG paths come with a different representation for an *arc of
ellipse*, based on the following parameters:

- a *source point* $\mathbf{P}_1$ (on the ellipse);
- an *destination point* $\mathbf{P}_2$ (on the ellipse);
- the *two radii* $r_x$ and $r_y$ that we already know from our
  representations (we are lucky with them);
- a *rotation angle* (counter-clockwise) $\phi$ (same as that in our
  parametric representation, so we're lucky again but we have to
  consider that it's expressed in *degrees*);
- two *flags* (taking values of either $0$ or $1$) to indicate:
    - $f_A$ which ellipse should be chosen (the equations usually allow
      two distinct ellipses, which are mirror images with respect to a
      line through $\mathbf{P}_1$ and $\mathbf{P}_2$);
    - $f_S$ which arc between $\mathbf{P}_1$ and $\mathbf{P}_2$ should
      be considered (i.e. the longer or the shorter one).

So, starting from the parameters above, we have the goal to find:

- the *center* of the ellipse $\mathbf{C}$;
- the parameter $t_1$ corresponding to point $\mathbf{P}_1$;
- the parameter $t_2$ corresponding to point $\mathbf{P}_2$;
- the parameters $t_{begin}$ and $t_{end}$ from $t_1$ and $t_2$ so that
  $[t_{begin}, t_{end}]$ is a contiguous interval representing the arc
  of ellipse we are after.

As you might have already guessed, our next move when we have these
parameters will be to find the minimum and maximum values for the two
coordinates when $t$ varies in the $[t_{begin}, t_{end}]$ range, and
this will give us the bounding box.

Stay tuned!

[Ellipses (for SVG): parameter and angles]: {{ '/2020/07/19/ellipses' | prepend: site.baseurl }}
