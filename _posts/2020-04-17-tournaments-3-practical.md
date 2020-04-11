---
title: Allocating games in tournaments - 3 players practicalities
type: post
tags: [ game, boardgamearena, google docs ]
comment: true
date: 2020-04-17 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> After much talking about tournaments for multi-player games, let's
> look at a practical example for a tournament of 3-players matches.

First things first: [BoardGameArena][] is an amazing site and you should
consider becoming a [premium][] member to support the folks.

If you just jumped here and want to know a bit what this is all about,
start from [Allocating games in tournaments][] and then come back.

Here, we will consider the practicalities of setting up a tournament for
games that are good for 3 players (e.g. [Tokaido][], [7 Wonders][],
[Roll for the Galaxy][], and [Takenoko][] come to mind).

# Find players

You will need 9 players for this tournament.

If the game restricts table creation to [premium][] players, you will
need to make sure that 5 of the 9 participants are [premium][] ones. 

Personally, I think this is the most challenging part of organizing the
tournament!


# Agree about timing

Each player will compete in exactly 4 rounds; all matches in a round are
played at the same time, so there are very limited wait times.

Discuss with the participants how long the playing sessions can be, or
better start with a proposal (e.g. one-hour long). Depending on the
specific game, you might be able to arrange a single round, several, or
all of them in the agreed amount of time.

After this, head over an online poll tool to agree when to allocate the
needed time slots, e.g. [Doodle][] or one of its
[alternatives][doodle-alternatives].


# Decide on points assignment & other rules

Before starting, make sure to set (or agree) all relevant constraints
for the tournament.

## Point system

Make sure that your points system is fair across all matches. One
possible arrangement is as follows:

- $A$ points for first place, $B$ points for second place, and $C$
  points for third place
- If two players end up with in the same place, they divide the points
  of that place and the following one evenly
  - if they are both first, they get $\frac{A + B}{2}$ points each;
  - if they are both second, they get $\frac{B + C}{2}$ points each;
- If all players end up in the first place, the divide all points (i.e.
  they get $\frac{A + B + C}{3}$ points)

One easy way to do this is to set $A = 6$, $B = 4$, and $C = 2$; in this
way, any situation will yield an integer amount of points, like this:

![points awarded]({{ '/assets/images/points-per-ranking.png' | prepend: site.baseurl | prepend: site.url }})

## No-show, timeouts

Agree on a policy for players that do not show up or time out. Example:

- not showing up yields 0 points and gives the match to the participants
  that showed up, who end up 1st place.
- $0 < t \leq X$ minutes: 1 point penalty
- $t > X$ : last place in ranking (to allow calculating the points of
  other players) and no points


# Set up tracking

To track the tournament, you can use [this spreadsheet][template].

If you have an account on Google, you can go to `File`, then `Make a
copy` and start filling it on the spot. otherwise, you can download it
(via `File`, then `Download`) in a number of formats, and use some tools
on your PC to customize and update it.

Adjust to your needs:

- sheet `Dashboard`: set tournament name and other relevant data, as
  well as the participants nicknames in the yellow/green cells. Cell
  colors are meaningful only for [premium][] games; ensure to fill the
  yellow ones with [premium][] users in this case;
- sheet `Rounds`: adjust the points assignment table according to the
  rules you agreed;
- sheet `Policy`: write down a reminder of the rules agreed (e.g.
  penalties) so that everyone is cool with them.

# Play!

Now you just have to play! Head to sheet `Rounds` and set up matches
according to the table for the relevant Round. Participants with the
same color compete in the same match.

For [premium][] games, the tournament scheduling is such that each match
contains *at least* one [premium][] user, who will be in charge of
creating the table; otherwise, any player in a match can do this, of
course.

After each match is concluded, put the points awarded to each player in
the match, taking into account penalties in the `Policy` sheet if any.

Sheet `Dashboard` provides an updated view of the leaderboard with the
data available. At the end of the tournament, you will be able to see
who is the winner!

# So long for now...

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
[Tokaido]: https://boardgamearena.com/gamepanel?game=tokaido
[7 Wonders]: https://boardgamearena.com/gamepanel?game=sevenwonders
[Roll for the Galaxy]: https://boardgamearena.com/gamepanel?game=rollforthegalaxy
[Takenoko]: https://boardgamearena.com/gamepanel?game=takenoko
[template]: https://docs.google.com/spreadsheets/d/18HtxoYaWkDFosn2uUlZxDCwxS-7HvBrrkLcas_3N6Xk/edit?usp=sharing
[Doodle]: https://doodle.com/
[doodle-alternatives]: https://alternativeto.net/software/doodle/
[BoardGameArena]: https://boardgamearena.com/
[premium]: https://boardgamearena.com/premium
