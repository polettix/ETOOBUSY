---
title: Parsing SVG paths
type: post
tags: [ algorithm, svg, parsing, perl, coding ]
series: Bounding Box for SVG Paths
comment: true
date: 2020-07-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Reinventing wheels: parsing the `d` attribute of paths in SVG.

I know, I know.

There is [Image::SVG::Path][] on [CPAN][] that does exactly this. But
*how hard can it be?!?*.

Well... a bit, indeed. But now it's (mostly) in the past, so we can
enjoy an intermediate-though-working byproduct, `parsth`:

<script src='https://gitlab.com/polettix/notechs/snippets/1994835.js'></script>

I try to follow the grammar as much as possible, taking shortcuts here
and there. The last part should remind of what described in [Parsing
toolkit in cglib][].

We are converging...

[Image::SVG::Path]: https://metacpan.org/pod/Image::SVG::Path
[CPAN]: https://metacpan.org/
[Parsing toolkit in cglib]: {{ '/2020/07/11/parsing-toolkit' | prepend: site.baseurl }}
