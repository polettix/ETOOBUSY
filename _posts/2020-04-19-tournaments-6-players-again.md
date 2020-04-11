---
title: Allocating games in tournaments - 6 players matches, again
type: post
tags: [ algorithm, game, maths, boardgamearena, perl ]
comment: true
date: 2020-04-19 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where we continue our quest for a tournament scheduling for matches with 6
> players.

In [Allocating games in tournaments - 6 players matches][] we ended up with an
arrangement that is compliant with the requirements of the [Social Golfer
Problem][], i.e. that participants never compete against each other more than
once.

How these golfers can really be called social beats me though. If they're
this social, they shouldn't mind playing twice with the same person every
now and then, should they? Anyway.

# What's missing

To understand what we are missing, let's remember what we did to get the
schedule:

- we started from an affine-plane based schedule for matches with
  7 players each
- then removed the first 7 players, and
- the whole first round.

Let's look at this removed round, then, with the re-numbering we already
did the last time (i.e. $8..49$ mapped onto $1..42$):

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


Each non-empty match here shows us which players will not compete against
each other. As an example, players `1` and `7` appear in the same match,
so we are sure that they do not compete against each other in any of the
rounds that we kept (because of how the matches have been designed in the
first place).

# What to do about it?

There are a few things that might be done about it...

## Ignore the round

The first possible thing to do is to just ignore the round, and fall back
to the solution we discussed in the previous post. Nothing more to see
here.

## Relax: number of participants in a match

How about a tournament where matches are *normally* arranged for 6 people,
but one of them contains 7? Many games would allow this, so why not?

This would be the eight round then:

```
round 8:
  (  1,   7,  13,  19,  25,  31,  37)
  (  2,   8,  14,  20,  26,  32,  38)
  (  3,   9,  15,  21,  27,  33,  39)
  (  4,  10,  16,  22,  28,  34,  40)
  (  5,  11,  17,  23,  29,  35,  41)
  (  6,  12,  18,  24,  30,  36,  42)
```

This has the advantage that each player would compete against each other
*exactly once* (yay!) and would not need to relax anything only for
a subset of players, which might be considered... *less fair* (e.g. what
if people competing twice or more strike a cheating deal?!?).

## Relax: some pairs can face twice

If it's nothing too official, and the risk of cheating is low (with *risk*
assumed to be the product of *probability* and *damage* of cheating), then
we can arrange one more round where only a bare minimum of players will
face each other for the second time:

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

In short, we removed one participant from each 7-players match and put all
of them in an additional match (the last one). In this way, only those
players (i.e. `1`, `2`, `21`, ...) will face each other for the second
time in the tournament, while the others will still comply with the
[Social Golfer Problem][] requirements.

The choice of players for the last match is not random. We could of course
have taken the first player in each of the previous ones (i.e. players `1`
to `6`), but this would have been a sheer repetition of the very first
match in the very first round, which is admittedly boring. So, we opted
for making at least sure that no three players in that match ever played
at the same table at the same time in a previous round, which you can
easily verify.

Characteristics:

- still there are pairs of players that didn't play against each other. As
  an example, in this arrangement player `1` never gets to play against
  players `7`, `13`, ..., i.e. all players in the first match of the
  additional eighth round;
- this *lack of completeness* is unbalanced, too: while player `7` does
  not get to ever play with player `1` *only*, player `1` does not get to
  ever play with six other players;
- the asymmetry also shows up in that only a few players get to face each
  other twice;
- on the good side, we have another round of 6-players matches!


# Summary

This post contains three possible alternatives for tournaments of matches with
6 players... Now the choice is yours! Stay tuned, though: we still have to
elaborate a bit about premium players...

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
