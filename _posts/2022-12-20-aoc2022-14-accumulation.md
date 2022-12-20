---
title: 'AoC 2022/14 - Sand accumulation'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-20 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 14][puzzle] from [2022][aoc2022]:
> making sand fall and time pass.

This was a nice puzzle, and I feel like I would be spoilering the fun
writing about it.

Well, let's be honest. I'm a lot tired, because I spent most of the last
night *trying* to solve puzzle 19, to no avail. So this year I failed at
solving each puzzle in its own day.

This failures are a goldmine. I don't think I'll go looking for
solutions until I have one by myself, but I actually was pissed way more
than I anticipated. So well, yeah... who knows if I'll make it in time
for when I'll write about that puzzle?

Anyway, back to puzzle 14. To be honest, there's nothing tricky about
it. I went for a *brute-forcish* approach where I rasterized all
segments, and it worked fine.

Reading the inputs is a little exercise in getting array and maps and
hyperoperators right:

```raku
sub get-inputs ($filename) {
   [
      $filename.IO.lines.map(
         {
            [ .split(/\s*\-\>\s*/).map({[.comb(/\d+/)».Int]}) ]
         }
      )
   ];
}
```

As we will be dealing with `.min` and `.max` later, we have to make sure
that they will treat numbers as numbers. Method `.comb()` gives strings
back, hence the explicit casting with `».Int`.

Incidentally, I find that I'm always going for `Array`s instead of using
plain sequences. I'm surely *not* getting something in the right way.

Part 1 is about finding how many units of sand will get stuck in the
different levels until sands starts going off into the pit. The main
insight here is that as soon as a unit of sand goes outside the levels
bounding box (either downwards or on a side) then everything after that
will go for good as well.

In the following function the first loop builds the rasterization of all
polygonals, using a hash to represent the field in a *sparse* way.
Raster, but *with style*!

The second loop is infinite, but not too much (because we will `return`
as soon as the right conditions show up).

This is just the outer loop, though, where new sand units are dropped
from the entrance on the top. The inner loop, still *undefined*, is
about making this unit of sand drop down as much as possible, according
to the rules. Here is where we check if the unit is still inside the
bounds or is gone for good, making the whole search stop.

If the unit stops somewhere, we fix that position with a `O` and proceed
with a new one, and so on.

```raku
sub part1 ($inputs) { return 'part 1';
   my $min_x = $inputs.map({$_»[0]}).flat.min;
   my $max_x = $inputs.map({$_»[0]}).flat.max;
   my $min_y = $inputs.map({$_»[1]}).flat.min;
   my $max_y = $inputs.map({$_»[1]}).flat.max;
   my %field;
   for @$inputs -> $poly {
      my ($fx, $fy) = $poly[0].Slip;
      for 1 .. $poly.end -> $i {
         my ($tx, $ty) = $poly[$i].Slip;
         my @xrange = min($fx, $tx) .. max($fx, $tx);
         my @yrange = min($fy, $ty) .. max($fy, $ty);
         for @xrange X @yrange -> ($x, $y) { %field{"$x,$y"} = '#' }
         ($fx, $fy) = $tx, $ty;
      }
   }

   for 1 .. * -> $i {
      my $x = 500;
      my $y = 0;
      loop {
         my $in-bounds = $min_x <= $x <= $max_x && $y <= $max_y;
         return $i - 1 unless $in-bounds;

         my $ny = $y + 1;
         if    %field{"$x,$ny"}:!exists       {      }
         elsif %field{"{$x - 1},$ny"}:!exists { --$x }
         elsif %field{"{$x + 1},$ny"}:!exists { ++$x }
         else                                 { last }
         $y = $ny;
      }
      %field{"$x,$y"} = 'O';
   }
}
```

Part 2 is a variation on the theme, only this time there's no falling in
a pit but the sand might accumulate "pyramidally" up to closing the
entrance. As a matter of fact, we just have to run the same simulation
with different boundary and exit conditions:

```raku
sub part2 ($inputs) {
   my $min_y = $inputs.map({$_»[1]}).flat.min;
   my $max_y = $inputs.map({$_»[1]}).flat.max;
   $max_y += 2;

   my $min_x = min(500 - $max_y, $inputs.map({$_»[0]}).flat.min);
   my $max_x = max(500 + $max_y, $inputs.map({$_»[0]}).flat.max);

   my %field;
   for @$inputs -> $poly {
      my ($fx, $fy) = $poly[0].Slip;
      for 1 .. $poly.end -> $i {
         my ($tx, $ty) = $poly[$i].Slip;
         my @xrange = min($fx, $tx) .. max($fx, $tx);
         my @yrange = min($fy, $ty) .. max($fy, $ty);
         for @xrange X @yrange -> ($x, $y) { %field{"$x,$y"} = '#' }
         ($fx, $fy) = $tx, $ty;
      }
   }

   %field{"$_,$max_y"} = '#' for $min_x .. $max_x;

   for 1 .. * -> $i {
      my $x = 500;
      my $y = 0;
      loop {
         return $i - 1 if %field{'500,0'}:exists;

         my $ny = $y + 1;
         if    %field{"$x,$ny"}:!exists       {      }
         elsif %field{"{$x - 1},$ny"}:!exists { --$x }
         elsif %field{"{$x + 1},$ny"}:!exists { ++$x }
         else                                 { last }
         $y = $ny;
      }
      %field{"$x,$y"} = 'O';
   }
}
```

We still have the sort-of rasterization at the beginning, with the
addition of the bottom floor that can be represented as an additional
segment. It's potentially infinite in size, but to meet the top entrance
closing condition we just need the right amount of floor, i.e. the
strict necessary to accomodate a triangular pattern of fallen sand.

The rest... is left as a simple exercise for the reader!

[Full solution][] (with some visualization!).

Stay safe!


[puzzle]: https://adventofcode.com/2022/day/X
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/14.raku
