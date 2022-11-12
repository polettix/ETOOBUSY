---
title: 'AoC 2016/11 - Initial data structure'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-11 ]
series: Radioisotope Thermoelectric Generators (AoC 2016/11)
comment: true
date: 2021-01-05 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: the
> *initial* data structure.

In [last post on input parsing][aoc2016-11-input-parsing] we took a quick
look at how to turn the very-verbose input into information that we can
fit insie a data structure. Now it's the time to look at the data
structure.

As I already wrote, this puzzle was challenging *for me*. This meant that
I had to change strategy, and the underlying data structure, a few times.
We will probably see only a couple of them here, so this is the initial
take.

My approach is to try and go with what I think it's the simpler for *me as
a human* to keep track of. So it's usually nothing optimized, but at least
*I* find it understandable. At that time, at least. So please don't
complain too much, *future me*!

# Representing the state

My initial goal was to keep things simple. I have to represent
a four-floors section? Let's use a four-slots array! Each slot in the
array will contain a reference to an array that holds the *actual*
contents of the floor.

I also decided to adopt the following convention inside each floor:

- each floor size is the same, independently of the actual contents. The
  size is the maximum number of objects that it can contain, i.e. the
  *elevator*, all *generators*, all *microchips*;
- each type of item has a fixed position in the floor's array:
    - the first position (i.e. index `0`) holds the elevator;
    - the second and third positions (i.e. indexes `1` and `2`) hold the
      first element's microchip and generator, respectively;
    - as an extension, the $k$-th element's microchip and generator are
      kept at indexes $2 \cdot k - 1$ and $2 \cdot k$ respectively. But
      wait! We're dealing with the [Perl][] language where array indexes
      start at `0`, so assuming that $k$ starts there too our formula
      becomes $2 \cdot k + 1$, where $k = 0$ represents the first element.

There's no particular imagination in this representation, actually,
because it mimics very closely how the whole thing is pictured in the
[puzzle input][p11]:

```text
F4 .  .  .  .  .  
F3 .  .  .  LG .  
F2 .  HG .  .  .  
F1 E  .  HM .  LM 
```

So here's how the initial state state is built:

```perl
my @start = map { [(0) x $n_slots] } 1 .. 4;
$start[0][0] = 1; # elevator
while (my ($element, $floor) = each $floor_for{m}->%*) {
   $start[$floor][$slot_idx_of{$element}] = 1;
}
while (my ($element, $floor) = each $floor_for{g}->%*) {
   $start[$floor][$slot_idx_of{$element} + 1] = 1;
}
```

As anticipated, the *elevator* is put in slot `0` of the first floor
(which has index `0`). Then we fit microchips in the slot identifiers
provided by a helper data structure `%slot_idx_for` (more on this shortly)
and the corresponding generator in the slot immediately after.

The final goal is to move everything on the fourth floor, i.e. on the
array at index `3`. For this reason, this final state is built as follows:

```perl
my @goal = map { [(0) x $n_slots] } 1 .. 3;
push @goal, [(1) x $n_slots];
```

It's now time to take a closer look at all these variables and data
structures that helped us set up these two states.

# The supporting data structures

There are a few supporting data and data structures that are helping in this
case:

- `%slot_idx_for` keeps track of the *slot index* that a microchip will end up in;
- `%floor_for` keeps track of which floor a microchip or a generator are
  put in. It actually has two sub-hashes, one for microchips (with the `m`
  key) and one for generators (with the `g` key).
- `$n_slots` is the total number of slots.

This last variable is the easier to tackle because it can be derived
directly from `%slot_idx_for`:

```perl
my $n_slots = scalar(keys %slot_idx_of) * 2 + 1;
```

Each floor contains two slots for each element (one for the microchip, one
for the generator), plus an additional one for the generator (in index
`0`).

Let's not move to the two hashes, which are populated while reading the
inputs:

```perl
 1 my %floor_idx_of = (
 2    first => 0,
 3    second => 1,
 4    third => 2,
 5    fourth => 3,
 6 );
 7 my %slot_idx_of = ();
 8 my %floor_for;
 9 my $filename = shift || basename(__FILE__) =~ s{\.pl\z}{.tmp}rmxs;
10 open my $fh, '<', $filename;
11 while (<$fh>) {
12    my ($floor) = m{\A The \s+ (\S+) \s+ floor \s+ contains \s+}mxs;
13    my $floor_idx = $floor_idx_of{$floor};
14    while (s{(\S+)-compatible}{}mxs) {
15       my $id = scalar keys %slot_idx_of;
16       $slot_idx_of{$1} //= 2 * $id + 1;
17       $floor_for{m}{$1} =  $floor_idx;
18    }
19    while (s{(\S+) \s+ generator}{}mxs) {
20       $floor_for{g}{$1} = $floor_idx;
21    }
22 }
23 close $fh;
```

The helper `%floor_idx_of` (lines 1 through 6) is a mapping that turns the
*name* of the floor into an index inside the main array of the state,
hence we find the indexes from `0` to `3` included.

During the main loop for reading the inputs (lines 11 through 22) we
leverage the regular expressions in [Input
parsing][aoc2016-11-input-parsing] to extract the floor name (line 12) to
get the floor index (line 13), then iterate over the line to get
microchips (lines 14 through 18) and generators (lines 19 through 21).

In these sub-loops we record the specific floor for each element's
component (microchip at line 17, generator at line 20).

Last, we populate `%slot_idx_of`, that is the slot index for microchips,
by *potentially* assigning a new identifier for the element in `$1` (lines
15 and 16). The `//=` operator makes sure that we only allocate a new
identifier when it's not already present, although this is a paranoid
measure because there's always *one single microchip* for each element.
The new element's index is found according to the formula we already saw
before, remembering that the index of the first element is $k = 0$.

# Enough!

I think I abused your patience enough for today. With probably much more
code tha we needed, we managed to populate the initial state from the
puzzle input, and the goal state based on the puzzle description. Now...
we will concentrate on understanding what's the minimum number of steps to
go from one to the other!

[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[aoc2016-11-input-parsing]: {{ '/2021/01/04/aoc2016-11-input-parsing/' | prepend: site.baseurl }}
