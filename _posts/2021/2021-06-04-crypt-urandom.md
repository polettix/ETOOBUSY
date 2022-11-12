---
title: 'Crypt::URandom'
type: post
tags: [ perl, security ]
comment: true
date: 2021-06-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Crypt::URandom][] might come handy for portability.

It's no mistery that I've been looking at ways to generate a *random
salt* lately, where in [Random bytes and co.][] I happily declared:

> In **my** typical situation, though, I'm in a [Linux][] environment
> not from *ages* ago, so we might rely on `/dev/urandom` directly:

While still true for me, if you need something a bit more *portable* you
might want to look into [Crypt::URandom][]:

```perl
use Crypt::URandom 'urandom';
my $salt = urandom(16);
```

From what I can see, it takes care to call the right API if run in
Windows, while still relying on `/dev/urandom` (or `/dev/random` in
FreeBSD) as a fallback.

So, if you need your *salt*s to be more portable... give it a try!

[Crypt::URandom]: https://metacpan.org/pod/Crypt::URandom
[Random bytes and co.]: {{ '/2021/05/31/random-bytes-and-co/' | prepend: site.baseurl }}
[Linux]: https://www.kernel.org/
