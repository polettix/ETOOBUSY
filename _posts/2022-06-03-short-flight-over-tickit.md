---
title: Short flight over Tickit
type: post
tags: [ perl, terminal, tickit ]
comment: true
date: 2022-06-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I took a quick glance at [Tickit][].

Aiming to generate a little *Terminal User Interface* for some data
visualization, I've ventured into looking at [Tickit][].

I have to say that it is an interesting project, although it has it own
flaws and I eventually decided to stick with [Curses::UI][]. I hope
these considerations will not be taken negatively, because again the
project is interesting and the whole library seems very flexible.

Withough further ado, some comments:

- documentation is somehow lacking - fortunately most things have
  example programs;
- the overall maturity is not exceptionally great. As an example, a
  vertical split is a specialization of a generic split (ok, good) but
  there's no way to set the split position upon creation, only by
  fiddling with the mouse (uhm no, this is bad).
- I so missed the equivalent of a combo box!
- Some widget require version `5.26` or higher, and I have a stock
  `5.24` (ok, this is easy to address!).

Another thing that struck me *a lot* was the lack of a *clear* way of
contributing back. That was a bummer to be honest, because I did want to
work on a patch to contribute back.

All in all, I would really like to be able and use [Tickit][] beyond the
examples... but my [Tickit][]-fu is currently too weak.

Stay safe everybody!


[Perl]: https://www.perl.org/
[Tickit]: https://metacpan.org/pod/Tickit
[Curses::UI]: https://metacpan.org/pod/Curses::UI
