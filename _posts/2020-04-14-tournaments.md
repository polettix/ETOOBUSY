---
title: Allocating games in tournaments
type: post
tags: [ algorithm, game, maths, boardgamearena ]
comment: true
date: 2020-04-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> I've become curious about how to organize tournaments (in the sense of
> allocating games in it) when games have more than two players.

In these days of Coronavirus, there's been a surge in online playing, and
board games make no exception. In particular, [BoardGameArena][] is a very
nice place to play online, and they saw about a 6x increase in their traffic
(which gave them a few issues...).

One thing that always tickled me is that there is a tournament system. Alas,
as it is today their system only caters for two-players games, i.e. even
when games would allow for additional players, instances in tournaments only
allow two. This is sub-optimal in a lot of games that I like (e.g.
[Tokaido][]) and that are better played with three or more players.

# Two-players tournaments are easy...

... and there are a lot of ways to set them up. One of the easiest ways is
to get a number of players that is a power of 2, then half them at each
round with direct eliminations.

One consequence of direct-elimination matches is that half of the people
will play only a single game in the tournament. Which might be good for the
competition, less for people who wants to play 🤨

In the two-players space the answer to this issue is *round robin*
tournaments, in which each participant plays against each other. This is the
same as, for example, sport leagues (although often in this case they play
*two* matches against each other participant).

# Direct elimination for more players?

One easy extension is to organize $N$-players games in direct-elimination
matches, assuming that there are $N^p$ players. This means having $p$
rounds. Alas, this has the same drawback of the direct elimination
tournaments for two-players games, with the additional negative aspects
that:

- at each round, *more* people end playing at the same time ($\frac{2}{3}$
  for three-players games, $\frac{3}{4}$ for four-players games, and so
  on...)
- more players are needed for the same number of rounds (e.g. a three-rounds
  tournament for two-players games would require $2^3=8$ participants, for
  three-players games would require $3^3=27$ participants, i.e. more than
  three times).

One possibility is to let more players through each round. For example,
letting two players pass to the next round in four-player games basically
means keeping the same structure as in two-player direct-elimination
tournaments:

```
 1-1 1-2 1-3 1-4   1-5 1-6 1-7 1-8

     2-1 2-2           2-3 2-4

               winner
```

At any rate, this does not solve the need for people to play more!

# k-players leagues?

Another solution would be to find a way to extend the "league" approach to
$k$-players games (out of a total population of $n$ players participating in
the tournament).

One straightforward way to do this is to form all $n \choose k$ sub-sets of
$k$ players out of all $n$ participants, where each of them will play in
${n-1} \choose {k-1}$ matches. This might mean a few too many matches
though: a tournament with 8 players overall and 4-player matches would mean
70 matches overall, where each player competes in 35 of them. Ooops.

One observation is that many of those matches are... *redundant*. From the
example with 4-players matches out of 8 total participants, we have the
following matches (among others):

```
1 2 3 4
1 2 3 5
1 2 3 6
1 2 3 7
1 2 3 8
```

They are somehow... *pretty similar*, in that players `1`, `2`, and `3` are
playing five matches with each other inside.

Hence, while it's interesting that each participant plays against every
other one at some time, we can probably remove a lot of the redundant games
and enjoy the tournament. In general, we should aim for an arrangement where
we have a limit on how many times the same people play at the same table.

# Block Designs

One answer to the challenge in the previous section is to leverage [Block
Designs][]. This is the definition for *t-designs* (slightly adapted):

> Given a finite set $X$ (of $v$ elements called points) and integers $t$,
> $k$, $r$, $\lambda \geq  1$, we define a $t$-design $B$ to be a family of
> $k$-element subsets of $X$, called blocks, such that any $x$ in $X$ is
> contained in $r$ blocks, and any subset of $t$ of distinct points is
> contained in $\lambda$ blocks. The number of elements in family $B$ is
> $b$.

Uh? Translated in tournamentese:

- we have a set $X$ of $v$ participants to the tournament;
- we want to organize matches with $k$ players inside;
- each player competes in $r$ matches;
- we want that $t$ players compete in exactly $\lambda$ matches in which
  all are present at the same time.

In case we want to limit the number of times *pairs* of players compete at
the same table, we set $t = 2$, deal with *2-designs*, and call them BIBD
(Balanced Incomplete Block Designs). Actually, *block design* usually refers
to *2-designs*, and we will stick with them in the following.

Easy right? *Next problem pleaaaaase!*

Well, not so fast.

# Block Designs for arranging matches?

There are several different ways to create BIBDs, not all totally amenable
for tabletop games. For example, consider the BIBD induced by the [Fano
plane][] (numbers are player identifiers, from `0` up to `6`):

```
(1, 3, 5)
(0, 3, 4)
(2, 3, 6)
(0, 1, 2)
(1, 4, 6)
(0, 5, 6)
(2, 4, 5)
```

It might be applicable to a tournament of 7 players for games that accept
3 players at a time. Everyone plays against anybody else, but only once.
Yay!

There is a big defect though. As any other block design based on [finite
projective planes][finite projective plane], it has the characteristic that
*any two blocks always share exactly one point*. Which means: if you want to
limit the number of games that are played at the same time, e.g. so that
each player is only on a single table at the same time (like a real-time
table would more or less require), then you can only play a very limited
number of games at the same time. In particular, if you limit to one game
per player at most, at any time only a single game can run, where three
participants play and four wait.

# Finite affine planes to the rescue

On the other hand, BIBDs induced by [finite affine plaines][finite affine
plane] do not have this limitation. It's easy to get one from a [finite
projective plane][]: just get rid of a block and all items in it, and what
you're left with is a [finite affine plane][]. In the [Fano plane][] case,
let's get rid of the group `(0, 5, 6)`, as well as players `0`, `5`, and
`6`:

```
(1, 3, 5) -> (1, 3)
(0, 3, 4) -> (3, 4)
(2, 3, 6) -> (2, 3)
(0, 1, 2) -> (1, 2)
(1, 4, 6) -> (1, 4)
(0, 5, 6) ->      
(2, 4, 5) -> (2, 4)
```

This should look familiar: it's basically a *round-robin* arrangement for
four players, which allows two real-time games to go on at the same time,
for a total of 3 rounds:

```
1st round: (1, 2) (3, 4)
2nd round: (1, 3) (2, 4)
3rd round: (1, 4) (2, 3)
```

This is quite amenable now:

- everybody plays against each other, but no more than once
- everybody plays at each round
- everybody plays a reasonable amount of games


# Alternative paths of investigation

Another promising path for investigating is to explore the so-called [Social
Golfer Problem][] (see also [here][sgp-2]), which is formulated as follows:

> The task is to schedule $g \cdot p$ golfers in $g$ groups of $p$ players
> for $w$ weeks such that no two golfers play in the same group more than
> once.

The goal is to find the minimum number of weeks $w$ where this can happen,
and I'm also not sure at the moment if this also requires that every golfer
still plays with every other one... but it seems promising to find out
something to code in the future, and also to overcome some rigidity in the
schemas that we will investigate in the short time.

# More? Comments?

Please share your comments below!

[BoardGameArena]: https://boardgamearena.com/
[Tokaido]: https://boardgamearena.com/gamepanel?game=tokaido
[Block Designs]: https://en.wikipedia.org/wiki/Block_design
[Fano plane]: https://en.wikipedia.org/wiki/Fano_plane
[finite projective plane]: http://mathworld.wolfram.com/ProjectivePlane.html
[finite affine plane]: http://mathworld.wolfram.com/AffinePlane.html
[Social Golfer Problem]: https://www.metalevel.at/sgp/
[sgp-2]: http://www.mathpuzzle.com/MAA/54-Golf%20Tournaments/mathgames_08_14_07.html
