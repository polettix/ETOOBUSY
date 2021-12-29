---
title: 'AoC 2021/20 - Flashy enhancements'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 20][puzzle] from [2021][aoc2021]:
> an image enhancement algorithm, with a flashy trick.

After the long ride that day 19 was for me, this puzzle seemed more in
line with leaving me some spare time to live my life.

Anyway, it managed to flash a bright light in my eyes and make me blind
for (luckily) a little time. It was not the puzzle's fault though,
because there are plenty of warnings:

> **Every** pixel of the infinite output image needs to be calculated
> exactly based on the relevant pixels of the input image.

The trick is that the background of the infinite canvas starts *off* and
the example input yields *off* for sub-regions that are already *off*.
So I thought... let's just ignore it for the most part!

BUT my input had that totally *off* sub-regions would be turned *on*,
which would happen for most of the canvas all of a sudden! Luckily,
though, all of these pixels will be then turned *off* again at the next
iteration, which also accounts for the fact that we are required to run
the algorithm an even number of times in both halves of the puzzle.

In my implementation I still disregard *most* of the infinite canvas and
just consider *some* of it around the target image. This is done thanks
to an `expand` function that adds a "frame" around the image, using the
right background setup (*off* or *on*) depending on the specific step of
the enhancement algorithm:

```raku
sub expand ($image, $around = 0) {
   my $retval = $image.map({ [ $around, |@$_, $around ] }).Array;
   $retval.unshift: [ $around xx $retval[0].elems ];
   $retval.push: [ $around xx $retval[0].elems ];
   return $retval;
}
```

In my representation, *on* is 1 and *off* is 0, so the `$around`
variable carries the information about the *current* background for
expanding the image. This is always applied twice (yes, I could have
done it directly inside the function itself!), e.g. while reading the
inputs:

```raku
sub get-inputs ($filename) {
   my ($map, $image) = $filename.IO.slurp.split: /\n (\n+ | $)/;
   my @map = $map.comb(/ \S /).map: { $_ eq '.' ?? 0 !! 1 };
   my @image = $image.lines».comb(/ \S /)».map({$_ eq '.' ?? 0 !! 1 }).Array;
   return {
      mapping => @map,
      image   => expand(expand(@image)),
      around  => 0,
   };
}
```

The expanded picture allows us to easily calculate what goes on in a
*smaller* future picture. In particular, the enhancement pass will trim
off one light in each border, so the net effect will be that the
original image grows by one light in each direction. Function `value-at`
takes care to calculate the new value for a position based on the 3x3
grid around it and the mapping provided as input.

```
sub value-at ($input, $r, $c) {
   my $bstring = (-1 .. 1).map({ $input<image>[$r + $_][$c - 1 .. $c + 1].join('')}).join('');
   return $input<mapping>[$bstring.parse-base(2)];
}

sub enhance ($input) {
   my @trimmed;
   for 1 ..^ $input<image>.end -> $ri {
      my $row = $input<image>[$ri];
      @trimmed.push: (1 ..^ $row.end).map({value-at($input, $ri, $_)}).Array;
   }
   my $around = $input<mapping>[0] - $input<around>;
   return {
      mapping => $input<mapping>,
      image => expand(expand(@trimmed, $around), $around),
      around => $around;
   };
}
```

As we can see, the data structure that is returned has the image
expanded twice again, this time with a value of `$around` that is
calculated by *possibly* flipping the background light. This addresses
both the example input where the background stays off all the time, as
well as the real input where it flashes all bright every other
enhancement step.

Last, we can show off a bit of [Raku][] in calculating the number of
*on* pixels:

```raku
sub calculate-lit ($image) { $image».sum.sum }
```

I always loved `map` and having this *tiny hyperform* `».whatever` that
fits some specific cases is a real treat. Although, admittedly, it's
easy to miss and I'm not sure it facilitates understanding what's going
on for those who don't know it.

I guess it's everything, stay safe folks!


[puzzle]: https://adventofcode.com/2021/day/20
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
