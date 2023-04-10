---
title: Rearviewmirror on Kasai!
type: post
tags: [ perl, game, handheld ]
comment: true
date: 2023-04-10 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I took a look back at an old project, described in [Kasai!][].

I remember when a lot of my time was spent over re-creating a prototype for
old hand-held games from my childhood. What I didn't remember until a few
minutes ago was that it more or less happened in coincidence with my
resolution to write one post per day back at the end of 2019.

It does not surprise me: I was probably looking for something *different* to
do after proving myself that I could put up a workable prototype.

I can, anyway, provide some of the then sought feedback to the past me,
which I hope will be sufficiently constructive.

1. Dumping *a lot* of code without even a `README.md` in the repository is
   the best way to get something ignored and higly disrespectful of whoever
   you could happen to be talking to. Pile on with a systematic (systemic?)
   lack of documentation and we're set up for failure. **Admittedly**, I can
   think that the blog post served the role of the `README.md` and that the
   lack of documentation for the code does no harm to people who just want
   to try out the game.

2. The timing approach seems *weird* and needs some reworking. When the game
   speeds up, so does the pause after a miss and I sort of remember that
   this was not the experience at the time (like two beeps, the savers
   flashing together with the missed person). Also, acceleration through the
   game might be smoother.

3. There does not seem to be any mechanism to get lives back, which seems to
   go against memory.

4. Overall I enjoyed playing the game again, though, so it's a nice
   prototype. I would like to see different combinations, as well as games
   of *type B* (together with people going down from the lower floor too).

There you go, past me! Well... I guess that in lack of past me, I'll have to
read and use this beautiful feedback... or ignore it for another three
years and some.

Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Kasai!]: {{ '/2019/12/29/kasai/' | prepend: site.baseurl }}
