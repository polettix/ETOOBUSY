---
title: A PDF workaround
type: post
series: PDF musings
tags: [ perl, coding, pdf ]
comment: true
date: 2022-11-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A workaround for [A PDF void][].

In latest post [A PDF void][] I expressed my surprise for *not* finding
[Perl][] modules that allow creating PDF files from scratch that include
*forms*.

Not too much of a miss, anyway. [PDF::Builder][] is very supporting in
taking pre-existing PDF stuff and adding *more* stuff onto it, e.g.
strings in key places.

The [SYNOPSIS][] is just eye candy and a joy to read. So much so that
I'll steal it entirely:

```perl
use PDF::Builder;
 
# Create a blank PDF file
$pdf = PDF::Builder->new();
 
# Open an existing PDF file
$pdf = PDF::Builder->open('some.pdf');
 
# Add a blank page
$page = $pdf->page();
 
# Retrieve an existing page
$page = $pdf->open_page($page_number);
 
# Set the page size
$page->size('Letter');  # or mediabox('Letter')
 
# Add a built-in font to the PDF
$font = $pdf->font('Helvetica-Bold'); # or corefont('Helvetica-Bold')
 
# Add an external TrueType (TTF) font to the PDF
$font = $pdf->font('/path/to/font.ttf');  # or ttfont() in this case
 
# Add some text to the page
$text = $page->text();
$text->font($font, 20);
$text->position(200, 700);  # or translate()
$text->text('Hello World!');
 
# Save the PDF
$pdf->saveas('/path/to/new.pdf');
```

Enough said, cheers!

[Perl]: https://www.perl.org/
[A PDF void]: {{ '/2022/11/06/a-pdf-void/' | prepend: site.baseurl }}
[PDF::Builder]: https://metacpan.org/pod/PDF::Builder
[SYNOPSIS]: https://metacpan.org/pod/PDF::Builder
[sogimp]: https://stackoverflow.com/questions/8971243/free-tool-for-watching-coordinates-in-pdf
[GIMP]: https://www.gimp.org/
