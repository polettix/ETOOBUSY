---
title: 'AoC 2016/11 - Initial algorithm: Dijkstra'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-11 ]
comment: true
date: 2021-01-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: using
> [Dijkstra Algorithm][] as an initial solution.

In the last post of this series ([AoC 2016/11 - Initial data structure][])
we left with two data structures populated for the task: the *initial
state* and the *goal state*.

> This is a series of posts, [click here][aoc2016-11-tag] to list them
> all!

[aoc2016-11-tag]: {{ '/tagged#aoc-2016-11' | prepend: site.baseurl }}


In itself, the problem can be thought as a search over a directed graph.
Each *state* is represented as a **node** in the graph, while
*transitions* are represented by **edges**. In our case, we have to find
the length of the *shortest path* from the initial to the goal state.

Does this ring a bell?

There's a whole host of algorithms on [shortest paths][Dijkstra
Algorithm], and one of the most celebrated has been described by [Edsger
Dijkstra][]. This is interesting because this algorithm applies to the
cases where we want some *locality*, i.e. it deals with a *single source*
and a *customizable set of goals* (that is, one in our case).

I recently wrote about my implementation [DijkstraFunction][] in [cglib][]
(see [Dijkstra Algorithm - as functions only][] for the details), and that
is the one we will reuse here:

```perl
use DijkstraFunction 'dijkstra';
...
my $outcome = dijkstra(
   start => \@start,
   goals => [\@goal],
   distance => sub { 1 },
   successors => \&successors_for,
   identifier => \&id_of,
);
say $outcome->{distance_to}->(\@goal);
```

The output of the function is a hash with two keys. The one we are
actually interested into here is only `distance_to`, because it's what the
puzzle asks us. We might also print out the whole solution using
`path_to`, though.

The function requires us a few input parameters:

- `start`: this is easy because we can provide our starting state as
  a reference to the array `@start`, which we built in the previous post
  in this series;
- `goals`: this is a reference to an array containing a list of goals we
  are interested into. In our case, we just provide one, that is
  a reference to array `@goal`;
- `distance`: in the algorithm, edges between nodes might have a variable
  weight. In our case, two adjacent nodes represent states that are
  separated by a single step of the elevator, so the cost of each action
  is always `1`;
- `successors`: a reference to a sub that takes a state as input, and
  provides back a list of states that can be reached. In graph terms, it
  provides all nodes that can be reached from a specific node (remember,
  the graph is directed!);
- `identifier`: each node in the graph must be recognized by an
  *identifier*, so that we can properly track when we land on the same
  node time and again. This function takes care to look into a node/state
  and produce a suitable identifier that is always consistent (i.e.
  identical states yield the same identifier, even if they come from two
  different underlying arrays).

At this point... we only lack `successors_for` and `id_of`, right? This
will be meat for future posts!

Before concluding, anyway, a little word on the choice of the algorithm.
The [A\* Algorithm][astar] might just as well address our concerns, and in
a more efficient way. But... that algorithm requires us to build
a *heuristic* on our estimation of how distant we are from the solution,
and this must also be either exact (in which case we would already have
the solution!) or *underestimate* the actual value. Which means... more
work for the programmer! Hence, at this stage we keep it simpler and stick
with [Dijkstra Algorithm][] instead.


[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[Dijkstra Algorithm]: https://algs4.cs.princeton.edu/44sp/
[AoC 2016/11 - Initial data structure]: {{ '/2021/01/05/aoc2016-11-initial-data-structure' | prepend: site.baseurl }}
[Edsger Dijkstra]: https://it.wikipedia.org/wiki/Edsger_Dijkstra
[Dijkstra Algorithm - as functions only]: {{ '/2021/01/02/dijkstra-function/' | prepend: site.baseurl }}
[DijkstraFunction]: https://github.com/polettix/cglib-perl/blob/master/DijkstraFunction.pm
[astar]: https://en.wikipedia.org/wiki/A%2A_search_algorithm
[cglib]: https://github.com/polettix/cglib-perl/
