---
title: 'AoC 2022/12 - Human-machine interface solution'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-18 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 12][puzzle] from [2022][aoc2022]:
> solving the puzzle with a little human insight.

When I see path search puzzles my brain goes automatically to the
[A\* algorithm][astar]. I know that going by default solutions can be
dangerous, but I've got [a Raku implementation][asraku] and I want to
use it when possible.

Let's start from the beginning, i.e. reading the inputs:

```raku
sub get-inputs ($filename) {
   my @field = $filename.IO.lines.map(
      { .comb.map(
         {
            $_ eq 'S'    ?? -101
            !! $_ eq 'E' ?? 101
            !! .ord - 'a'.ord
         }).Array }
   );
   my (@start, @end);
   for (^@field X ^@field[0]) -> ($y, $x) {
      if @field[$y][$x] < -100 { @start = $x, $y; @field[$y][$x] = 0 }
      if @field[$y][$x] > 100  { @end   = $x, $y; @field[$y][$x] = 'z'.ord - 'a'.ord }
   }
   return {
      start => @start,
      end   => @end,
      field => @field,
   };
}
```

There *must* surely be a better way to do this! I'm especially ashamed
about going through the field twice, so that i can properly track where
the Start and the End are located. Whatever.

Part 1 of the puzzle is about finding the shortest path according to
some rules for going *upwards*. I saw a meme or two about this, and I
wholeheartedly agree: we can jump *down* as much as we want?!? Whatever.

So the solution is pretty straightforward:

```raku
sub part1 ($inputs) {
   my @path = path($inputs, $inputs<start>, $inputs<end>);
   return @path.elems - 1;
}
```

Uh... ehm... right, this is `path`:

```raku
sub path ($inputs, $from, $to) {
   my \rows = $inputs<field>.elems;
   my \cols = $inputs<field>[0].elems;
   my $nav = Astar.new(
      distance => -> $u, $v { 1 },
      successors => -> $pos {
         my ($px, $py) = @$pos;
         my $max = $inputs<field>[$py][$px] + 1;
         my @valid =
         gather for ([$px-1,$py], [$px+1,$py], [$px,$py-1], [$px,$py+1]) -> ($x, $y) {
            next unless 0 <= $y < rows && 0 <= $x < cols;
            take [$x, $y] if $inputs<field>[$y][$x] <= $max;
         };
         @valid;
      },
      heuristic => {($^v «-» $^w).map(*²).sum.sqrt},
      identifier => {$^v.join(',')},
   );
   return $nav.best-path($from, $to);
}
```

It's *just* a wrapper around `Astar` to feed it the right data, with
particular reference to finding the successors for each position.

Part 2 is supposed to be more challenging because it asks about finding
*another* starting spot among... a lot of possible starting positions. I
mean *a lot*.

The most clever apprach I saw about it is to reverse the search and
start from the end, up until the closest `a` character in the map. I
mean... *Flavio, you might use your brain every now and then!*

But I started brute-forcing it, just to understand that it was *not* the
right way to go. There are *so many* candidates for the starting
position that this is not feasible.

So I thought about looking at the inputs. There are *many* `a`s and `c`s
there... but whatever the starting point, it *must* have a `b` to make
the first step, right?

So I went for the *human-machine interface* and looked at the input. Not
general, I know, so my solution will most probably not be general at
all. Whatever.

Then I saw that all `b`s are in the second column! Look by yourself:

```
abccccca...
abccccca...
abccccaa...
abcccaaa...
...
abaaaacc...
abaacccc...
```

Well... not really a clear view, right? Whatever.

This insight makes it possible to only check the `a` characters in the
first column as a starting point:

```raku
sub part2 ($inputs) {
   my \rows = $inputs<field>.elems;
   my \cols = $inputs<field>[0].elems;
   my $best = cols * rows;
   for (0 X ^rows) -> ($x, $y) {
      next if $inputs<field>[$y][$x] > 0;
      my @path = path($inputs, [$x, $y], $inputs<end>);
      my $n = @path.elems;
      $best = $n if $best > $n;
   }
   return $best - 1;
}
```

It's **not** fast, it's not **smart**... but *it works*!


[Full solution][].

Stay safe!

[puzzle]: https://adventofcode.com/2022/day/12
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/12.raku
[astar]: https://en.wikipedia.org/wiki/A*_search_algorithm
[asraku]: {{ '/2021/07/31/raku-astar/' | prepend: site.baseurl }}
