---
title: 'Evolution in Data::Resolver'
type: post
tags: [ perl ]
comment: true
date: 2023-05-15 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Evolving [Data::Resolver][]

While trying to move on with [PDF::Collage][], I figured that the next step
would be to fully adopt [Data::Resolver][]'s new OOP interface, get rid of
all the overloading over one single sub call as in the previous iteration,
and finally embrace the new asset-oriented interface.

Such good intentions made a big loud noise while crashing against reality.

It turns out that the directory-based interface was pretty much to the
point, while the TAR-based had some restrictions that surely were attractive
at coding time, but proved to make the interface cumbersome while actually
using it.

What? Well, asking for a key that has a hierarchy in it (like `foo/bar.txt`,
which has a directory/container part, as well as a file/content part) is
processed fine in the directory case, but it *was* stopped in the TAR
alternative.

This is no more the case in the newest trial release, though!

Just as an added bonus, I also decided to force a Unix syntax to all
hierarchical keys in the directory case. It might seem arbitrary, but I
think that it's probably something that helps with portability as keys are
meant to go *beyond* the system. Plus I like Unix much better and the TAR
interface sticks to it anyway.

So there we go, [Data-Resolver-0.005-TRIAL][newmod] is out, and I'm crossing
fingers seeking feedback from CPAN Testers!

Stay safe!

[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[PDF::Collage]: https://metacpan.org/pod/PDF::Collage
[newmod]: https://metacpan.org/release/POLETTIX/Data-Resolver-0.005-TRIAL
