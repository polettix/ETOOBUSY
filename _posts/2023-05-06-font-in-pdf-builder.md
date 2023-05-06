---
title: 'Font selection in PDF::Builder'
type: post
tags: [ pdf, perl ]
comment: true
date: 2023-05-06 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some notes on selecting the right font in [PDF::Builder][].

I hope I didn't already write about this, but anyway [repetita iuvant][] 🙄

Using a font in [PDF::Builder][] requires that the library can get to
the font somehow. This can be through (at least) two ways:

- setting the path (relative or absolute) in the string for requesting
  the font, OR
- making sure the font is in a *known* directory.

Let's get to the examples, starting from this:

```perl
use PDF::Builder;
my $pdf = PDF::Builder->new;
```

The first way is:

```perl
# somefont.ttf is in /path/to/
my $font_1 = $pdf->font('/path/to/somefont.ttf');
```

It's possible to see which directories are pre-defined in
[PDF::Builder][]:

```perl
print "$_\n" for PDF::Builder->font_path;
```

If `/path/to` is already there, yay! Otherwise, we can add it:

```perl
PDF::Builder::add_to_font_path('/path/to');
```

When the directory is there, we can just pass the base name of the file:

```perl
# somefont.ttf is in /path/to/
my $font_2 = $pdf->font('somefont.ttf');
```

The current directory is included in the list by default, which is why
relative paths work and copying the file locally works too.

As a matter of fact, relative paths work taking any directory in the
list as a base. So this would work too:

```perl
# somefont.ttf is in /path/to/
PDF::Builder::add_to_font_path('/path');
my $font_3 = $pdf->font('to/somefont.ttf');
```

I hope future me will remember about this!

Stay safe folks!

[Perl]: https://www.perl.org/
[PDF::Builder]: https://metacpan.org/pod/PDF::Builder
[repetita iuvant]: https://it.wikipedia.org/wiki/Repetita_iuvant
