---
title: Codeberg Pages
type: post
tags: [ codeberg, git ]
series: Codeberg
comment: true
date: 2022-07-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some notes about [Codeberg Pages][].

I use [GitHub Pages][] a lot, and it was just natural that I became
interested into [Codeberg Pages][].

On the surface they offer the similar service of hosting static
websites, which perfect for documentation and... *this blog*.

Scratching the surface, though, they're very different services.
[Codeberg Pages][] is what probably was implemented initially in the
other site: an opinionated way of providing static resources (HTML
files, style sheets, images, etc.) in a [Git][] repository, so that it
can be exposed to the Internet.

[GitHub Pages][] became much more, though, as it copes with
automatically generate the static website using a host of generators,
including [Jekyll][] (that is used for this very blog).

The bottom line is that using [Codeberg Pages][] means running the
generator in our clients, populating/updating a specific branch in our
repository (by default, `pages`) and pushing the whole thing.

If on one hand I became spoiled by the ease of use in [GitHub Pages][],
it's also an interesting thing to automate, and a wheel that will be fun
to reinvent. So all in all... very good!

Stay safe!

[Codeberg Pages]: https://codeberg.page/
[GitHub Pages]: https://pages.github.com/
[Git]: https://www.git-scm.com/
[Jekyll]: https://jekyllrb.com/
