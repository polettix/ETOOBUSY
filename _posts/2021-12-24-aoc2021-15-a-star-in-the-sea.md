---
title: 'AoC 2021/15 - A* in the sea'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-24 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 15][puzzle] from [2021][aoc2021]:
> using [A\*][astar].

This day's puzzle was about finding a path through a field according to
a minimization principle, which is somehow textbook for search
algorithms.

A lot of people used [Dijkstra's Algorithm][dijkstra] but I thought of
re-using my [A\*][astar] [implementation][cglib-astar] from
[cglib-raku][]. I was *not* thrilled with the results, though: there's
probably ample space for improvement.

Anyway, I learned that using *integers* instead of strings for
identifying the different nodes gave some execution boost that was good
to see.

The core of the solution is in the implementation for part 1, as part 2
is basically the same with different parameters:

```raku
sub part1 ($b, :$kr = 1, :$kc = 1) {
   my $size = [$b.elems, $b[0].elems];
   my $max = ($size «*» ($kr, $kc)) «-» (1, 1);
   my $row-size = $max[1] + 1;
   my &cost = -> $p {
      my $v = $p «%» $size;
      my $base = $b[$v[0]][$v[1]];
      my $shift = ($p «/» $size)».Int.sum;
      1 + ($base + $shift - 1) % 9;
   };
   my $astar = Astar.new(
      heuristic => -> $v, $w { ($v «-» $w)».abs.sum },
      distance => -> $v, $w { &cost($w) },
      identifier => -> $v { $v[0] * $row-size + $v[1] },
      successors => -> $v {
         ((1, 0), (0, 1), (-1, 0), (0, -1)).map({ $v «+» $_ })
            .grep({.min >= 0 && ($max «-» $_).min >= 0});
      },
   );
   my $path = $astar.best-path([0, 0], $max);
   return $path.map(&cost).sum - $b[0][0];
}
```

The heuristic is a basic Manhattan distance, which plays well with the
movement restrictions (no diagonals) and with the heuristic's constraint
for optimality (i.e. not overestimating the actual distance). It's
probably not great, though, and the whole thing is likely collapsing to
plain [Dijkstra][dijkstra].

As anticipating, I'm using an integer for the identifier, although it is
anyway stringified in the algorithm's implementation. It does not excel
in performance... but it works `¯\_(ツ)_/¯`.

Finding the successors is an occasion to show off some meta-operations:
we iterate through the allowable displacements and apply them to the
current position using `«+»`. To check if the result is within the bound
we still apply meta stuff.

The result if found by summing the elements in the whole path... except
for the starting tile, whose cost must be ignored by explicit
requirement.

Well, enough for today... stay safe and have `-Ofun` people!

[puzzle]: https://adventofcode.com/2021/day/15
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[dijkstra]: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
[Astar]: https://en.wikipedia.org/wiki/A*_search_algorithm
[cglib-astar]: https://github.com/polettix/cglib-raku/blob/main/Astar.rakumod
[cglib-raku]: https://github.com/polettix/cglib-raku
