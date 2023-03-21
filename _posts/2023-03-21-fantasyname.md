---
title: Fantasy Name Generator
type: post
tags: [ perl, parsing ]
series: Fantasy Name Generator
comment: true
date: 2023-03-21 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I submitted a [Pull Request][pr] to [Fantasy Name Generator][].

About two years and a half ago I run a little series of post starting with
post [Fantasy Name Generator - a grammar][fngg]. The gist of it is that the
[Fantasy Name Generator][] repository contains a [Perl][] implementation,
but it can become quickly slow for moderately complex expressions, as also
noted in the project itself.

I finally got to generate a [Pull Request][pr] about it, proposing a
different parser implementation.

I suspect that there's not much interest in that repository since a long
time, because my [previous issue][issue] didn't receive any answer, and I
see stalled pull requests as well. Anyway, maybe people interested into the
project will anyway figure that there's been some improvement desppite the
reduced attention that the project got in these latest years.

Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Fantasy Name Generator]: https://github.com/skeeto/fantasyname
[pr]: https://github.com/skeeto/fantasyname/pull/20
[fngg]: {{ '/2020/11/02/fng-grammar/' | prepend: site.baseurl }}
[issue]: https://github.com/skeeto/fantasyname/issues/19
