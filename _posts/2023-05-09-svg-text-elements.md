---
title: SVG Text elements
type: post
tags: [ svg, perl ]
comment: true
date: 2023-05-09 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Taking a look at textual elements in [SVG][].

I think it's not *that* difficult to guess where I'm heading to,
considering all the fuss about stitching stuff on top of PDF files (with
[PDF::Collage][]) and generally have a way to generate PDFs
programmatically. [SVG][] just is another direction of investigation.

So, after figuring out how to deal with `px` units, it makes sense to
figure out where text is placed in SVG files.

Why?

Well... we could go the [cairosvg][] way of course, or even fiddle with
[InkScape][] from the command line. But hey! This would be having less
fun, right?

So *let's assume* we want to look inside the [SVG][] box and deal with
the text inserts inside. I feel both lazy and hands-on, so I'll just
observe that my current [InkScape][] installation produces stuff like
the following (redacted for conciseness):

```xml
<text     style="..." x="100" y="100"
  ><tspan style="..." x="100" y="100"
    >whatever</tspan></text>
```

I can just guess that `tspan` elements can be inside `text` elements,
but I don't know if `text` elements can fit inside other `text` elements
or the like. Besides, I'll only be using simple stuff.

Assuming that text elements might be embedded in other ones, it makes
sense to have a stack of them, inheriting unknown stuff from the parent.
While parsing each of them we can take the upper one as default, which
is what's done in the following function (using `$upper_frame` to this
extent). The `$cv` is a conversion hash from [SVG px conversion in Perl][].


```perl
sub parse_textish ($el, $cv, $upper_frame) {
   my $frame = {$upper_frame->%*};    # shallow copy will do

   # x attribute just needs to be converted from px
   if (defined(my $x = $el->getAttribute('x'))) {
      $frame->{x} = sprintf '%.2f', $x * $cv->{factor};
   }

   # y attribute needs to take into account that PDF's viewport has the
   # origin set on the lower-left corner, not upper-left like SVG.
   if (defined(my $y = $el->getAttribute('y'))) {
      $frame->{y} = sprintf '%.2f', ($cv->{Y_span} - $y) * $cv->{factor};
   }

   # the style attribute can be a trove of useful information
   if (defined(my $style = $el->getAttribute('style'))) {
      if (defined(my $font_size = $style->{'font-size'})) {
         $font_size =~ s{px\z}{}mxs or die "font-size...";
         $frame->{font_size} = sprintf '%.2f', $font_size * $cv->{factor};
      }
      if (defined(my $ta = $style->{'text-align'})) {
         $frame->{align} = $ta;
      }
      if (defined(my $ff = $style->{'font-family'})) {
         $frame->{font_family} = $ff;
      }
   } ## end if (defined(my $style ...))

   # cut to integers if it makes sense
   s{\.00\z}{}mxs for $frame->@{qw< x y font_size >};

   # CDATA might or might not be present, whatever is good
   $frame->{cdata} = $el->getCDATA;

   return $frame;
} ## end sub parse_textish
```

As we're finally heading to PDF-land, we're doing Y axis transformation
right on the spot. SVG has Y coordinates start from top and increase
going down, while PDF starts from the bottom and increases going up.
Nothing too difficult to takle, anyway.

The `style` parsing is conveniently already done by [SVG::DOM][], so we
just have to look into the corrensponding hash reference provided by
`$el->getAttribute('style')`. We just take the font family, the size and
its alignment, which we will eventually use to drive [PDF::Collage][].

Stay safe!

[Perl]: https://www.perl.org/
[cairosvg]: https://cairosvg.org/
[PDF::Collage]: https://metacpan.org/pod/PDF::Collage
[SVG]: https://www.w3.org/Graphics/SVG/
[InkScape]: https://www.inkscape.org/
[SVG px conversion in Perl]: {{ '/2023/05/08/svg-px-conversion/' | prepend: site.baseurl }}
[SVG::DOM]: https://metacpan.org/pod/SVG::DOM
