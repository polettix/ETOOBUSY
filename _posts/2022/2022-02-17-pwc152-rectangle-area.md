---
title: PWC152 - Rectangle Area
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#152][].
> Enjoy!

# The challenge

> You are given coordinates bottom-left and top-right corner of two
> rectangles in a 2D plane.
>
> Write a script to find the total area covered by the two rectangles.
>
> **Example 1:**
>
>     Input: Rectangle 1 => (-1,0), (2,2)
>            Rectangle 2 => (0,-1), (4,4)
>
>     Output: 22
>
> **Example 2:**
>
>     Input: Rectangle 1 => (-3,-1), (1,3)
>            Rectangle 2 => (-1,-3), (2,2)
>
>     Output: 25


# The questions

My only question in this case would be the exact domain of the inputs,
in particular with respect to the expectations. I mean, if we're talking
about values within "reasonable" bounds (say a few millions) just for
fun or any possibly number that can be represented exactly. This would
affect the choice of library to represent numbers (e.g. in [Perl][]
something like big-stuff).

# The solution

I once saw a movie or an episode in a thriller series where some people
were kidnapped, forced inside a maze whose shape was ever changing while
suffering thirst, then released. After some times, they were shown a
picture of the maze, and this induced so much emotion that they would
panic and basically cause their death (I remember a car plate turning
around showing the maze picture).

What does this have to do with the challenge?

Well, I have *inflicted* on you the whole series of last year's [Advent
of Code][], and this was like being shown the picture of the maze for
me. [This particular maze][]. Only that, lucky me, this is a much
gentler challenge, one that is maybe designed to get acquainted with
mazes after a rought split.

OK, back to business. We will use this algorithm:

- take the area of the first rectangle
- sum the area of the second rectangle
- subtract the area of the intersection, if any.

In fact, the area of the intersection would be counted twice, so if we
remove it once we land on the correct result.

[Raku][] first, which gives us the power of hyper-operators:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   put rectangle-area([[-1, 0], [2, 2]], [[0, -1], [4, 4]]);
   put rectangle-area([[-3, -1], [1, 3]], [[-1, -3], [2, 2]]);
}

sub rectangle-area ($r1, $r2) {
   return area($r1) + area($r2) - area(intersection($r1, $r2));
}

sub area ($r) { return $r ?? [*] ($r[1] «-» $r[0]).List !! 0  }

sub intersection ($r1, $r2) {
   my $bottom-left = $r1[0] «max» $r2[0];
   my $top-right = $r1[1] «min» $r2[1];
   my $min-difference = ($top-right «-» $bottom-left).min;
   return $min-difference > 0 ?? [$bottom-left, $top-right] !! Nil;
}
```

I had a bit of trouble in choosing the right representation for the
"inexistent" intersection. I eventually landed on `Nil`, even though I'm
not 100% happy with peppering the code with handling that special case.

The [Perl][] version is pretty much the translation, unrolled for the
lack of hyper-operators but still quite readable in my opinion:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util qw< min max >;

say rectangle_area([[-1, 0], [2, 2]], [[0, -1], [4, 4]]);
say rectangle_area([[-3, -1], [1, 3]], [[-1, -3], [2, 2]]);

sub rectangle_area ($r1, $r2) {
   return area($r1) + area($r2) - area(intersection($r1, $r2));
}

sub area ($r) {
   return 0 unless $r;
   return ($r->[1][0] - $r->[0][0]) * ($r->[1][1] - $r->[0][1]);
}

sub intersection ($r1, $r2) {
   my $bottom_left = [
      max($r1->[0][0], $r2->[0][0]),
      max($r1->[0][1], $r2->[0][1]),
   ];
   my $top_right = [
      min($r1->[1][0], $r2->[1][0]),
      min($r1->[1][1], $r2->[1][1]),
   ];
   my $min_difference = min(
      $top_right->[0] - $bottom_left->[0],
      $top_right->[1] - $bottom_left->[1],
   );
   return $min_difference > 0 ? [$bottom_left, $top_right] : undef;
}
```

So that's it, I'm not at peace with calculating this kind of stuff...

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#152]: https://theweeklychallenge.org/blog/perl-weekly-challenge-152/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-152/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Advent of Code]: https://adventofcode.com/
[This particular maze]: {{ '/2022/01/09/aoc2021-22-add-and-remove/' | prepend: site.baseurl }}
