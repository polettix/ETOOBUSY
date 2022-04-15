---
title: 'Echoes from the past: LavaRnd'
type: post
tags: [ random, security ]
comment: true
date: 2022-04-15 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I found an old website from the past: [LavaRnd][].

It's no secret that I've always been fascinated by random numbers
generation ([Random bytes and co.][], [Crypt::URandom][], [A 4-faces die
from a 6-faces die][426], ...). As a student in University, I spent lot*
of time dealing with the *signal* part, so the fact that generating
*good noise* is actually difficult to *get right* is both
counter-intuitive and amazing.

So a lot of time ago I stumbled upon [LavaRnd][], and found it very
interesting at the time. As I found it again now, it's amusing how it
came with a [Perl][] suite of modules:

> Perl programmers should use the perldoc command:
>
>     perldoc LavaRnd::Exit
>     perldoc LavaRnd::Retry
>     perldoc LavaRnd::Return
>     perldoc LavaRnd::S100_Any
>     perldoc LavaRnd::TryOnce_Any
>     perldoc LavaRnd::Try_Any
>
> to learn how to use the Perl interface.

Alas, it was so much easier to be a [Perl][] programmer in the early
2000 🙄

Today, I have to admit that I'm not totally convinced of
the scrambling approach: I'd probably prefer an approach that removes
the *signal* to only keep the noise (e.g. by subtracting two consecutive
sample images), but I understand that the devil is in the details,
including how the data from the CCD are taken and transferred (possibly
without any processing).

There also seem to be a lot of similar approaches that flourished in
time, e.g. [Quantum Random Number Generation on a Mobile
Phone][sanguinetti], where by *similar* I mean *using a camera to get
some randomness from around*.

All in all... this is *fascinating*. Stay safe please!


[Perl]: https://www.perl.org/
[LavaRnd]: https://www.lavarand.org/index.html
[Random bytes and co.]: {{ '/2021/05/31/random-bytes-and-co/' | prepend: site.baseurl }}
[Crypt::URandom]: {{ '/2021/06/04/crypt-urandom/' | prepend: site.baseurl }}
[426]: {{ '/2020/05/11/d6-to-d4/' | prepend: site.baseurl }}
[sanguinetti]: https://journals.aps.org/prx/pdf/10.1103/PhysRevX.4.031056
