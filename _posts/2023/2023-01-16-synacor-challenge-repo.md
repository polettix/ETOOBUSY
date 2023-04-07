---
title: Synacor Challenge - my repo
type: post
tags: [ rakulang ]
comment: true
date: 2023-01-16 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I put the code in the [synacor-challenge][] repository.

In my [last post][] I introduced the [Synacor Challenge][] and tagged it
as something to do with [Raku][]. If you're curious about the code, it's
available as a big, huge, humoungous mess at [synacor-challenge][].

I wanted to use a digest algorithm and tried to install a module,
failing miserably. Maybe it's time for me to upgrade my [Raku][], or
maybe it's something with the module.

I ended up *copy-pasting* [Digest::MD5][] by [Cosimo Streppone][Cosimo]
and it works like a charm after *almost* 6 years. Thanks Cosimo!

[Raku]: https://raku.org/
[synacor-challenge]: https://codeberg.org/polettix/synacor-challenge
[Synacor Challenge]: https://challenge.synacor.com/
[last post]: {{ '/2023-01-15-synacor-challenge/' | prepend: site.baseurl }}
[Digest::MD5]: https://raku.land/github:cosimo/Digest::MD5
[Cosimo]: http://www.streppone.it/cosimo/blog/
