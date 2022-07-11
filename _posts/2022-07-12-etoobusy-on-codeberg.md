---
title: ETOOBUSY on Codeberg
type: post
tags: [ blog, jekyll, codeberg ]
series: Codeberg
comment: true
date: 2022-07-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'll probably move the blog in [Codeberg Pages][].

One good thing about [GitHub Pages][] is that static sites can be pushed
as [Markdown][] files and they provide the site generation out of the
box.

Which, you know, means *a lot* for a blog that's sub-titled *minimal
blogging for the impatient*.

On the other hand, I've become fond of [Codeberg Pages][] and I started
playing with it. I mean, like keeping an alternative version of the blog
at [etoobusy.polettix.it][etoobusy].

Doing the full move will require to integrate a few more moving parts,
most probably inside [busypub][] (of [ETOOBUSY automated publishing][]
memory). It already takes care of part of the publishing... it can just
as well care for the other part, possibly integrating with [dokyll][]
(of [Jekyll with Docker][] memory).

Then of course I though about adopting a different static site
generator... but [Jekyll][] is very slick, served me well so far and
don't really see any compelling reason to switch.

Until the automation is in place, that will be dealt with manually.
Which means that posts *might* appear later... but most probably sooner.
So if you want a sneak peak anticipation, it might be the right place to
consider!

[Codeberg Pages]: {{ '/2022/07/09/codeberg-pages/' | prepend: site.baseurl }}
[GitHub Pages]: https://pages.github.com/
[etoobusy]: https://etoobusy.polettix.it/
[busypub]: https://github.com/polettix/busypub
[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub/' | prepend: site.baseurl }}
[dokyll]: https://gitlab.com/polettix/dokyll
[Jekyll with Docker]: {{ '/2020/03/16/jekyll-in-docker/' | prepend: site.baseurl }}
[Jekyll]: https://hub.docker.com/r/jekyll/jekyll
