---
title: PerlMagick PDF pages
type: post
tags: [ perl, pdf, imagemagick ]
comment: true
date: 2022-04-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It's easy to get individual pages from a PDF with [PerlMagick][].

I was playing around with [PerlMagick][] and a PDF with two pages
inside, when a question hit me: how do I figure out how many pages are
there in the PDF and iterate through them?

Some searching was not useful to this regard, because either I found
stuff applicable to PHP, or walls of text where searching for *pages*,
*multiple* ecc. did not yield a clear result.

Then this example came in my vision cone:

```perl
$image->Crop(geometry=>'100x100+10+20');
$image->[$x]->Frame("100x200");
```

Wait. A. Minute.

Are we saying that an `ImageMagick` is actually a blessed *array
reference* when reading multiple images (like a PDF)? It seems... so:

```
Image::Magick=ARRAY(0x7efebdc8be00)
```

From this point, the path goes downwards with a gentle decline, through
an amazing country landscape. The array contains indeed one item for
each page, *and* each item in the array can itself be used as an
`ImageMagick` object (this time it's a blessed `SCALAR` instead, but who
cares?).

So there we go, to know how many pages are in the PDF we can do like
this:

```perl
use v5.24;
use ImageMagick;
my $pm = ImageMagick->new;
$pm->Read('myfile.pdf');
my $n_pages = $pm->@*;
```

Enjoy and stay safe!

[Perl]: https://www.perl.org/
[PerlMagick]: https://imagemagick.org/script/perl-magick.php
