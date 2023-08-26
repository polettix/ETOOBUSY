---
title: Frustrating results with PerlMagick
type: post
tags: [ perl, imagemagick ]
comment: true
date: 2023-08-26 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I wonder about the state of PerlMagick.

**PerlMagick** represents the [Perl][] bindings for... well, it's
complicated:

- [ImageMagick][] is the "original" software, which is still very
  popular as it grows and evolves
- [GraphicsMagick][] is a fork (21 years ago!) that aimed at interface
  stability and efficiency.

Both projects include the bindings, which eventually result in the
installation of `Image::Magick` and `Graphics::Magick` respectively.

Out of curiosity, I tried to compile both modules for a fairly recent
version of [Perl][] (v5.36). With... frustrating results.

First of all, there's no way to install them from [CPAN][]. It's the
other way around: we compile the main thing, and the modules are
available (and installable) as a *side effect*. A sort of *Alien*, but
in reverse. This has its drawbacks, because tools like `carton` and
`cpanm` are out of the game.

[ImageMagick][] complains *a lot*. Many errors have to do with
input/output, so it might be related to some library that I forgot to
include during configuration/compilation.

```
t/blob.t .......... ok   
t/bzlib/read.t .... Failed 2/2 subtests 
t/bzlib/write.t ... Failed 1/1 subtests 
t/composite.t ..... Failed 1/18 subtests 
t/filter.t ........ Failed 1/58 subtests 
t/getattribute.t .. ok     
t/jng/read.t ...... ok     
t/jng/write.t ..... ok     
t/jpeg/read.t ..... ok   
t/jpeg/write.t .... ok   
t/montage.t ....... ok     
t/ping.t .......... ok   
t/png/read-16.t ... ok   
t/png/read.t ...... ok   
t/png/write-16.t .. ok   
t/png/write.t ..... ok   
t/read.t .......... 1/47 Readimage (gradient:red-blue):
   Exception 395: UnableToOpenConfigureFile `colors.xml'
   @ warning/configure.c/GetConfigureOptions/722
   at t/subroutines.pl line 317.
t/read.t .......... Failed 1/47 subtests 
t/setattribute.t .. ok     
t/tiff/read.t ..... ok     
t/tiff/write.t .... ok     
t/write.t ......... Failed 1/32 subtests 
t/zlib/read.t ..... Failed 1/2 subtests 
t/zlib/write.t .... Failed 1/1 subtests
```

[GraphicsMagick][] complains too:

```
t/blob.t .......... ok   
t/composite.t ..... ok     
t/filter.t ........ ok     
t/getattribute.t .. ok     
t/jbig/read.t ..... ok   
t/jbig/write.t .... ok   
t/jng/read.t ...... ok     
t/jng/write.t ..... ok     
t/jpeg/read.t ..... ok   
t/jpeg/write.t .... ok   
t/montage.t ....... Failed 19/19 subtests 
t/ping.t .......... ok   
t/png/read-16.t ... ok   
t/png/read.t ...... ok   
t/png/write-16.t .. ok   
t/png/write.t ..... ok   
t/ps/read.t ....... ok   
t/ps/write.t ...... ok   
t/read.t .......... ok    
t/setattribute.t .. ok     
t/tiff/read.t ..... ok     
t/tiff/write.t .... ok     
t/ttf/read.t ...... ok   
t/write.t ......... 1/? SetImageAttribute:
   Extending attribute value text is deprecated!
   (key="comment")
SetImageAttribute: Extending attribute value text
   is deprecated! (key="comment")
t/write.t ......... ok    
t/zlib/read.t ..... ok   
t/zlib/write.t .... ok
```

Anyway, this seems to be a bug introduced in the very latest release (as
of now, of course), properly tracked in [a bug report][].

Cheers!

[Perl]: https://www.perl.org/
[ImageMagick]: https://imagemagick.org/
[GraphicsMagick]: http://graphicsmagick.org/
[CPAN]: https://metacpan.org/
[a bug report]: https://sourceforge.net/p/graphicsmagick/bugs/722/
