---
title: Matt Parker on Dobble
type: post
tags: [ dobble, perl, maths ]
comment: true
date: 2021-05-04 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> [Matt Parker][] made a [video][] about [the maths behind][Some Maths
> for Dobble] [Dobble][].

It was interesting to see the video and be reminded of something I wrote
about three years ago: [Some Maths for Dobble][].

There were a few things that left me... *dissatisfied*. As an example,
the whole process where you make a circle of cards and use a specific
sequence to generate the cards seems a bit as coming out of thin air.
mean... why 57 cards? Why those displacements? Matt's explanation about
*why* it works is fantastic, though.

*Dissatisfaction* is an engine, though. There are a couple of loose ends
that will be interesting to follow.

I was curious about generating the cards with 102 pictures on,
leveraging $PG(2, 101)$. Using [pg2][] it took me about 70 minutes to
generate all the arrangements... I'm not impressed by my brute-force
algorithm to find all *orthogonal* sequences... 🙄

[Matt Parker]: http://standupmaths.com
[video]: https://www.youtube.com/watch?v=VTDKqW_GLkw
[Some Maths for Dobble]: http://blog.polettix.it/some-maths-for-dobble/
[Dobble]: https://boardgamegeek.com/boardgame/63268/spot-it
[pg2]: https://metacpan.org/source/POLETTIX/Math-GF-0.004/eg/pg2
