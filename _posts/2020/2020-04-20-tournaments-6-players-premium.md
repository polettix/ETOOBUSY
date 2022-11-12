---
title: Allocating games in tournaments - 6 players matches, premium
type: post
tags: [ algorithm, game, maths, boardgamearena, Tournaments games allocation ]
series: Tournaments games allocation
comment: true
date: 2020-04-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> With a few sub-optimal alternatives for tournaments with 6-players matches,
> we are now ready to talk about premium games.

As we already saw in [Allocating games in tournaments - premium games and
players][], [BoardGameArena][] has a [premium][] program that restricts
who can *create* a match for a limited set of games (*premium* games). We
also saw that, for numbers solvable with affine planes, it's easy to
address the issue with $2n-1$ premium players (where $n$ is the number of
participants at each match).

# What to do with tournaments having 6-players matches?

The answer depends on the model and scheduling chosen among the
sub-optimal proposals in [Allocating games in tournaments - 6 players
matches, again][].

## Ignore the (extra) round

Although we ignore the extra round, it's interesting to take a look at it:

```
removed round:
  ()
  (  1,   7,  13,  19,  25,  31,  37)
  (  2,   8,  14,  20,  26,  32,  38)
  (  3,   9,  15,  21,  27,  33,  39)
  (  4,  10,  16,  22,  28,  34,  40)
  (  5,  11,  17,  23,  29,  35,  41)
  (  6,  12,  18,  24,  30,  36,  42)
```

This tells us a very interesting thing: taking all the players in *any* of the
matches above, and making them premium, is *sufficient* to guarantee that all
matches in the rounds we keep will have a premium user to create them.

How can we say this? Let's take the first match (`1`, `7`, ...) and consider
all those players premium. We know by design that any two of them will *not*
play in the same match in any of the rounds we kept. As there are 7 of them,
and each following round contains exactly 7 matches, this is actually at the
same time a sufficient and necessary condition.

So there we go, we *only* need 7 premium users:

```
1 7 13 19 25 31 37
```

## Relax: number of participants in a match

In this case, the eighth round is the following:

```
round 8:
  (  1,   7,  13,  19,  25,  31,  37)
  (  2,   8,  14,  20,  26,  32,  38)
  (  3,   9,  15,  21,  27,  33,  39)
  (  4,  10,  16,  22,  28,  34,  40)
  (  5,  11,  17,  23,  29,  35,  41)
  (  6,  12,  18,  24,  30,  36,  42)
```

As we saw in the previous section, taking the whole first match players and
making them premium is sufficient to address all the first seven rounds. To
keep things simple, we also take the whole first column and ensure addressing
this extra round too. In a twist, we note that we can take any element in any
row, so we will take player `8` instead of player `2`.

Hence this is a sufficient list for our purposes, with 12 elements inside:

```
1 3 4 5 6 7 8 13 19 25 31 37
```

## Relax: some pairs can face twice

In this case, the eighth round is the following:

```
round 8:
  (       7,  13,  19,  25,  31,  37)
  (       8,  14,  20,  26,  32,  38)
  (  3,   9,  15,       27,  33,  39)
  (  4,  10,       22,  28,  34,  40)
  (  5,  11,  17,  23,       35,  41)
  (  6,  12,       24,  30,  36,  42)
  (  1,   2,  21,  16,  18,  29     )
```

Again, the whole first match *plus* player `1` suffices to address every other
round. Again, all other matches in this round can be addressed by adding players
`3` to `8`, like in the previous section.

Hence this is a sufficient list for our purposes, with 12 elements inside (this
is the same list as the previous section):

```
1 3 4 5 6 7 8 13 19 25 31 37
```

# That's all folks!

What are you waiting for? Go set up a tournament!!!

If you want to take a look at all posts, here's the list:

- [Allocating games in tournaments][]
- [Allocating games in tournaments - example][]
- [Allocating games in tournaments - premium games and players][]
- [Allocating games in tournaments - 3 players practicalities][]
- [Allocating games in tournaments - 6 players matches][]
- [Allocating games in tournaments - 6 players matches, again][]
- [Allocating games in tournaments - 6 players matches, premium][]
- [Allocating games in tournaments - a program][]
- [Code repository][tournange]

[tournange]: https://gitlab.com/polettix/tournange
[Allocating games in tournaments - a program]: {{ '/2020/04/21/tournaments-program' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches, premium]: {{ '/2020/04/20/tournaments-6-players-premium' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches, again]: {{ '/2020/04/19/tournaments-6-players-again' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches]: {{ '/2020/04/18/tournaments-6-players' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 3 players practicalities]: {{ '/2020/04/17/tournaments-3-practical' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - premium games and players]: {{ '/2020/04/16/tournaments-premium' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - example]: {{ '/2020/04/15/tournaments-example' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments]: {{ '/2020/04/14/tournaments' | prepend: site.baseurl | prepend: site.url }}
[Social Golfer Problem]: https://www.metalevel.at/sgp/
[BoardGameArena]: https://boardgamearena.com/
[premium]: https://boardgamearena.com/premium
