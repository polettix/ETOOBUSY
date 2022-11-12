---
title: 'AoC 2016/11 - New algorithm: A*'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-11 ]
series: Radioisotope Thermoelectric Generators (AoC 2016/11)
comment: true
date: 2021-01-11 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: moving to
> the [A\* algorithm][astar].

One drawback of using Dijkstra's algorithm for our search is that it makes
a lot of expansions to get from the start node to the goal one. This was
somehow acceptable with the shorter inputs, but became prohibitive with
the longer one in **part 2**.

There's a more complex, but also more efficient, algorithm that will yield
the optimal path by generally expanding less nodes, taking less time in
the process. This is the [A\* Algorithm][astar]. On the good side, we
*already* have a self-contained implementation for the algorithm in
[cglib][], i.e. [AstarX.pm][].

This is the call we can adopt:

```perl
my $outcome2 = astar(
   start => [@start],
   goal  => [@goal],
   distance => sub { return 1 },
   heuristic => sub ($v, $goal) {
      my $d = 0;
      for my $fid (0 .. 2) {
         my $weight = 3 - $fid;
         $d += $weight * scalar grep {$_} $v->[$fid]->@*;
      }
      return $d;
   },
   identifier => \&id_of,
   successors => \&successors_for,
);
say scalar($outcome2->@*) - 1;
```

One difference is that the returned value is a list of nodes from the
start to the goal, both included. For this reason, we print the list's
lenght *minus one*, so that we know how many *steps* we have to take.

The second difference is the presence of the `heuristic` parameter. This
is an estimation of the distance between two nodes, but in the algorithm
is only used to establish the *distance of a node to the goal*. If we
set this identically to `0` we would fall back to Dijkstra's Algorithm,
and in general we need to provide either a correct value, or an
*underestimated* one.

Of course we don't know the correct value at this stage, otherwise we
might use that value to solve our initial problem. We can provide an
*underestimation* though, i.e. the bare minimum number of moves for each
item to the target fourth floor. It's a bit crude but it's a start.

Running the new code ([local version here][]) tells us we're heading in
the right direction:

```
$ time perl 11.pl 11.tmp
11

real  0m0.053s
user  0m0.048s
sys   0m0.008s

$ time perl 11.pl 11.input
33

real  0m10.165s
user  0m10.036s
sys   0m0.116s
```

It now takes one third of the previous time to solve part 1 - nothing terribly
better, but still an improvement!

Alas, this does not suffice to address all our concerns for this puzzle.
When provided the new *extended* input with *elerium* and *dilithium*...
it still eats a lot of memory and provides no answer in *reasonable
time*, so we have to do MOAR!



[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[astar]: https://en.wikipedia.org/wiki/A%2A_search_algorithm
[cglib]: https://github.com/polettix/cglib-perl/
[AstarX.pm]: https://github.com/polettix/cglib-perl/blob/master/AstarX.pm
[local version here]: {{ '/assets/code/aoc2016-11-02.pl' | prepend: site.baseurl }}
