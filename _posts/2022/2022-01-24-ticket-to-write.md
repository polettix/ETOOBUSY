---
title: Ticket to Write
type: post
tags: [ game, roll and write ]
comment: true
date: 2022-01-24 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm thinking about a transposition of the venerable [Ticket to
> Ride][].

[Ticket to Ride][] is an amazing and fun game. I actually played [Ticket
to Ride: Europe][], but the base game logic is the same.

Alas it's not exactly something that you might play around. There are a
lot of pieces, and it's easy to mess them on th board with a bump to the
table (e.g. while traveling).

This got me thinking about a *roll-and-write* transposition, using paper
sheets to keep track of stuff (deployed carts, cards in hand, stations,
...) and dice to simulate cards.

Here's where I arrived so far:

- *Colors*: we will consider six colors only, so that they can be mapped
  onto the six faces of a 6d die (some variants alraedy have six colors
  only). Well... actually we will get rid of colors completely, and only
  consider die faces.

- *Drawing tickets*: tickets are printed in a sheet, arranged in six
  groups of six tickets each. A die is rolled once to select a group,
  once again to get a ticket inside the group. If already taken, the
  next is taken, then the next, etc.

- *Drawing cards*: five dice are rolled and take the role of the five
  face-up cards. Each represents its value, except doubles that jointly
  represent a jolly card. Taking a card means marking a resource on
  one's sheet, then the die is re-rolled.

- *Drawing from the pile*: a die is rolled twice (or two, but in
  sequence), if the two rolls yield the same value then get a jolly,
  otherwise the last value that came out.

- *Using cards*: cross available cards on the tracking sheet and on the
  board too, in correspondence of the route to realize. Routes are
  marked with small dice picture to show the needed value (an empty
  square means any die value, as long as are all the same).

I'll try to prototype this in the coming days... I hope it works,
because I like the game but I don't play it often because of the
time/space it requires.

Stay safe!

[Ticket to Ride]: https://boardgamegeek.com/boardgame/9209/ticket-ride
[Ticket to Ride: Europe]: https://boardgamegeek.com/boardgame/14996/ticket-ride-europe
