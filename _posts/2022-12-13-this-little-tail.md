---
title: 'AoC 2022/9 - This little tail...'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-13 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 9][puzzle] from [2022][aoc2022]:
> this was fun!

This challenge is very interesting because the operations depend on the
reciprocal positions of the ends of a rope, which are "connected"
together while still being allowed to be separated for little times.
Quantum behaviour for the win!

In the first puzzle, we have a very short rope, formed by a head and a
tail that must eventually be touching by a side or by a corner. If the
head moves away from this condition, the tail will follow according to
certain rules (see the [puzzle][] for a few examples).

In the second puzzle, there are many chunks connected head-to-tail and
we have to follow all tails (as we're interested into the last one,
actually).

The puzzle is expressed simply: determine the movements of the tail
induced by the input movements of the head. Inputs are like this:

```
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
```

It's easy to parse them, as we are interested into each pair:

```raku
sub get-inputs ($file) { [ $file.IO.lines.map({ [ .comb(/\S+/) ] }) ] }
```

It's actually better to turn these inputs into the positions of the head
of the first (or only) chunk:

```raku
sub moves-to-positions (@moves) {
   state %delta = R => (1, 0), L => (-1, 0), U => (0, 1), D => (0, -1);
   my @head = 0, 0;
   return [
      [0, 0],
      @moves.map(-> ($direction, $amount) {
         (^$amount).map({[@head «+=» %delta{$direction}]}).Slip
      }).Slip
   ];
}
```

In hindsight, *this* can be considered part of inputs parsing actually.
Whatever.

Now we have a sequence of positions for the head, so we can implement
the algorithm to determine the corresponding positions of the tail:

```raku
sub head-to-tail (@head-positions) {
   my @tail = @head-positions[0].Slip;
   my @tail-positions;
   for @head-positions -> $head {
      my @diff = @$head «-» @tail;
      if ([*] @diff).abs > 1 { # diagonal movement needed
         @tail «+=» (@diff «/» @diff».abs);
      }
      elsif @diff[0].abs > 1 {
         @tail[0] += (@diff[0] / 2).Int;
      }
      elsif @diff[1].abs > 1 {
         @tail[1] += (@diff[1] / 2).Int;
      }
      else { next if @tail-positions } # no need to move in this case
      @tail-positions.push: [@tail.Slip];
   }
   return @tail-positions;
}
```

Hyperoperators abund this time! The decisions are based on the
difference vector in the two-dimensional positions of the head and the
tail. There are a few possibilities:

- they are a *knight's move apart* in any direction, like this example:

```
..H
T..
```

In this case, the vector has a difference of one in one dimension and a
difference of two in the other. The absolute value of the product is
greater than 1, so this is the test condition that we use. In this case,
the tail has to move in *both* dimensions, getting closer to the head.

- they are aligned but separated, like this example:

```
T.H
```

Here, the first test fails (the product is always 0) but the absolute
difference in one of the dimensions is two (i.e. greater than one).
These are the two middle tests in the code.

This approach works *also* in case the head does a diagonal movement,
reaching a configuration like this example:

```
T..
...
..H
```

This falls under the first case, so the tail would move towards the head
in both dimensions, reaching this configuration:

```
...
.T.
..H
```

It is not really important when there is only one single chunk, like
in part 1, because the head only moves horizontally or diagonally in
this case. It **is** important in part 2, though, so it's good that the
code does the right thing.

Speaking of *the right thing*, what's the correct movement? Well, we
have to move at most one position, and always towards the head. Let's
take the diagonal movement example:

```raku
@tail «+=» (@diff «/» @diff».abs);
```

The expression on the right calculates the *sign* function assuming,
like it is the case, that all components are non-zero. In other terms,
it gives out either `-1` or `+1`, which is exactly what we have to add
to the *current* tail position to move on.

The output of this function is the list of positions of the tail. Both
parts require us to calculate how many distinct positions are there for
a tail, which can be done turning positions into strings, then counting
how many distinct strings are there (using a `Set`):

```raku
@positions».join(' ').Set.elems;
```

The function takes as input the number of *knots*, i.e. in our small
rope case it's one head and one tail (two knots total):

```raku
sub part1 ($inputs) { count-tail($inputs, 2) }
```

In the second part we have a total of 10 knots:

```raku
sub part2 ($inputs) { count-tail($inputs, 10) }
```

How is this `count-tails` function shaped? Here it is:

```raku
sub count-tail ($inputs, $knots) {
   my @positions = moves-to-positions($inputs);
   @positions = head-to-tail(@positions) for 1..^$knots;
   return @positions».join(' ').Set.elems;
}
```

The main insight here is that middle knots first act as *tails*, and
"afterwards" act as *heads*. So we can apply our movement function
iteratively to each pair of head-tail knots and we will end up with the
right sequence of positions for the last tail. This is the sense of
applying `head-to-tail` for multiple times, depending on the number of
knots.

[Full solution][].

Stay safe, cheers!

[puzzle]: https://adventofcode.com/2022/day/9
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/09.raku
