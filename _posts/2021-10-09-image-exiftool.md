---
title: 'Image::ExifTool'
type: post
tags: [ perl, image, exif ]
comment: true
date: 2021-10-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Image::ExifTool][] is a handy [Perl][] module.

Some time ago I wanted to divide my photos by date. Fact is, I wanted to
operate on the date they were *shot*, not just the file date (which
often got changed in the copy process from the camera to the PC).

Cameras usually save a lot of metadata along with photos, so that's
where I was looking for what I needed. But, of course, I needed some way
to read that data.

Look no further if you have the same need: the answer is
[Image::ExifTool][]:

```perl
#!/usr/bin/env perl
use v5.24;
use Image::ExifTool 'ImageInfo';
my $image_path = shift // '/path/to/someimage.jpg';
my $info = ImageInfo($image_path,
    qw< EXIF::ModifyDate EXIF:DateTimeOriginal EXIF:CreateDate >);
for my $key (sort { $a <=> $b } keys $info->%*) {
    say "$key <$info->{$key}>";
}
```

Running it on a sample image gets us some data:

```
ModifyDate <2013:11:16 13:34:10>
CreateDate <2013:11:16 13:34:10>
DateTimeOriginal <2013:11:16 13:34:10>
```

In my program I took any of the three to get the date needed for
categorization, even though I *suspect* that this might not have been a
great idea, because it mostly meant that I was taking different fields
from image to image. That's life.

This is barely scratching the surface of the iceberg.
[Image::ExifTool][] lets you also *modify* most of the data in addition
to reading it... if you need to do some bulk processing on metadata,
it's fair to see that it's the tool for you.

And if you don't want/need to code... there's also a program `exiftool`
that gives you all the feature of this amazing module with the ease of
the command line.

What could you ask more?

I know what I can ask you: please stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Image::ExifTool]: https://metacpan.org/pod/Image::ExifTool
