---
title: Allocating games in tournaments - example
type: post
tags: [ algorithm, game, maths, boardgamearena ]
comment: true
date: 2020-04-15 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> After looking briefly at a promising way to arrange tournaments for
> multi-player games, let's look at a few practical examples.

By *example* here we will also consider something a bit more...
*theoretical*. In particular, we will focus on games with more than two
players inside, and see where it goes.

# Arrangements for multi-player games: numbers

As already discussed in previous post [Allocating games in tournaments][],
finite affine planes are a promising way to get some tournament scheduled.
BIBDs based on affine planes have the following characteristics:

- $n$ is the number of players in each match;
- $n^2$ is the total number of players in the tournament;
- $n + 1$ is the number of rounds played, corresponding to the number of
  games played by each participant;
- $n\cdot(n+1$ is the overall number of games played in the whole
  tournament.

This leads us to the following table:

| players/game | rounds | total players | total games |
| $n$ | $n + 1$ | $n^2$ | $n \cdot (n + 1)$ |
|:---:|:---:|:---:|:---:|
| 2 | 3 | 4 | 6 |
| 3 | 4 | 9 |12 |
| 4 | 5 |16 |20 |
| 5 | 6 |25 |30 |
| 7 | 8 |49 |56 |
| 8 | 9 |64 |72 |
| 9 |10 |81 |90 |

Rows from $n = 5$ on become increasingly trickier because of the quick
growth in the number of participants needed to arrange the tournament, but
are anyway left for completeness.

You surely noticed the lack of an alternative for $n = 6$. It so happens
that there is no finite projective plane possible for it, so we're just
leaving it out.

# Example: 3-players games

This is the arrangement of lines for order-3 projective plane:

```
  0. (1, 4, 7, 10)
  1. (0, 4, 5, 6)
  2. (3, 4, 9, 11)
  3. (2, 4, 8, 12)
  4. (0, 1, 2, 3)
  5. (1, 6, 9, 12)
  6. (1, 5, 8, 11)
  7. (0, 10, 11, 12)
  8. (3, 6, 8, 10)
  9. (2, 5, 9, 10)
 10. (0, 7, 8, 9)
 11. (2, 6, 7, 11)
 12. (3, 5, 7, 12)
```

As before, we get rid of one line and all points inside, let's choose line 7
and points `0`, `10`, `11`, and `12`:

```
  0. (1, 4, 7, 10)   --> (1, 4, 7)
  1. (0, 4, 5, 6)    --> (4, 5, 6)
  2. (3, 4, 9, 11)   --> (3, 4, 9)
  3. (2, 4, 8, 12)   --> (2, 4, 8)
  4. (0, 1, 2, 3)    --> (1, 2, 3)
  5. (1, 6, 9, 12)   --> (1, 6, 9)
  6. (1, 5, 8, 11)   --> (1, 5, 8)
  7. (0, 10, 11, 12) -->
  8. (3, 6, 8, 10)   --> (3, 6, 8)
  9. (2, 5, 9, 10)   --> (2, 5, 9)
 10. (0, 7, 8, 9)    --> (7, 8, 9)
 11. (2, 6, 7, 11)   --> (2, 6, 7)
 12. (3, 5, 7, 12)   --> (3, 5, 7)
```

To get the different rounds easily, it's sufficient to look for all groups
in the left hand side that share the same removed point:

```
round 1: (1, 4, 7) (3, 6, 8) (2, 5, 9)
round 2: (4, 5, 6) (1, 2, 3) (7, 8, 9)
round 3: (3, 4, 9) (1, 5, 8) (2, 6, 7)
round 4: (2, 4, 8) (1, 6, 9) (3, 5, 7)
```

# So long... for now!

If you want to take a look at all posts, here's the list:

- [Allocating games in tournaments][]
- [Allocating games in tournaments - example][]
- [Allocating games in tournaments - premium games and players][]
- [Allocating games in tournaments - 3 players practicalities][]
- [Allocating games in tournaments - 6 players matches][]
- [Allocating games in tournaments - 6 players matches, again][]

[Allocating games in tournaments - 6 players matches, again]: {{ '/2020/04/19/tournaments-6-players-again' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 6 players matches]: {{ '/2020/04/18/tournaments-6-players' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 3 players practicalities]: {{ '/2020/04/17/tournaments-3-practical' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - premium games and players]: {{ '/2020/04/16/tournaments-premium' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - example]: {{ '/2020/04/15/tournaments-example' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments]: {{ '/2020/04/14/tournaments' | prepend: site.baseurl | prepend: site.url }}
[Math::GF]: https://metacpan.org/pod/Math::GF
