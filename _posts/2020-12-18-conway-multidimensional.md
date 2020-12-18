---
title: "Multidimensional Conway's Game of Life"
type: post
tags: [ maths, perl ]
comment: true
date: 2020-12-18 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Addressing [Conway's Game of Life][] with a different approach for a
> multidimensional infinite space.

So... the [Advent of Code][] is challenging us with a multi-dimensional
generalization of [Conway's Game of Life][], to be evaluated on an infinite
space with $n$ dimensions. Cool!

This got me thinking... I can use a different representation and only keep
track of the cells that are *alive*, without keeping the whole matrix.
Especially now that it's not a matrix any more, *and* it's infinite in size.
Ouch.

So, I settled for this:

- coordinates are merged together in a single *key* string, like `1 5 -2` that
  stands for $x = 1$, $y = 5$, and $z = -2$;
- the whole field is just a list of *key*s, representing the coordinates of
  *alive cells*.

Evolving from a state to the next one means calculating another list of
active keys. This is done with the following function:

```perl
sub conway_3d_tick ($state) {
   my %previously_active;
   my %count_for;
   for my $cell ($state->@*) {
      my ($x, $y, $z) = split m{\s+}mxs, $cell;
      for my $xd (-1 .. 1) {
         my $X = $x + $xd;
         for my $yd (-1 .. 1) {
            my $Y = $y + $yd;
            for my $zd (-1 .. 1) {
               my $Z = $z + $zd;
               my $key = "$X $Y $Z";
               if ($xd == 0 && $yd == 0 && $zd == 0) {
                  $previously_active{$key} = 1;
               }
               else {
                  $count_for{$key}++;
               }
            }
         }
      }
   }
   my @active;
   while (my ($key, $count) = each %count_for) {
      if ($previously_active{$key}) {
         push @active, $key if $count == 2 || $count == 3;
      }
      else {
         push @active, $key if $count == 3;
      }
   }
   return \@active;
}
```

The first loop (`for`) iterates over all cells that are alive in the input
state, and does the following:

- increments the count of neighbors for surrounding cells;
- marks the specific cell as *previously active*.

The second loop goes through all cells that have alive neighbors and checks
for the count, to establish if the cell will contain an active element in
the next round. If this is the case, the key is recorded in an array that is
eventually produced as output.

Generalizing to 4 dimensions in the "second half" of the puzzle is trivial
with copy-paste and adaptations. I know, I know... copy and paste code is
not a good practice. But but... it's very effective if you are in a hurry
and you don't care about future maintenance!

[Conway's Game of Life]: {{ '/2020/04/23/conway-life/' | prepend: site.baseurl }}
[Advent of Code]: https://adventofcode.com/
