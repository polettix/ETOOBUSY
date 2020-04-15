---
title: Allocating games in tournaments - premium games and players
type: post
tags: [ algorithm, game, maths, boardgamearena ]
comment: true
date: 2020-04-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> [BoardGameArena][] restricts the creation of tables for some selected
> games only to *premium users*. How does this affect tournament
> arrangements?

# What's the issue?

First and foremost: [BoardGameArena][] is an amazing site and you're totally
encouraged to [go premium][premium]. Everybody has its own financials, though, and
not all players are premium ones.

The *amazing* thing about [BoardGameArena][] is that you're in no way
prevented from playing premium games; the only restriction is that you have
to wait for some other player to create a table for that game.

This, of course, affects the creation of multi-player tournaments of
premium games. How many premium members have to be in these tournaments? How
should they be arranged?

Let's take a closer look!

# Let's start with a couple examples

Let's see a couple of examples for less-crowded tournaments.

## Two-player games

Let's start simple: a tiny round-robin tournament of 4 players in
two-players games:

```
1st round: (1, 2) (3, 4)
2nd round: (1, 3) (2, 4)
3rd round: (1, 4) (2, 3)
```

It's easy to see that we need three premium users here. As soon as player
`1` is not premium, in fact, all the other ones need to be premium to be
able to start the first table in the three rounds. So this is it: for $n=2$,
the total number of players is $n^2 = 4$ and we need 3 of them to be
premium.

## Three-player games

Let's now consider three-players matches:

```
round 1: (1, 4, 7) (3, 6, 8) (2, 5, 9)
round 2: (4, 5, 6) (1, 2, 3) (7, 8, 9)
round 3: (3, 4, 9) (1, 5, 8) (2, 6, 7)
round 4: (2, 4, 8) (1, 6, 9) (3, 5, 7)
```

Let's first select `1` as a premium user (anybody can do at this point):

```
round 1: (1, 4, 7)
round 2:           (1, 2, 3)
round 3:           (1, 5, 8)
round 4:           (1, 6, 9)
```

So, *in theory*, at this point every other player might be non-premium. But
of course there are other matches to cater for. We addressed 4 tables, which
is the maximum we could do with one single premium player.

Let's now select the first match `(1, 4, 7)`, and decide that also the other
two players are premium. We are going to surely include additional tables,
because we already know that this first table is the only one where any pair
of `1`, `4`, and `7` appear at the same time.

```
round 1: (1, 4, 7)
round 2: (4, 5, 6) (1, 2, 3) (7, 8, 9)
round 3: (3, 4, 9) (1, 5, 8) (2, 6, 7)
round 4: (2, 4, 8) (1, 6, 9) (3, 5, 7)
```

As a matter of fact, each of them addresses 3 additional games, again
because the only game where they encounter each other is the first one,
which we already *assigned* to `1`.

Now, we're *only* left to choose exactly one additional player in each of
the tables of the first round. This can be easily done by choosing any table
with `1` in another round, and take all of the other players as premium.
Let's take `(1, 2, 3)` from the second round then:

```
round 1: (1, 4, 7) (3, 6, 8) (2, 5, 9)
round 2: (4, 5, 6) (1, 2, 3) (7, 8, 9)
round 3: (3, 4, 9) (1, 5, 8) (2, 6, 7)
round 4: (2, 4, 8) (1, 6, 9) (3, 5, 7)
```

Now everything is accounted for, with the following premium users: `1`, `2`,
`3`, `4`, and `7`. It's 5 players out of the total of 9 - which starts being
better than the two-player games example we saw before!

# Generalizing premium selection

The example for three-players games shows us a way to understand how many
premium users we need, and how to select them.

For $n$-players games, we have to account for $n \cdot (n + 1)$ total
matches, played by $n^2$ players (assuming they are indexed from `1` on),
each playing $n + 1$ matches.

Let's consider player `1`, and any two matches (let's call them A and B)
where this player participates. We claim that making all the players in this
matches premium is sufficient to cover the whole tournament.

Making `1` premium, of course, addresses $n + 1$ matches, i.e. all matches
where `1` participates, including matches A and B.

At this point, let's make all *other* $n - 1$ players in match A premium. By
construction, match A is the only one in which any pair of them is in the
same game, which means that each of them is now capable of addressing
additional $n$ games (i.e. all games for each player, except game A itself).
So far, then, we covered $(n + 1) + (n - 1) \cdot n = n^2 + 1$ matches.

Now let's consider match B. Each, of course, participates in B itself
(addressed by `1`), as well as exactly one match with each participant in
match A that is not `1`, because we already counted all those matches; in
other terms, they already participate into $n$ matches that are already
addressed by some other player. Out of the $n + 1$, then, one is left out,
which means that making them premium will address them, for a total of $n -
1$ additional matches addressed (we don't count match B of course).

So, we covered $n^2 + 1 + n - 1 = n^2 + n = n \cdot (n + 1)$ matches, i.e.
all of them.

Summarizing, how many players should be made premium? There are $n$ players
in match A and $n$ in match B, with `1` shared between them, so the number
we are after is $2n - 1$. I suspect that this is also the minimum number of
players, but I'm not seeing the proof at the moment.

Here's a table of needed premium players for each case:

| players/game | players | premium |
| $n$   | $n^2$ | $2n - 1$ |
| :---: | :---: | :---:    |
| 2 | 4 | 3 |
| 3 | 9 | 5 |
| 4 |16 | 7 |
| 5 |25 | 9 |
| 7 |49 | 11 |
| 8 |64 | 13 |
| 9 |81 | 15 |

# Conclusions

Arranging tournaments for premium games is definitely doable. Although
generally *less open* than individual games, where only one premium user is
strictly needed, they are reasonably open anyway, even more so as the number
of players per game increases.

If you want to take a look at all posts, here's the list:

- [Allocating games in tournaments][]
- [Allocating games in tournaments - example][]
- [Allocating games in tournaments - premium games and players][]

[Allocating games in tournaments]: {{ '/2020/04/14/tournaments' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - example]: {{ '/2020/04/15/tournaments-example' | prepend: site.baseurl | prepend: site.url }}
[Allocating games in tournaments - premium games and players]: {{ '/2020/04/16/tournaments-premium' | prepend: site.baseurl | prepend: site.url }}
[BoardGameArena]: https://boardgamearena.com/
[premium]: https://boardgamearena.com/premium
