---
title: "Multidimensional Conway's Game of Life - the NestedLoops way"
type: post
tags: [ perl ]
comment: true
date: 2020-12-19 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Where I sacrifice some efficiency for maintenability.

In post [Multidimensional Conway's Game of Life][] I discussed my approach
to address a puzzle in [Advent of Code][] that deals with [Conway's Game of
Life][].

As usual, that day's challenge was split into two halves, basically
requiring to solve the same problem in different dimensions. As it is, I
just did some copy-and-paste with adaptations - it got the job done, but of
course I'll have to go in hell for this *too*.

So I thought... why not *generalize* the solution for a generic dimension?
Possibly using one old friend... [Algorithm::Loops][]? Here is what I came
up with:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use autodie;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Algorithm::Loops 'NestedLoops';
$|++;

my @active;
my $x = 0;
while (<DATA>) {
   my @line = split m{\s*}mxs;
   for my $y (0 .. $#line) {
      push @active, "$x $y" if $line[$y] eq '#';
   }
   ++$x;
}

for my $dimension (3, 4) {
   $_ .= ' 0' for @active;
   my $ticker = conway_ticker(@active);
   $ticker->() for 1 .. 5;
   say $dimension, ' ', scalar $ticker->()->@*;
}

sub conway_ticker (@active) {
   return sub { return [] } unless scalar @active;
   my $state = \@active;
   my $N = scalar split m{\s+}mxs, $state->[0]; # dimension
   my @ranges = map { [-1 .. 1] } 1 .. $N;
   return sub {
      my %previously_active;
      my %count_for;
      for my $cell ($state->@*) {
         my @pos = split m{\s+}mxs, $cell;
         $previously_active{$cell}++;
         NestedLoops(
            \@ranges,
            sub (@ds) {
               my $key = join ' ', map { $pos[$_] + $ds[$_] } 0 .. $#ds;
               $count_for{$key}++ if $key ne $cell;
            }
         );
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
      return $state = \@active;
   };
}

__DATA__
##.#...#
#..##...
....#..#
....####
#.#....#
###.#.#.
.#.#.#..
.#.....#
```

One interesting thing is that this code is about 5 to 6 times *slower* than
the copy-and-paste solution. *Without* having done any kind of benchmark
(which is the only way to go when you have these kind of doubts!), my *gut
feeling* is that this generic solution makes heavy use of *sub calls*, which
is not the case in the "less maintainable" version.

Take it like this... a gut feeling.

Anyway... it works, so enjoy!


[Multidimensional Conway's Game of Life]: {{ '/2020/12/18/conway-multidimensional' | prepend: site.baseurl }}
[Conway's Game of Life]: {{ '/2020/04/23/conway-life/' | prepend: site.baseurl }}
[Advent of Code]: https://adventofcode.com/
[Algorithm::Loops]: {{ '/2020/07/27/algorithm-loops' | prepend: site.baseurl }}
