---
title: 'Term::Twiddle'
type: post
tags: [ perl, terminal ]
comment: true
date: 2021-05-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I took a look at [Term::Twiddle][].

After looking at [Term::StatusBar][], it was an easy step to take a look
at [Term::Twiddle][] too. I mean, it's mentioned in [Term::StatusBar
POD][]!

The module does a simple thing:

> Now, anytime you or your users have to wait for something to finish,
> instead of twiddling their thumbs, they can watch the computer twiddle
> its thumbs.

I have to add that it does it well.

By default, it provides the rotating bar that we all love, but it's
possible to define custom animations, which is interesting:

<script id="asciicast-412981" src="https://asciinema.org/a/412981.js" async></script>

I think that I'll probably give this a try if possible, should such a
need arise in a program. Who knows?

The test code used above can be found in [this gist][].

Cheers!

[Term::Twiddle]: https://metacpan.org/pod/Term::Twiddle
[Term::StatusBar]: {{ '/2021/05/24/term-statusbar/' | prepend: site.baseurl }}
[Term::StatusBar POD]: https://metacpan.org/pod/Term::StatusBar
[this gist]: https://gist.github.com/polettix/81f2f778d34c12379a627610c2df4059
