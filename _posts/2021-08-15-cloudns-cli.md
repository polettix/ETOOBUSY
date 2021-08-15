---
title: ClouDNS CLI
type: post
tags: [ cloudns, cli ]
comment: true
date: 2021-08-15 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I started toying with [ClouDNS][]'s [API][] to build a (minimal,
> incomplete) CLI application.

I'm planning to use [App::Easer][] for it, so that I can put it to test
after the (little) time it took me to forget about it. The real test!
This will also allow me to understand the shortcomings and rough edges
of the module, so it will be a double win.

The provided [API][] is very large, but for my purposes I'm only
planning to support part of it (dealing with resource records
management, in particular). The structure with [App::Easer][] should
make it easy to add more commands as time goes, anyway.

I know I'll regret this, but I'm currently *not* planning on building a
separate module for implementing the API layer. It will be a nice
project in the future, should I need it; for the time being I'll go a
bit lower-level.

I was initially thinking on relying upon [HTTP::Tiny][] and have zero
dependencies, only to realize almost immediately that I would need to
install [IO::Socket::SSL][] (which means installing [Net::SSLeay][]).
At this point, it makes sense to also bring [Mojolicious][] in and rely
on the excellent [Mojo::UserAgent][].

Let's see...

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ClouDNS]: https://www.cloudns.net/
[API]: https://www.cloudns.net/wiki/article/41/
[HTTP::Tiny]: https://metacpan.org/pod/HTTP::Tiny
[App::Easer]: https://metacpan.org/pod/App::Easer
[IO::Socket::SSL]: https://metacpan.org/pod/IO::Socket::SSL
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Net::SSLeay]: https://metacpan.org/pod/Net::SSLeay
