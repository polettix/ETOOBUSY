---
title: 'Netcat... in Perl'
type: post
tags: [ perl, networking, linux ]
series: Netcat in Perl
comment: true
date: 2021-10-31 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A minimal [Netcat][] in [Perl][].

After looking at a few alternatives for [Netcat][] (by this way, this
page contains a lot more!), I saw that none other than [SALVA][] put
[App::pnc][] on [CPAN][].

Alas, it's *just* the basic functionality of netcat, and it does *not*
help with the proxy stuff I looked at these days.

[Yeah, well... history is gonna change][quotation]!

[Perl]: https://www.perl.org/
[SALVA]: https://metacpan.org/author/SALVA
[Netcat]: https://sectools.org/tool/netcat/
[Netcat... what a mess!]: {{ '/2021/10/29/netcat-what-a-mess/' | prepend: site.baseurl }}
[App::pnc]: https://metacpan.org/pod/App::pnc
[CPAN]: https://metacpan.org
[quotation]: https://movie-sounds.org/sci-fi-movie-samples/quotes-with-sound-clips-from-back-to-the-future/yeah-well-history-is-gonna-change
