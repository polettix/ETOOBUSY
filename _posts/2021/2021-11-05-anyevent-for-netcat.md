---
title: 'AnyEvent for Netcat?'
type: post
tags: [ perl, networking, linux ]
series: Netcat in Perl
comment: true
date: 2021-11-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I considered using [AnyEvent][] for the Netcat [Perl][] investigation.

Doing the little investigation for a Netcat in [Perl][], it's clear that
it mostly revolves around doing I/O without blocking. Also, considering
the possible amount of endpoints involved in a generalized solution...
some module that manages an efficient I/O loop would be good.

Or would it be?

For the moment, I'd like to have something that relies on CORE modules
only, so that I can take it basically wherever there's [Perl][]. I know,
I should probably use *low-level* socket facilities, but
[Io::Socket::INET][] is in core since 5.6 so... I can safely guess that
it's available, or there's no [Perl][] I can make use of.

So I guess I'll have to look into [AnyEvent][] some other time...


[Perl]: https://www.perl.org/
[AnyEvent]: https://metacpan.org/pod/AnyEvent
[IO::Socket::INET]: https://metacpan.org/pod/IO::Socket::INET
