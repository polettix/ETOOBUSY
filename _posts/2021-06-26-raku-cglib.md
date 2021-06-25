---
title: Codingame library in Raku
type: post
tags: [ perl, raku, cglib ]
comment: true
date: 2021-06-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'll probably populate an equivalent of [cglib-perl][] in [Raku][]:
> [cglib-raku][].

From time to time, especially in posts about the [Perl Weekly
Challenge][], I reuse some copy-and-paste code from a library of
functions/algorithms that I keep in [cglib-perl][]. I created this
library when I was actively using the amazing web site [CodinGame][],
although today I don't spend much time there any more.

In a recent post ([PWC118 - Adventure of Knight][]) I leveraged it again
to solve one challenge, but then I was not able to quickly replicate the
same solution in [Raku][], for the simple reason that I don't have a
similar implementation in this language.

So I'm starting a new repository [cglib-raku][] to collect the same kind
of code, in [Raku][]. Let's see where it gets me!


[cglib-perl]: https://github.com/polettix/cglib-perl
[cglib-raku]: https://github.com/polettix/cglib-raku
[Perl]: https://www.per.org/
[Raku]: https://raku.org/
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[PWC118 - Adventure of Knight]: {{ '/2021/06/24/pwc118-adventure-of-knight/' | prepend: site.baseurl }}
[CodinGame]: https://www.codingame.com/
