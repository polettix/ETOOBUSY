---
title: Double Dobble - constraints
type: post
tags: [ maths, dobble, double dobble ]
series: Double Dobble
comment: true
date: 2021-05-10 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where I derive a constraint for [Double Dobble][].

In previous post [Matt Parker on Dobble][], I introduced a [video][] by
[Matt Parker][] with interesting stuff on the game [Dobble][].

One interesting thing is a link to [Double Dobble][], where a variant is
introduced with the following rule:

> Each pair of cards share exactly two symbols.

The two solutions provided, for $5$ and $9$ symbols per card, have been
derived with some code, but it got me thinking on whether they knew
*beforehand* how many cards these attempts would yield (i.e. $11$ and
$37$ cards, respectively, which is the same as the overall number of
symbols).

I think I got how to calculate these numbers.

Let's have $N$ symbols and $N$ blocks in total. This means that there are:

$$\frac{N(N-1)}{2}$$

distinct pairs in total; each pair must appear in two cards, so we
consider $N(N-1)$ total pairs to distribute over $N$ blocks, i.e. each
block holds $N - 1$ pairs.

If a block contains $k$ symbols, then it also contains:

$$\frac{k(k-1)}{2}$$

distinct pairs. As we saw, this must be equal to $N - 1$, so:

$$
N - 1 = \frac{k(k-1)}{2} \\
N = \frac{k(k-1)}{2} + 1
$$

This formula tells us that:

$$
k = 5 \iff N = 11 \\
k = 9 \iff N = 37
$$

Yay!

[Matt Parker on Dobble]: {{ '/2021/05/04/matt-parker-dobble/' | prepend: site.baseurl }}
[Double Dobble]: https://aperiodical.com/2020/05/the-big-lock-down-math-off-match-22/
[Matt Parker]: http://standupmaths.com
[video]: https://www.youtube.com/watch?v=VTDKqW_GLkw
[Some Maths for Dobble]: http://blog.polettix.it/some-maths-for-dobble/
[Dobble]: https://boardgamegeek.com/boardgame/63268/spot-it
[pg2]: https://metacpan.org/source/POLETTIX/Math-GF-0.004/eg/pg2
