---
title: Dumb Gnuplot
type: post
tags: [ gnuplot, terminal ]
comment: true
date: 2020-12-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Using the `dumb` terminal with [gnuplot][] is a real treat.

I already confessed that [Inconsolation][] is a great source of
inspiration, in multiple dimensions 🙄

One thing that blew my mind is being pointed towards the `dumb` terminal for
[gnuplot]. Consider the following small script and keep an eye on the `set
terminal dumb` line in particular:

```
#!/usr/bin/gnuplot
#
# Creates a version of a plot, which looks nice for inclusion on web pages
#
# AUTHOR: Hagen Wierstorf

reset

set terminal dumb ansirgb

# define axis
# remove border on top and right and set color to gray
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11
set tics nomirror
# define grid
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12

# color definitions
set style line 1 lc rgb '#8b1a0e' pt 1 ps 1 lt 1 lw 2 # --- red
set style line 2 lc rgb '#5e9c36' pt 6 ps 1 lt 1 lw 2 # --- green

set key bottom right

set xlabel 'x axis label'
set ylabel 'y axis label'
set xrange [0:1]
set yrange [0:1]

plot 'nice_web_plot.dat' u 1:2 t 'Example line' w lp ls 1, \
     ''                  u 1:3 t 'Another example' w lp ls 2
```

Should we run it? Course we should:

<script id="asciicast-372580" src="https://asciinema.org/a/372580.js" async></script>

If it complains about `ansirgb` you probably have an older version of
[gnuplot][]... just get rid of it and leave it as `set terminal dumb`. It
will not be as colored as the example above, but it will still work.

I read about this in [gnuplot: I swear this is a coincidence][], although I
guess that [Creating pretty graphs in linux with gnuplot][] (from [Adam
Shore's blog][]) is to... *blame* here. Thanks!

[gnuplot]: http://www.gnuplot.info/
[Adam Shore's blog]: https://adamjsho.blogspot.com/
[Creating pretty graphs in linux with gnuplot]: https://adamjsho.blogspot.com/2013/10/creating-pretty-graphs-in-linux-with.html
[Inconsolation]: https://inconsolation.wordpress.com/
[gnuplot: I swear this is a coincidence]: https://inconsolation.wordpress.com/2013/11/17/gnuplot-i-swear-this-is-a-coincidence/
