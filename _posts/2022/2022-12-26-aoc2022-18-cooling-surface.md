---
title: 'AoC 2022/18 - Cooling surface'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-26 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 18][puzzle] from [2022][aoc2022]:
> cubes and area calculation.

This puzzle happened to come up on a Sunday, when I had a lovely walk
with my wife, talking about the puzzle and possible solutions. Very
inspirational!

Reading the inputs is easy, because there's no difficult parsing to do:

```raku
sub get-inputs ($filename) {
   [ $filename.IO.lines.map({ [ .comb(/ \-? \d+ /) «+» 1 ] }) ]
}
```

Each cube is represented by its coordinates in the grid. We can think of
these coordinates as belonging to any point of the cube, as long as it's
the *same* point for all cubes. For sake of choosing one, let's say it's
the corner pointing to the negatives for all dimensions.

Why add `1` to all coordinates, you might ask! Good question, I don't
know!

I was actually biten by the *negative* numbers, so the lonely `\-?` is
there in evidence as a reminder.

Part 1 is about calculating the total surface of an aggregate of cubes,
in a rigid tridimensional grid. Two cubes sharing a face are considered
"merged" together and the common face is not part of the surface area
we're after. In other terms, two cubes sharing a face have the total
surface area of 10 times the surface of each face (5 faces from each
cube).

My surface area calculation function is the following:

```raku
sub surface ($inputs) {
   my $overall = SetHash.new;
   my @by-dimension = (0..2).map({ SetHash.new });
   state @faces = [1, 0, 0], [0, 1, 0], [0, 0, 1];
   for @$inputs -> $cube {
      die 'duplicate' if $overall{$cube.join(',')};
      $overall.set($cube.join(','));
      for 0 .. 2 -> $dim {
         for 0 .. 1 -> $offset {
            my $coords = $cube «+» (@faces[$dim] «*» $offset);
            my $key = $coords.join(',');
            my $sh = @by-dimension[$dim];
            if $sh{$key} { $sh.unset($key) }
            else         { $sh.set($key)   }
         }
      }
   }
   return [+] @by-dimension».elems;
}
```

Using a `SetHash` is easy, but any regular hash would do, e.g. in
[Perl][]. Anyway, we have it in [Raku][] and using it adds to the
readability. so why not?

The `$overall` variable is there only because I'm a paranoid and I
wanted to double check that there were no duplicate cubes in the inputs,
so we can disregard it.

We keep track of all faces, separating them by direction, in
`@by-dimension`. Each cube tries to add its six faces; if a face is
already there, then it means that the two participating cubes share that
face and we can get rid of it (`$sh.unset($key)`), otherwise we add it
to the lot (`$sh.set($key)`). As there are no duplicate cubes, each face
can appear *at most* twice, so this will work.

After iterating through all cubes, we're left with the singly-added
faces only, so we just have to count them (by sum).

```
return [+] @by-dimension».elems;
```

In hindsight, I could have kept one single cauldron of faces, using
their direction to generate their associated `$key` and avoiding the
hypersum at the end. Anyway... it's cool and does not harm.

Part 2 poses an interesting additional constraint: calculate only the
surface that remains on the *outside* of the whole thing. In other
terms, if there are "air bubbles" inside the whole thing, we have to
disregard the area of the internal bubble surface.

I didn't want to chase all these bubbles, so I thought it better to take
a cast of the whole thing and use it for the area calculation.

The idea is to build the following aggregate of cubes:

- find the bounding box of the whole thing, by finding the minimum and
  maximum value through all coordinates.
- Consider a bigger bounding box, adding one [voxel][] layer on every
  dimension. This creates a box that totally wraps our thing in all
  directions.
- Find all voxels that are *outside* of the thing. This can be done with
  a global visit of all adjacent voxels, starting from any corner of the
  embedding box (which is outside, by construction), stopping at any
  cube belonging to the thing.

At this point, we're left with a sort of [plaster cast][] of the thing,
with an exterior surface that is the same surface as the full box (so
it's very easy to calculate), and an interior surface that is what we
are after.

As our `surface()` function above calculates the *sum* of the two, we
can calculate our result by subtracting the area of the box surface from
it.

All of this is implemented in the `part2` function:

```raku
sub part2 ($inputs) {
   my $is-full = $inputs».join(',').Set;
   my $transposed = (0..2).map({$inputs»[$_]}).Array;

   # We immerse our droplet in a "box", totally surrounding it with
   # at least one layer in each direction
   my $mins = $transposed».min «-» 1;
   my $maxs = $transposed».max «+» 1;

   # This box has an exterior area that can be easily calculated.
   # If it has dimensions A, B, and C, then the area will be
   # 2 * (A*B + A*C + B*C). Note that A*B = (A*B*C)/C
   my $deltas = ($maxs «-» $mins) «+» 1;
   my $wrap = ([*] @$deltas);
   my $exterior = (($wrap «/» $deltas) «*» 2).sum;

   # Now we put our droplet in the box and fill it as much as we can,
   # creating a "cast" whose internal area is exactly what we are after.
   # It's just a plain visit through the graph of reachable voxels inside
   # the box, starting from one of the corners that we know *for sure* to
   # be on the outside.
   my %external;
   my @queue = [[$mins.Slip],$mins.join(',')],;
   state @offsets = [1, 0, 0], [0, 1, 0], [0, 0, 1];
   while @queue {
      my ($p, $pkey) = @queue.shift.Slip;
      next if %external{$pkey}:exists;
      %external{$pkey} = $p;
      for 0 .. 2 -> $dim {
         for -1, 1 -> $sign {
            my $q = $p «+» (@offsets[$dim] «*» $sign);
            next unless $mins[$dim] <= $q[$dim] <= $maxs[$dim];
            my $qkey = $q.join(',');
            next if $is-full{$qkey};
            @queue.push: [$q, $qkey];
         }
      }
   }

   # Our "surface" function above will calculate the interal area *plus*
   # the external area that we already calculated above as $exterior
   return surface([%external.values]) - $exterior;
}
```

[Full solution][].

Stay safe!

[puzzle]: https://adventofcode.com/2022/day/18
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[voxel]: https://en.wikipedia.org/wiki/Voxel
[plaster cast]: https://en.wikipedia.org/wiki/Plaster_cast
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/18.raku
