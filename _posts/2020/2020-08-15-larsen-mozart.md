---
title: 'Automated Mozart, by larsen'
type: post
tags: [ perl, music, generative ]
comment: true
date: 2020-08-15 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> From the past... generative music with no brains!

About 15 years ago I had the pleasure and honor to know [larsen][].

He used [Markov chains][] to generate music automatically, starting from
an *example* MIDI file. Alas, after some time his [Automatic Music with
Perl][] became a bit stale and the pointer to the code was lost...

[Internet Archive][] to the [rescue][]! Here's a copy of the code, for
future generations:

<script src='https://gitlab.com/polettix/notechs/-/snippets/2004497.js'></script>

[Local copy][].

Thanks [larsen][] 😄


[larsen]: https://perlmonks.org/?node=larsen
[Markov chains]: https://en.wikipedia.org/wiki/Markov_chain
[Automatic Music with Perl]: https://perlmonks.org/?node_id=151249
[rescue]: https://web.archive.org/web/20090106192605/http://larsen.perlmonk.org/src/mozart.txt
[Internet Archive]: https://archive.org/
[Local copy]: {{ '/assets/code/larsen-mozart.pl' | prepend: site.baseurl }}
