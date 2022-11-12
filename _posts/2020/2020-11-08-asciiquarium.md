---
title: Asciiquarium
type: post
tags: [ perl, ascii, curses ]
comment: true
date: 2020-11-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I've been totally *fascinated* by [Asciiquarium][].

I mean... *how cool can this possibly be*?

<script id="asciicast-370611" src="https://asciinema.org/a/370611.js" async></script>

There's even a [Twitch channel streaming it 24/7][twitch]!

It's a big [Perl][] script that can possibly use some refactoring or
reorganization, but still! I've forked what I've found as a
[semi-official repository in GitHub][], because there were a few
interesting pull requests lingering from some time and I was curious. If
you're curious too, take a look at [polettix/asciiquarium][], which
includes also the enhancements (a yellow submarine, a sword fish, and
some more stuff that is in the original as far as I can understand).

This also led me to discover the [Perl][] module [Term::Animation][],
which is what makes the magic possible. I hope to have time to take a
deeper look at it!

[Asciiquarium]: https://robobunny.com/projects/asciiquarium/html/
[twitch]: https://www.twitch.tv/asciiquarium
[semi-official repository in GitHub]: https://github.com/cmatsuoka/asciiquarium
[polettix/asciiquarium]: https://github.com/polettix/asciiquarium
[Term::Animation]: https://metacpan.org/pod/Term::Animation
[Perl]: https://www.perl.org/
