---
title: 'Ticket to Write - thoughts'
type: post
tags: [ game, roll and write ]
comment: true
date: 2022-02-18 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm thinking about next steps with [Ticket to Write][]

I'm quite happy that [Ticket to Write][] [drew some interest][].

My main goal was to work within the constraints of having pen, papers
and a few dice, and try to re-create the overall experience with
substitute mechanisms relying on these game parts. That, I think, worked
OK.

On the other hand, I'm quite *disappointed* by the fact that it owes a
lot to [Ticket to Ride London][]: the graph of the map and, in one board
case, the mechanism for additional scoring. I have to admit that I chose
it because it had 6 colors (matching the 6 faces of the die) *and* I
thought that the graph was somehow "battle tested" and thus not boring.

The next step might be to come out with a different map/graph. Tickets
were already invented ex-novo because I didn't have a list of official
tickets *and* anyway I needed exactly 36 of them. They were manually
selected from the list of all possible candidates, with a small
pre-filtering.

But maybe I should just go one step up and code something that *finds
out* interesting setups by itself. Like coming up with a graph and some
tickets, and simulate many games to see how it scores. Which also means
coding what "fun" might be. *This* might be fun.

Well, now I wrote it, so I will not forget it and I'll be able to blame
myself for yet another thing that just got forgotten.

Stay safe folks!

[Perl]: https://www.perl.org/
[Ticket to Write]: {{ '/2022/01/29/ticket-to-write-playable/' | prepend: site.baseurl }}
[drew some interest]: https://boardgamegeek.com/filepage/234883/ticket-write-roll-and-write-print-and-play-inspire
[Ticket to Ride London]: https://boardgamegeek.com/boardgame/276894/ticket-ride-london
