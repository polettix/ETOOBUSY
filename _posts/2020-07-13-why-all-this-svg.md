---
title: Why all this SVG?
type: post
tags: [ svg ]
comment: true
date: 2020-07-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> There's a sort of plan behind all this SVG stuff.

Although I don't strive to give too much consistency to the posts in
this blog, there's actually a sort of plan behind many of the latest
ramblings.

My end goal is to build SVG *cards* in a flexible way. I already tried
it, but was not too much satisfied because I don't want to depend on the
availability of a specific font.

So, the *obvious* thing to do (🙄) is to transform each letter into a
SVG path and use it, right? Well yes, but surely I can turn a 2-hours
job of getting all letters and numbers I want into a multiple-days job
of studying the paths, how to calculate the bounding box of a path (so
that I can center it!), and eventually position it. Can't be too
difficult, right?!?

This explains why I took a stab at parsing the `d` attribute of a SVG
path in [Parsing SVG paths][], and also why I'll annoy any reader with
much unneeded maths in the future posts.

You have been warned.

[Parsing SVG paths]: {{ '/2020/07/12/parsing-svg-paths' | prepend: site.baseurl }}
