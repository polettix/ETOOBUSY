---
title: Fun trick with EPAN and Mojolicious
type: post
tags: [ perl, cpan, mojolicious ]
comment: true
date: 2022-06-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Serving an [epan][] through [Mojolicious][].

In past post [EPAN - Exclusive Perl Archive Nook][] I introduced a small
application [epan][], which covers a small niche of generating just the
missing bits to turn what's left from running `cpanm` with the right set
of command-line parameters into a valid local mini-CPAN directory.

But, of course, CPAN is mostly a thing that we love to access via
HTTP/HTTPS, so the next stop would be to make it accessible via this
protocol.

If you toss [Mojolicious][] into your `epan` archive, this can be done
in virtually no time:

<script id="asciicast-501030" src="https://asciinema.org/a/501030.js" async data-speed="1.5"></script>

Hope you find it useful... and hope you stay safe too!

[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[epan]: https://metacpan.org/pod/App::EPAN
[EPAN - Exclusive Perl Archive Nook]: {{ '/2021/06/13/epan/' | prepend: site.baseurl }}
