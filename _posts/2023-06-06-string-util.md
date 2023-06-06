---
title: 'String::Util'
type: post
tags: [ perl ]
comment: true
date: 2023-06-06 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [String::Util][] seems interesting.

I was taking a lazy look at [metacpan][] when I saw some module with
utilities inside (I don't remember which module, sorry!) and somehow I
thought about the `trim()` function, which I define as removing all leading
and trailing whitespace from a string (nothing original, I know).

Then it hit me... this should belong to a `String::Util` module!

Then it hit me... *surely there's already a `String::Util` module*!

There you go: [String::Util][]. It has a few interesting functions,
including `trim()` and its siblings to only trim leading (`ltrim()`) and
trailing (`rtrim()`) spaces, as well as other like `eqq` and `neqq`, which
work with `undef` too. Nice!

I'll take a look and I'll probably get it by near-default in the future,
it's the kind of things that I tend to reimplement over and over... which is
not very good, right?

Stay safe!

[Perl]: https://www.perl.org/
[String::Util]: https://metacpan.org/pod/String::Util
[metacpan]: https://metacpan.org/
