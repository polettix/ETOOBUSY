---
title: 'AoC 2016/11 - New representation'
type: post
tags: [ advent of code, coding, perl, algorithm, series:AoC 2016-11 ]
comment: true
date: 2021-01-12 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]:
> adopting a new, more compact representation.

One of the things that are quite evident in the solution so far is that
it's a *memory hog*. I blame my representation for this and, to a lesser
unscientific degree, the algorithm.

> This is a series of posts, [click here][aoc2016-11-tag] to list them
> all!

[aoc2016-11-tag]: {{ '/series#aoc-2016-11' | prepend: site.baseurl }}

So, we will try to adopt a different approach that is much more compact.
We will go back to a time when things were simpler, screens were blocky
and a single bit would mean anything, if you put enough imagination.

Losing *a lot* of generality, we can pragmatically observe that:

- in the most challenging puzzle version, there are seven different
  elements;
- there are four floors.

Having less than (or equal to!) eight elements means that we can fit the
whole floors state in two 32-bits unsigned integers:

- one for microchips, one for generators;
- each octet represents a floor;
- each bit in a octet is `1` if the corresponding item is *there*, `0`
  otherwise

As a convention, we will assume that *floor 4* is the least significant
octet in the unsigned integer, and *floor 1* is the most significant
one. It might be the other way around, of course, but I thought it best
to underline the fact that we're aiming to bring everything to *floor 4*
eventually, and this representation heads us towards minimizing the
integers in the representation.

On top of this, we only need to track the position of the elevator,
which takes another unsigned char (as a minimum). Consistently with the
representation for the floors, we will assume that `0` means *elevator
at the fourth floor* and `3` means *elevator at the first floor*.

As a concession to more recent times, though, we will:

- track the number of actual different elements, because it will come
  handy later, and
- fit this all in a hash with explicative keys, like `microchips`,
  `generators`, `elevator`, and `n_elements`.

As an example, let's consider the input for the first part of the
puzzle:

```
my $start_puzzle_1 = {
   elevator   => 0,
   generators => 0b00000001_00011110_00000000_00000000,
   microchips => 0b00000001_00000000_00011110_00000000,
   n_elements => 5,
};
```

Our goal will be:

```
my $goal_puzzle_1 = {
   elevator   => 0,
   generators => 0b00000000_00000000_00000000_00011111,
   microchips => 0b00000000_00000000_00000000_00011111,
   n_elements => 5,
};
```

For part 2 we will have instead:

```
my $start_puzzle_2 = {
   elevator   => 0,
   generators => 0b01100001_00011110_00000000_00000000,
   microchips => 0b01100001_00000000_00011110_00000000,
   n_elements => 7,
};

my $goal_puzzle_2 = {
   elevator   => 0,
   generators => 0b00000000_00000000_00000000_01111111,
   microchips => 0b00000000_00000000_00000000_01111111,
   n_elements => 7,
};
```

This will hopefully help us keep memory at bay... let's hope for the
best!


[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
