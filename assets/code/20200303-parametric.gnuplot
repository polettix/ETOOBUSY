#!/usr/bin/env gnuplot

# Mathematics
Ax = 0
Ay = 0
m = 0.9
q = -1.0
line(x) = m * x + q
dist(x) = sqrt((Ax - x)**2 + (Ay - line(x))**2)
hyperb(x) = line(x) + dist(x)
r = (0.0 + n) / N
mix(x) = (1 - r) * line(x) + r * hyperb(x)


# Graphics
reset
set terminal pngcairo size 410,250 enhanced font 'Verdana,9'
set output filename
set style line 1 lc rgb 'red'  lw 2
set style line 2 lc rgb 'blue' pt 7
set key off
set yrange [-2:1.2]

## Draw point
set label at Ax, Ay "A" point ls 2

## Draw mix
plot [-1:1] mix(x) t 'mix' ls 1
