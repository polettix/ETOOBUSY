---
title: Gnuplot Parametric Mix
type: post
tags: [ gnuplot, graphics, coding ]
comment: true
date: 2020-03-03 08:00:00 +0100
preview: true
---

**TL;DR**

> Where I wanted to generate different PNG files with [Gnuplot][], each
> corresponding to a different *mix* of two functions, parametrically.

For a future post (I hope), I wanted to generate different images for
showing the transition from the *linear* space to the *transformed*
space in [Fortune's algorithm][] (see also the [other post][]). And I
wanted to use [Gnuplot][].

My first step has been to make the [Gnuplot][] script parametric, which
is easy:

```
 1 #!/usr/bin/env gnuplot
 2
 3 # Mathematics
 4 Ax = 0
 5 Ay = 0
 6 m = 0.9
 7 q = -1.0
 8 line(x) = m * x + q
 9 dist(x) = sqrt((Ax - x)**2 + (Ay - line(x))**2)
10 hyperb(x) = line(x) + dist(x)
11 r = (0.0 + n) / N
12 mix(x) = (1 - r) * line(x) + r * hyperb(x)
13
14 # Graphics
15 reset
16 set terminal pngcairo size 410,250 enhanced font 'Verdana,9'
17 set output filename
18 set style line 1 lc rgb 'red'  lw 2
19 set style line 2 lc rgb 'blue' pt 7
20 set key off
21 set yrange [-2:1.2]
22
23 ## Draw point
24 set label at Ax, Ay "A" point ls 2
25
26 ## Draw mix
27 plot [-1:1] mix(x) t 'mix' ls 1
```

[Local version][] (without line numbers!).

As indicated by the comments, the first section (lines 4 through 12)
include the mathematics for the curves and their mix:

- lines 4 through 7 include the parameters for the `A` point (via `Ax`
  and `Ay`) and the line (via `m` and `q`);
- line 8 defines the `line` function, using `m` and `q`;
- line 9 is a helper function to calculate the distance of a point on
  the line from the reference point `A`;
- line 10 calculates the hyperbole according to [Fortune's algorithm][];
- line 11 calculates `r`, that allows mixing `line` and `hyperb`
  together. It is supposed to range between `0` (all `line`) and `1`
  (all `hyperb`);
- line 12 calculates the mix of `line` and `hyperb`, according to the
  ratio `r`.

The mix is just a linear combination of the two functions, according to
a ratio `r`. This is calculated using the two parameters `n` and `N`,
which are supposed to come from the outside; this allows passing the
ratio as a numerator/denominator pair, which allows using integers from
the outside.

The rest is graphics stuff. One important thing is that line 17 sets the
name of the output file according to the `filename` variable, which is
supposed to be set from the outside.

Invoking the script, then, requires setting `n`, `N`, and `filename`,
like this:

```
# set at 10/25th of the mix, save in test.png
$ gnuplot \
   -e 'n=10' \
   -e 'N=25' \
   -e 'filename=test.png' \
   20200303-parametric.gnuplot
```

And I guess it's all for today!


[Gnuplot]: http://gnuplot.info/
[Fortune's algorithm]: {{ '/2019/10/12/voronoi1' | prepend: site.baseurl | prepend: site.url }}
[other post]: {{ '/2019/10/13/voronoi2' | prepend: site.baseurl | prepend: site.url }}
[Local version]: {{ '/assets/code/20200303-parametric.gnuplot' | prepend: site.baseurl | prepend: site.url }}
