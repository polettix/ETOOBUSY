---
title: ImageMagick in graffer
type: post
tags: [ docker, graffer ]
comment: true
date: 2020-10-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I added [ImageMagick][] to [graffer][].

A few days ago I introduced [graffer][graffer-post], a [Docker][] image
for wrapping grapics utilities (starting from [cairosvg][]).

I restructured it a bit and added [ImageMagick][] to the lot. The wrapper
script is now inclued in the image itself, print it out with:

```shell
docker run --rm graffer:active --wrapper
```

This wrapper script can be linked (symbolically) to also call `magick`
now. Yay!

[graffer-post]: {{ '/2020/10/17/graffer' | prepend: site.baseurl }}
[graffer]: https://gitlab.com/polettix/graffer
[Docker]: https://www.docker.com/
[cairosvg]: https://cairosvg.org/
[ImageMagick]: https://imagemagick.org/index.php
