---
title: Allocating games in tournaments - 6 players matches
type: post
tags: [ algorithm, game, maths, boardgamearena, perl ]
comment: true
date: 2020-04-18 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Tournaments for games with 6 players are... *hard* to set up. We might even
> conjecture impossible. Let's see a sub-optimal approach.

Let's recap our wishlist for tournaments:

- each player should compete against each other exactly once
- in matches with $k$ players each
- in rounds that allow all participants to play at the same time
- with the least amount of overall players

This allows everybody to play an adequate amount of matches, provides
variety (and avoids cheating!), allows playing games that are best with
multiple players, avoids dead times and are easier to set up.

# 6 players matches are tricky

In [Allocating games in tournaments - example][] we started investigating
finite affine planes to build such tournaments, and ended up with the
following table:

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

Alas, the affine plane approach is not applicable to 6-players games because
$6$ is not a power of a prime (it is, in fact, the product of two different
primes $2 \cdot 3$).

On the one hand I think it's extremely lucky that this is the only case for
integers below $10$ - it could have been worse; on the flip side, many games
are actually enjoyable with $6$ players!

# Relax

As it happens, we need to relax some of our requirements to cope with $6$
players matches.

The first requirement is actually quite strict and contains two constraints:

- everybody should play against everybody - i.e. every pair of players should
  end up in at least one match;
- everybody should not play against someone else more than once - i.e. every
  pair of players must compete against everybody else exactly once.

In this case, we have to give up on the *exactly once* constraint:

- either we make sure everybody plays with anyone else *at least* once,
  allowing for some or all pairs to compete twice against each other, OR
- we ensure that anyone competes *at most* once against each other player.

The second approach is the one usually considered in the [Social Golfer
Problem][]. We will take a look at one approach that allows for either way.

# Let's start bigger

Let's start with the next feasible design that addresses all requirements:
the case for 7-players matches. Here is its scheduling for $49$ players:

```
round 1:
  (  1,   2,   3,   4,   5,   6,   7)
  (  8,  14,  20,  26,  32,  38,  44)
  (  9,  15,  21,  27,  33,  39,  45)
  ( 10,  16,  22,  28,  34,  40,  46)
  ( 11,  17,  23,  29,  35,  41,  47)
  ( 12,  18,  24,  30,  36,  42,  48)
  ( 13,  19,  25,  31,  37,  43,  49)

round 2:
  (  1,   8,   9,  10,  11,  12,  13)
  (  2,  14,  21,  28,  35,  42,  49)
  (  3,  15,  23,  31,  32,  40,  48)
  (  4,  16,  25,  27,  36,  38,  47)
  (  5,  17,  20,  30,  33,  43,  46)
  (  6,  18,  22,  26,  37,  41,  45)
  (  7,  19,  24,  29,  34,  39,  44)

round 3:
  (  1,  14,  15,  16,  17,  18,  19)
  (  2,  13,  20,  27,  34,  41,  48)
  (  3,  12,  21,  29,  37,  38,  46)
  (  4,  11,  22,  31,  33,  42,  44)
  (  5,  10,  23,  26,  36,  39,  49)
  (  6,   9,  24,  28,  32,  43,  47)
  (  7,   8,  25,  30,  35,  40,  45)

round 4:
  (  1,  20,  21,  22,  23,  24,  25)
  (  2,  12,  19,  26,  33,  40,  47)
  (  3,  10,  18,  27,  35,  43,  44)
  (  4,   8,  17,  28,  37,  39,  48)
  (  5,  13,  16,  29,  32,  42,  45)
  (  6,  11,  15,  30,  34,  38,  49)
  (  7,   9,  14,  31,  36,  41,  46)

round 5:
  (  1,  26,  27,  28,  29,  30,  31)
  (  2,  11,  18,  25,  32,  39,  46)
  (  3,   8,  16,  24,  33,  41,  49)
  (  4,  12,  14,  23,  34,  43,  45)
  (  5,   9,  19,  22,  35,  38,  48)
  (  6,  13,  17,  21,  36,  40,  44)
  (  7,  10,  15,  20,  37,  42,  47)

round 6:
  (  1,  32,  33,  34,  35,  36,  37)
  (  2,  10,  17,  24,  31,  38,  45)
  (  3,  13,  14,  22,  30,  39,  47)
  (  4,   9,  18,  20,  29,  40,  49)
  (  5,  12,  15,  25,  28,  41,  44)
  (  6,   8,  19,  23,  27,  42,  46)
  (  7,  11,  16,  21,  26,  43,  48)

round 7:
  (  1,  38,  39,  40,  41,  42,  43)
  (  2,   9,  16,  23,  30,  37,  44)
  (  3,  11,  19,  20,  28,  36,  45)
  (  4,  13,  15,  24,  26,  35,  46)
  (  5,   8,  18,  21,  31,  34,  47)
  (  6,  10,  14,  25,  29,  33,  48)
  (  7,  12,  17,  22,  27,  32,  49)

round 8:
  (  1,  44,  45,  46,  47,  48,  49)
  (  2,   8,  15,  22,  29,  36,  43)
  (  3,   9,  17,  25,  26,  34,  42)
  (  4,  10,  19,  21,  30,  32,  41)
  (  5,  11,  14,  24,  27,  37,  40)
  (  6,  12,  16,  20,  31,  35,  39)
  (  7,  13,  18,  23,  28,  33,  38)
```

As we can see, players `1` to `7` always compete in different matches in all
rounds *except round 1*. If we remove them, then, as well as round 1, all other
rounds from 2 to 8 will contain non-overlapping matches with 6 participants
each, with the additional bonus that no two players ever compete against each
other more than once. Renumbering the rounds we end up with:

```
round 1:
  (      8,  *9, *10, *11, *12, *13)
  (     14,  21,  28,  35,  42,  49)
  (     15,  23,  31,  32,  40,  48)
  (     16,  25,  27,  36,  38,  47)
  (     17,  20,  30,  33,  43,  46)
  (     18,  22,  26,  37,  41,  45)
  (     19,  24,  29,  34,  39,  44)

round 2:
  (     14,  15,  16,  17,  18,  19)
  (     13,  20,  27,  34,  41,  48)
  (     12,  21,  29,  37,  38,  46)
  (     11,  22,  31,  33,  42,  44)
  (     10,  23,  26,  36,  39,  49)
  (      9,  24,  28,  32,  43,  47)
  (      8,  25,  30,  35,  40,  45)

round 3:
  (     20,  21,  22,  23,  24,  25)
  (     12,  19,  26,  33,  40,  47)
  (     10,  18,  27,  35,  43,  44)
  (      8,  17,  28,  37,  39,  48)
  (     13,  16,  29,  32,  42,  45)
  (     11,  15,  30,  34,  38,  49)
  (      9,  14,  31,  36,  41,  46)

round 4:
  (     26,  27,  28,  29,  30,  31)
  (     11,  18,  25,  32,  39,  46)
  (      8,  16,  24,  33,  41,  49)
  (     12,  14,  23,  34,  43,  45)
  (      9,  19,  22,  35,  38,  48)
  (     13,  17,  21,  36,  40,  44)
  (     10,  15,  20,  37,  42,  47)

round 5:
  (     32,  33,  34,  35,  36,  37)
  (     10,  17,  24,  31,  38,  45)
  (     13,  14,  22,  30,  39,  47)
  (      9,  18,  20,  29,  40,  49)
  (     12,  15,  25,  28,  41,  44)
  (      8,  19,  23,  27,  42,  46)
  (     11,  16,  21,  26,  43,  48)

round 6:
  (     38,  39,  40,  41,  42,  43)
  (      9,  16,  23,  30,  37,  44)
  (     11,  19,  20,  28,  36,  45)
  (     13,  15,  24,  26,  35,  46)
  (      8,  18,  21,  31,  34,  47)
  (     10,  14,  25,  29,  33,  48)
  (     12,  17,  22,  27,  32,  49)

round 7:
  (     44,  45,  46,  47,  48,  49)
  (      8,  15,  22,  29,  36,  43)
  (      9,  17,  25,  26,  34,  42)
  (     10,  19,  21,  30,  32,  41)
  (     11,  14,  24,  27,  37,  40)
  (     12,  16,  20,  31,  35,  39)
  (     13,  18,  23,  28,  33,  38)
```

# A relaxed solution

We can, of course, renumber the player identifiers as well, from range $8..49$
to a more natural $1..42$, and get the following arrangement:

```
round 1:
  (  1,   2,   3,   4,   5,   6)
  (  7,  14,  21,  28,  35,  42)
  (  8,  16,  24,  25,  33,  41)
  (  9,  18,  20,  29,  31,  40)
  ( 10,  13,  23,  26,  36,  39)
  ( 11,  15,  19,  30,  34,  38)
  ( 12,  17,  22,  27,  32,  37)

round 2:
  (  1,  18,  23,  28,  33,  38)
  (  2,  17,  21,  25,  36,  40)
  (  3,  16,  19,  29,  32,  42)
  (  4,  15,  24,  26,  35,  37)
  (  5,  14,  22,  30,  31,  39)
  (  6,  13,  20,  27,  34,  41)
  (  7,   8,   9,  10,  11,  12)

round 3:
  (  1,  10,  21,  30,  32,  41)
  (  2,   7,  24,  29,  34,  39)
  (  3,  11,  20,  28,  36,  37)
  (  4,   8,  23,  27,  31,  42)
  (  5,  12,  19,  26,  33,  40)
  (  6,   9,  22,  25,  35,  38)
  ( 13,  14,  15,  16,  17,  18)

round 4:
  (  1,   9,  17,  26,  34,  42)
  (  2,  12,  15,  28,  31,  41)
  (  3,   8,  13,  30,  35,  40)
  (  4,  11,  18,  25,  32,  39)
  (  5,   7,  16,  27,  36,  38)
  (  6,  10,  14,  29,  33,  37)
  ( 19,  20,  21,  22,  23,  24)

round 5:
  (  1,  12,  16,  20,  35,  39)
  (  2,  11,  13,  22,  33,  42)
  (  3,  10,  17,  24,  31,  38)
  (  4,   9,  14,  19,  36,  41)
  (  5,   8,  18,  21,  34,  37)
  (  6,   7,  15,  23,  32,  40)
  ( 25,  26,  27,  28,  29,  30)

round 6:
  (  1,  11,  14,  24,  27,  40)
  (  2,   9,  16,  23,  30,  37)
  (  3,   7,  18,  22,  26,  41)
  (  4,  12,  13,  21,  29,  38)
  (  5,  10,  15,  20,  25,  42)
  (  6,   8,  17,  19,  28,  39)
  ( 31,  32,  33,  34,  35,  36)

round 7:
  (  1,   8,  15,  22,  29,  36)
  (  2,  10,  18,  19,  27,  35)
  (  3,  12,  14,  23,  25,  34)
  (  4,   7,  17,  20,  30,  33)
  (  5,   9,  13,  24,  28,  32)
  (  6,  11,  16,  21,  26,  31)
  ( 37,  38,  39,  40,  41,  42)
```

This solution has the following characteristics:

- everybody plays the same number of rounds;
- always against different competitors;
- each player competes *almost* with every one else;
- never more than once, anyway.

In other terms, we preserve that no two participants ever compete against
each other twice (or more), at the cost of never making some players
compete against each other.

Not bad!

# Different relaxation?

What if we allow relaxing differently, and allow pairs of players to
compete more than once at the same match in the tournament? Stay tuned!

If you want to take a look at all posts, here's the list:

- [Allocating games in tournaments][]
- [Allocating games in tournaments - example][]
- [Allocating games in tournaments - premium games and players][]
- [Allocating games in tournaments - 3 players practicalities][]
- [Allocating games in tournaments - 6 players matches][]

[Allocating games in tournaments - 6 players matches]: {{ '/2020/04/18/tournaments-6-players' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - 3 players practicalities]: {{ '/2020/04/17/tournaments-3-practical' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments]: {{ '/2020/04/14/tournaments' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - example]: {{ '/2020/04/15/tournaments-example' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - premium games and players]: {{ '/2020/04/16/tournaments-premium' | prepend: site.baseurl | prepend: site.url }}
[Social Golfer Problem]: https://www.metalevel.at/sgp/
[Allocating games in tournaments]: {{ '/2020/04/14/tournaments/' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - example]: {{ '/2020/04/15/tournaments-example/' | prepend: site.baseurl | prepend: site.url }}
