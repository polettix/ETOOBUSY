---
title: 'PDF::Collage text align'
type: post
tags: [ pdf, perl ]
comment: true
date: 2023-05-13 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Adding support for horizontal text alignment in [PDF::Collage][].

My (*extremely*) low-tech PDF template system [PDF::Collage][] allows
assembing a new PDF with some basic operations, like taking a page from
another PDF or adding some text/images on top of a page.

Most of the times, this is just sufficient to get the job done. Although...
the job can get done in a *nicer way*, sometimes.

One such occasion is when you have a letter (in the sense of the type of
document) and some elements, like the recipient name/address, are written on
the top-right, hopefully aligned to the right border. This is where aligning
the text comes... handy.

I'm not aware of any way of doing this *natively* in PDF, and I doubt there
is because of its nature. But... [PDF::Builder::Resource::BaseFont][] has an
aptly named [width method][width] that allows us to calculate the size of a
string, so we're done right?

This is how the text operation has evolved to take this into account:

```perl
sub _op_add_text ($self, $command) {
   my $opts =
     $self->_expand($command, qw< align page
        font font_family font_size x y >);

   my $content =
     $self->_render_text($opts->@{qw< text text_template text_var >});

   my $font = $self->_font($opts->{font} // $opts->{font_family});
   my $font_size = $opts->{font_size};

   my ($x, $y) = map { $_ // 0 } $opts->@{qw< x y >};

   my $align = $opts->{align} // 'start';
   if ($align ne 'start') {
      my $width = $font_size * $font->width($content);
      $x -= $align eq 'end' ? $width : ($width / 2);
   }

   my $page = $self->_pdf->open_page(__pageno($opts->{page} // 'last'));
   my $text = $page->text;
   $text->position($x, $y);
   $text->font($font, $opts->{font_size});
   $text->text($content // '');

   return $self;
} ## end sub _op_add_text
```

There's been some reshuffling because we need to know the fully rendered
string, as well as the reference X position, *before* we make any use of the
new `align` option that we can fit into the several text operations. Then,
we'll stick to the following convention:

- a missing value, an undefined value, or string `start` means that the
  text is aligned to the... *start*
- `end` means that the text is aligned to the... *end*
- everything else means that the text is aligned to the center.

A bit crude but it should work.

Anything different from `start` (or its equivalents) mean that we have to
calculate the right X position for the start, by subtracting the right
amount depending on the needed alignment.

One interesting thing about the `width` is that it assumes that the font is
1-`pt` sized... so it's necessary (and sufficient!) to multiply by the
actual font size and we have the whole string size. Neat!

Stay safe!


[Perl]: https://www.perl.org/
[PDF::Collage]: https://metacpan.org/pod/PDF::Collage
[PDF::Builder::Resource::BaseFont]: https://metacpan.org/pod/PDF::Builder::Resource::BaseFont
[width]: https://metacpan.org/pod/PDF::Builder::Resource::BaseFont#$wd-=-$font-%3Ewidth($text)
