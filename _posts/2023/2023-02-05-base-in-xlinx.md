---
title: Add a base URL to xlinx
type: post
tags: [ perl, mojolicious, web, client ]
comment: true
date: 2023-02-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Adding a base to relative urls in [xlinx][].

*Some* time ago I posted about a script to [Extract links/images from
files or URLs][] and left with these words:

> [...] it does not pre-pend a base URL in case of relative URLs.

Of course, I needed the script and of course I needed absolute URLs.

The *robust* thing would be to look at what [LWP][] does and replicate
it. To be honest, I'm not really in the mood, so I adopted [a different
approach][] instead.

<script src="https://gitlab.com/polettix/notechs/-/snippets/1926435.js"></script>

Enough for today, cheers and stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[xlinx]: https://gitlab.com/polettix/notechs/-/snippets/1926435
[Extract links/images from files or URLs]: {{ '/2020/01/02/xlinx/' | prepend: site.baseurl }}
[LWP]: https://metacpan.org/pod/LWP
[a different approach]: https://stackoverflow.com/questions/24075040/mojodom-shortcut-to-get-absolute-url-for-a-resource/27582201#27582201
