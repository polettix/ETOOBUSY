---
title: 'Advent of Code 2018, puzzle 6: get the job done!'
type: post
tags: [ advent of code ]
comment: true
date: 2021-09-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I managed to get past [puzzle 6][aoc-2018-06] in [Advent of Code][],
> [2018 edition][aoc-2018].

And, to be honest, I'm not entirely happy with the solution.

I mean, I got past so my solution is *correct*. But... it's a solution
to *my* inputs, not a generic one. It's also very messy.

One tricky part is that some of the areas can go to infinity and one has
to be careful to... avoid them. So I was stuck for some time trying to
figure out a way to represent the field in order to avoid doing too much
calculation... but I ran out of ideas so I eventully conjured up
something and hammered it until it gave the correct answer back.

I think [Philboyd\_Studge][Philboyd-Studge] got it right in the *card*
of [this python solution][]:

> Rules for raising a programmer: never feed it after midnight, never
> get it wet, and never give it **anything involving the word
> 'infinite'**

It was dirty and did not leave me with a generic solution, which is a
shame.

On the bright side:

- ... it was fun!
- ... part 2 was easier and led me to [Today I Learned: Portable
  Grayscale Map][].
- ... I was reminded that I still have to *properly address* [Voronoi
  diagrams][];
- ... I realized [Voronoi diagrams][] with [Manhattan distance][] are
  nothing like their counterparts with the [Euclidean distance][];
- ... I discovered, in particular, that the points "going to infinite"
  are *NOT* the vertices of the polygonal [Convex Hull][] of the set of
  points, especially if you consider the [Euclidean distance][] to
  calculate it!

After all, it gave back some fruits.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Advent of Code]: https://adventofcode.com/
[aoc-2018]: https://adventofcode.com/2018/
[aoc-2018-06]: https://adventofcode.com/2018/day/6
[Voronoi diagrams]: https://en.wikipedia.org/wiki/Voronoi_diagram
[Manhattan distance]: https://en.wikipedia.org/wiki/Manhattan_distance
[Euclidean distance]: https://en.wikipedia.org/wiki/Euclidean_distance
[Convex hull]: https://en.wikipedia.org/wiki/Convex_hull
[this python solution]: https://www.reddit.com/r/adventofcode/comments/a3kr4r/2018_day_6_solutions/eb76o55?utm_source=share&utm_medium=web2x&context=3
[Philboyd-Studge]: https://www.reddit.com/user/Philboyd_Studge/
[Today I Learned: Portable Grayscale Map]:  {{ '/2021/09/05/til-pgm/' | prepend: site.baseurl }}
