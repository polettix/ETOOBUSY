---
title: A wrapper for asciinema
type: post
tags: [ asciinema, shell ]
comment: true
date: 2020-09-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Sometimes I use [asciinema][] and I'm fed up of remembering all
> options.

When I want to record a "termcast" with [asciinema][], I always struggle
a bit to remember the options and to get the prompt right. So I
figured... why not wrap it in a script with my defaults?

Here's what it does:

- I usually record stuff in a *standard size* terminal, i.e. one that is
  80 columns wide and 25 rows tall (call me a romantic... or granpa 🙄).
  Hence, I do a pre-check to make sure I don't record the whole thing
  just to realize that I have to do it again with the right size;
- I set a filename to a temporary file if nothing is provided;
- The prompt in the termcast is set to a plain, anonymous `$ `. After
  all, everything else might be distracting to the viewer (although
  sometimes it might come handy);
- [asciinema][] allows you to jump big idle periods by capping their
  maximum amount. I usually put it to one second, so that I can take my
  time during the recording (e.g. to do some copy-and-paste or
  whatever);
- so many time something goes wrong (e.g. I forget deleting a file) and
  I have to start over - this is why I set overwriting by default;
- last, I set to use a *plain* shell, to avoid loading all the bash
  stuff I have (which would also jeopardize my prompt, by the way).

So... here's [arec][]:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2014408.js"></script>

[Local copy here][].

[asciinema]: https://asciinema.org/
[arec]: https://gitlab.com/polettix/notechs/-/snippets/2014408
[Local copy here]: {{ '/assets/code/arec' | prepend: site.baseurl }}
