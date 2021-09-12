---
title: Assemble images in a PDF
type: post
tags: [ pdf, shell, cli, imagemagick ]
comment: true
date: 2021-09-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Using [convert][] to assemble multiple images in a PDF file.

In recent posts ([Crop an image with ImageMagick][], [No voids,
please][]) I introduced some small activity I've done recently, which
is:

- take a bunch of images, all with the same structure
- isolate one part of the image with some cropping operation
- remove spaces from the resulting file names
- turn all the cropped, renamed files into a single PDF file.

Here's the final script for doing the last step:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2174440.js"></script>

This also makes it clear why I wanted to get rid of the spaces: I'm just
taking all the file names and putting them inside the command line.

This approach has the *obvious* shortcoming of being limited by the
shell command line size. You know, the kind of stuff for which you would
resort to [xargs][].

In this case, though, I'm anticipating that I'll be joining only a few
(say less than 50) files, so I doubt that the command line will become
too lengthy.

With this, my whole pipeline became something like this:

```shell
ls inputs*png | crop 10,10 100,100 | no-voids | imgs2pdf stuff.pdf
```

I'm not entirely sure that the *output* on standard output should be the
filename, though. On the one hand, it's the actual output of this stage
in the pipeline; on the other hand, in this case the most useful
following step in the pipeline would be to get rid of the cropped
inputs, which I'm losing here.

While I ponder about this... please stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Crop an image with ImageMagick]: []: {{ '/2021/09/10/crop-with-imagemagick/' | prepend: site.baseurl }}
[No voids, please]: {{ '/2021/09/11/no-voids-please/' | prepend: site.baseurl }}
