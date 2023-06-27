---
title: GitHub Pages failed me
type: post
tags: [ web, github ]
comment: true
date: 2023-06-27 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It seems that [jekyll-toc][] is not supported.

I was looking into adding a table of contents (TOC) to the wider-range pages
and found [jekyll-toc][]. So far so good, it worked perfectly *in my
computer* and, as a consequence, in the blog instance at Codeberg, because
it's generated locally.

Then I pushed *also* to GitHub Pages and... well, the result was not exactly
what I was expecting, so to say.

I'll have to investigate more, e.g. using the TOC capabilities provided by
Kramdown,  or whatever else.

[jekyll-toc]: https://github.com/toshimaru/jekyll-toc
