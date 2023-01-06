---
title: 'AoC 2022/15 - Diamonds are squares in disguise'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-21 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 15][puzzle] from [2022][aoc2022]:
> there's always to learn from [the Megathread][].

This day's solution was a bad exercise in brute force for me, so I'm not
commenting my solution. As a matter of fact, I deleted my solution to
the second part actually, and opted for reimplementing it in a more
rational way (although not completely correct).

The [full solution][] is available, of course.

The gist of how part 2 *should be addressed* is to avoid going fully
brutal and only figure out intersections of the outer "shells"
(actually, perimeters) for each sensor's reach.

This can also be combined with a simple change of coordinates that turns
the diamond-shaped ranges into plain squares, which are *extremely* easy
to search for intersections.

So here's my part 2:

```raku
sub part2 ($inputs, $midsize) {
   my $size = $midsize * 2;
   my @t-rex = $inputs.map: ->($x, $y, $bx, $by) {
      my @r = (1 + ($x - $bx, $y - $by)».abs.sum) «*» (-1, 1);
      (($x + $y) «+» @r, ($x - $y) «+» @r).flat.Array;
   };

   for @t-rex -> $h {
      my ($hx-min, $hx-max, $hy-min, $hy-max) = |$h;
      for @t-rex -> $v {
         next if $h === $v;
         my ($vx-min, $vx-max, $vy-min, $vy-max) = |$v;
         PAIR:
         for ($hy-min, $hy-max) X ($vx-min, $vx-max) -> ($hy, $vx) {
            next unless $vy-min <= $hy <= $vy-max
                     && $hx-min <= $vx <= $hx-max;
            next PAIR if ($vx + $hy) % 2;
            for @t-rex -> ($cx-min, $cx-max, $cy-min, $cy-max) {
               next PAIR if $cx-min < $vx < $cx-max
                         && $cy-min < $hy < $cy-max;
            }
            my $x = ($vx + $hy) div 2;
            next PAIR unless 0 <= $x <= $size;
            my $y = ($vx - $hy) div 2;
            next PAIR unless 0 <= $y <= $size;
            return $x * $size + $y;
         }
      }
   }

   return 'part2';
}
```

The `$midsize` is the 10 or 2000000 value that should be otherwise
hardcoded.

After calculating the intersections, we go back in the "normal"
coordinates system and check if the intersection is within the bounds.
When we find one such position... we're done.

How is this *not completely* correct? Well... there are four corner
cases, located at the very four corners of the search area, where the
missing beacon might be located, and this solution would not find it.

Easy to address and left as an exercise for the reader, have fun!

[puzzle]: https://adventofcode.com/2022/day/X
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/15.raku
[the Megathread]: https://www.reddit.com/r/adventofcode/comments/zmcn64
