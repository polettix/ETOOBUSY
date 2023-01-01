---
title: Corkscrew in Perl
type: post
tags: [ perl, networking ]
comment: true
date: 2022-03-25 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A proof of concept implementation of [corkscrew][] in [Perl][].

[corkscrew][] is a handy program to set up SSH connectivity through a
web proxy that supports the `CONNECT` verb. (The project in GitHub
appears to be an attempt at preserving the [original
corkscrew][original]).

I was intrigued by this opportunity to reinvent the wheel with what
appears to be a bit too much of code ([local version here][]):

<script src="https://gitlab.com/polettix/notechs/-/snippets/2198887.js"></script>


It was a good occasion to remove some rust off my networking programming
skills 😅

[Perl]: https://www.perl.org/
[corkscrew]: https://github.com/bryanpkc/corkscrew
[original]: https://web.archive.org/web/20170510154150/http://agroman.net/corkscrew/
[local version here]: {{ '/assets/code/corkscrew.pl' | prepend: site.baseurl }}
