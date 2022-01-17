---
title: 'Data::Tubes release and... how cool is CPAN Testers?!?'
type: post
tags: [ perl, module, cpan ]
comment: true
date: 2022-01-18 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I recently released a small update on [Data::Tubes][] and, time and
> again, was caught in awe of how cool CPAN Tester is.

My module [Data::Tubes][] covers a niche that was very handy for me some
years ago, but sometimes I have some computations to do where I use it
because of the ease of adding/removing stuffs in a pipeline of record
massaging.

I know that I'm probably the only one to appreciate its usefulness, but
to be honest its niche is pretty... tight, and I already spent enough
energy in providing documentation for it. To the point that **I** still
find it useful after a few years, and have a good time navigating
through the docs to get the job done. Hive five, past me!

Recently I did a new release, which added a little *do what I mean*
feature. Actually, I was expecting that feature to be already there
(it's an automatic generation of a tube from an array-based definition,
which is also pervasively implemented around), so it gave me the
possibility to keep the project alive, altough very letargically.

In all of this, the real shining star, and unfortunately too rarely sung
hero, is [CPAN Testers][]. Every time I upload my *barely-good-for-me*
modules, they don't blink and eye and test it in a multiplicity of
platforms, providing feedback that would take me ages to collect
otherwise. This is so cool.

So, yeah... THANKS!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Data::Tubes]: https://metacpan.org/pod/Data::Tubes
