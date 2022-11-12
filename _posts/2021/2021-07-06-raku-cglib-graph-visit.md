---
title: Graph visit algorithms in cglib-raku
type: post
tags: [ rakulang, cglib ]
comment: true
date: 2021-07-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I added graph visit algorithms to [cglib-raku][].

In a slow learning of [Raku][], I'm continuing to work on [cglib-raku][]
and I added two algorithms to visit a graph, i.e.
[BreadthFirstVisit.rakumod][] and [DepthFirstVisit.rakumod][].

They are pretty much a translation of their counterparts in [Perl][]. I
took the occasion to make their interfaces uniform, adding hooks where
they were missing. It's also nice to be able to add a `MAIN` function
with some basic tests.

Now I hope there will be some *challenge* that will allow me to use
them 😎

[cglib-raku]: https://github.com/polettix/cglib-raku
[Raku]: https://raku.org/
[BreadthFirstVisit.rakumod]: https://github.com/polettix/cglib-raku/blob/main/BreadthFirstVisit.rakumod
[DepthFirstVisit.rakumod]: https://github.com/polettix/cglib-raku/blob/main/DepthFirstVisit.rakumod
[Perl]: https://www.perl.org/
