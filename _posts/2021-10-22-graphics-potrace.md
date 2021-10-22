---
title: 'Graphics::Potrace'
type: post
tags: [ perl, graphics, raster, vectorial ]
comment: true
date: 2021-10-22 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I took a look back at [Graphics::Potrace][].


It seems that about 9 years ago I started working on
[Graphics::Potrace][]:

```
0.1.0_03  2012-03-04 01:11:20 Europe/Rome
   - Checking for potrace executable before generating Makefile
   - Added README.md to the project
```

It took me more than one year to release it though:

```
0.72      2013-08-03 20:10:30 Europe/Rome
   - Added one test on trace
   - release!
```

What the heck does it do, anyway? It is a thin wrapper around
[Potrace][], a program (and a library) by Peter Selinger for
*Transforming bitmaps into vector graphics*.

It's been my first and I think only public venture into XS, which I
don't do any more since a long time. It has always felt a lot like black
magic, but eventually the module worked and I was happy to release it.

Looking at the implementation, I *think* there is some [relic code][]
that is not used any more in the XS:

```
MODULE = Graphics::Potrace::Bitmap	PACKAGE = Graphics::Potrace::Bitmap	PREFIX = gpb_
PROTOTYPES: DISABLE

SV *
gpb__trace (self, param, bitmap)
   SV *self
   SV *param
   SV *bitmap
   CODE:
      RETVAL = _trace((HV *)SvRV(param), (HV *)SvRV(bitmap));
   OUTPUT:
      RETVAL
```

The `Graphics::Potrace::Bitmap` module/package is nowhere to be found
and apparently not used either; furthermore, the `_trace` function has
its counterpart in the main module and as I see it it's the one I used
actually.

I can find cruft everywhere!

[Perl]: https://www.perl.org/
[Graphics::Potrace]: https://metacpan.org/pod/Graphics::Potrace
[Potrace]: http://potrace.sourceforge.net/
[relic code]: https://github.com/polettix/Graphics-Potrace/blob/e2ae24c5808c585f08d4c7368be42af499a4f42a/Potrace.xs#L246
