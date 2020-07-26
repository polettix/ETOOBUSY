---
title: Some Time Later
type: post
tags: [ svg, font ]
comment: true
date: 2020-07-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where I share an extraction of [Some Time Later][] to SVG, with a few
> changes.

You know when you need to do some very repetitive task and you have that
epiphany moment like... *I can automate it!*. Well, think twice.

For a little side project I was interested into getting individual
letters from the font [Some Time Later][] as SVG files. It's 26
uppercase letters, plus 26 lowercase letters, plus 10 digits. It's 62
total images and yes, 62 is greater than 5 so it's a candidate for
automation, right?

It would probably had taken me a hour or so to do all of them. *Instead*
I went through the rabbit hole, studied how to evaluate the bounding box
of SVG paths, wrote way too much about it, coded horrible code to get
the job done... and I eventually did, *much before* one month later.
Success!

After working a bit with [Inkscape][] to transform letters into
individual paths, I did some adaptation to a few glyphs:

- make uppercase i, digit 1 and lowercase L appear different
- add an internal marker to digit 0 and make both lowercase and
  uppercase o unambiguous
- turn lowercase Q into a rotated lowercase B, because I like it better

This is what I ended up with:

![]({{ '/assets/images/some-time-later.svg' | prepend: site.baseurl }})

If you want the individual letters... [here they are][].

I don't know if I'll ever share the code used to extract the individual
letters. It's way too big and... I'm not proud of it 🙄


[Some Time Later]: https://github.com/ctrlcctrlv/some-time-later
[Inkscape]: https://inkscape.org/
[here they are]: {{ '/assets/other/some-time-later.tar.gz' | prepend: site.baseurl }}
