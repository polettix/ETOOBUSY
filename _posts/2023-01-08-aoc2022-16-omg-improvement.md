---
title: 'AoC 2022/16 - OMG what an improvement'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2023-01-08 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> More stuff about [Advent of Code][] [puzzle 16][puzzle] from
> [2022][aoc2022].

In [AoC 2022/16 - Pressured shame][previous], I left with this:

> So yeah, I still have to go some way before I have a general solution
> program.

Then, in follow-up post [AoC 2022/16 - Paying a debt][], I left with
this:

> The code above is not exceptionally fast, taking about 10 minutes to
> complete the search over my input. Anyway, this is an acceptable time
> by my standards, so I call it a win.

Then, *after* writing that post, *of course* I found a better way, in
the form of [this Rust code][]. Which made it possible to enhance the
computation from 10 minutes to... about 20 seconds (in [Raku][], of
course). Yup, you read it right - a 30x improvement!

It's at the same time...

- ... *fantastic*, there's always something to learn!
- ... *humbling*, I was so *wrong* in my gut feelings about which way to
  go!
- ... *frustrating*, because at the end of the day it's basically A\*
  and I should know much, much better!

Anyway, I re-implemented the Rust code  in [Raku][] and [it's available
here][16b]. It's fully commented, so I will not repeat the full
explanation here, but just add a few notes:

- as before, we consider an *overlay* graph where only the start valve
  and the valves with some positive rate are included, in a sort of
  full-mesh where we evaluate the shortest distance between any two
  valves.
- Distances between nodes are incremented by one unit because it does
  not make sense to "visit" a valve if we have no intention to open it,
  at least considering the "overlay". Opening requires a minute, hence
  the `+ 1` added to the distance.
- The heuristic is based on the upper bound possible for the score
  starting from a given state. This is, in turn, calculated based on the
  best possible score increment that we might possibly obtain, based on
  the following observations:
  - each "residual" valve is considered in decreasing order of possible
    gain, based on the residual time;
  - the contribution is calculated based on *reaching the node*
    (considering the minimum distance from any node) and calculating its
    contribution.
- the neighbors of each valve are sorted based on the possible
  additional gain, in descending order. This makes sure to try and
  expand the most promising nodes before other ones, in the hope to
  prune search branches thanks to the heuristic.

This heuristic part guarantees us that we never underestimate the upper
limit, which in turn guarantees that the solution will be optimal
(because we will never cut an optimal solution search subtree because of
an underestimation). This is where A\* comes from, together with using a
*priority queue* to expand states that are more promising before the
other ones.

Not coming up with the right heuristic is the main error that I did in
this challenge, I think. At the end of the day, it only required a fresh
mind and determination. I'll keep it in mind next time!

Overall, this has probably been the most interesting puzzle this year,
with the possible exception of [puzzle 19][], which is the next puzzle I
want to read more about around...

In the meantime, stay safe folks!

[puzzle]: https://adventofcode.com/2022/day/16
[puzzle 19]: https://adventofcode.com/2022/day/19
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[AoC 2022/16 - Paying a debt]: {{ '/2023/01/07/aoc2022-16-debt-payment/' | prepend: site.baseurl }}
[this Rust code]: https://github.com/orlp/aoc2022/blob/master/src/bin/day16.rs
[16b]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/16.b.raku
[previous]: {{ '/2022/12/24/aoc2022-16-pressured-shame/' | prepend: site.baseurl }}
