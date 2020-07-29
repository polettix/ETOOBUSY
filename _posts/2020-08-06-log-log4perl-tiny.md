---
title: 'Log::Log4perl::Tiny'
type: post
tags: [ perl, log ]
comment: true
date: 2020-08-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Log::Log4perl::Tiny][] is a logging module I use for small projects.

When coding little projects, I often find useful to have a few logging
functions around to ease with development and feedback to the user.

All in all, I found [Log::Log4perl][] a lot of time ago and it totally
convinced me. The only thing it didn't have was... ease to be embedded
(read as *fatpacked* in today's parlance) in a script, for simplified
distribution.

This is where I thought of starting [Log::Log4perl::Tiny][]. It strives
to provide most of the functionality from the original project, but
within a single file. As pointed out in issue [Wishlist: Reduce overhead
of stealth logging?][], unfortunately it seems that the footprint of
the stealth loggers is not so negligible... but still, I consider it
somehow *tiny* because it can be easily embedded.

So if you use it... don't log too much 🙄



[Log::Log4perl::Tiny]: https://metacpan.org/pod/Log::Log4perl::Tiny
[Log::Log4perl]: https://metacpan.org/pod/Log::Log4perl
[Wishlist: Reduce overhead of stealth logging?]: https://github.com/polettix/Log-Log4perl-Tiny/issues/10
