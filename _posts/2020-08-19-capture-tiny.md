---
title: Capture::Tiny
type: post
tags: [ perl ]
comment: true
date: 2020-08-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The clean way to capture stuff in [Perl][].

I guess you saw it coming... after writing about a
[Quick-and-dirty capturing of STDOUT in Perl][], it's time to look at a
more robust way of doing the same.

[Capture::Tiny][] is what will help you doing this and much more. I
guess this whole post can be stolen from the module's description:

> Capture::Tiny provides a simple, portable way to capture almost
> anything sent to STDOUT or STDERR, regardless of whether it comes from
> Perl, from XS code or from an external program. Optionally, output can
> be teed so that it is captured while being passed through to the
> original filehandles. Yes, it even works on Windows (usually). Stop
> guessing which of a dozen capturing modules to use in any particular
> situation and just use this one.

Folks... it's easy to blog with so much amazing stuff available! 😄

[Quick-and-dirty capturing of STDOUT in Perl]: {{ '/2020/08/18/qnd-capture' | prepend: site.baseurl }}
[Capture::Tiny]: https://metacpan.org/pod/Capture::Tiny
[Perl]: https://www.perl.org/
