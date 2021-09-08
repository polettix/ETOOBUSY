---
title: Crop an image with ImageMagick
type: post
tags: [ graphics, imagemagick, cli ]
comment: true
date: 2021-09-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Using [ImageMagick][] to crop one or more images from the command
> line.

Do you know [ImageMagick][]? It's an amazing set of command-line tools
for doing image manipulation. It allows doing a lot - I mean really **a
lot** - of things, although not always *simple things are simple*.

Anyway, this time I needed to do some cropping.

Usually when I do this with a GUI I set one corner, draw a rectangle up
to the diagonally opposite corner, and there goes the cropping. It turns
out that the input required by [ImageMagick][] is somehow different:

- size (width and height) of the rectangle to cut, and
- offset (x and y) of the upper-left corner (assuming that y increases
  downwards).

Hence, a couple of points `(5, 7)` and `(27, 33)` become `23x27+5+7`.

After the first half time... it becomes *shell script* time! So here we
go:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2173003.js"></script>

I hope the comments make sense.

The list of files to crop is provided in the standard input, so that
this can be piped in the shell. There are two positional arguments: two
points (in the `x,y` form, like e.g. `19,72`) and an optional
substitution suitable for `sed`, to generate the name of the cropped
file.

The names of cropped files are printed on standard output, for further
processing down the line.

The [cropped images are produced with `+repage`][crop-repage], which
means that there is no virtual canvas preserved and *it just works*.

Well, I guess it's all for today... I hope you will enjoy!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ImageMagick]: https://imagemagick.org/
[crop-repage]: https://legacy.imagemagick.org/Usage/crop/#crop_repage
