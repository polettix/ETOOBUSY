---
title: 'Trying Cairo in Perl'
type: post
tags: [ cairo, perl ]
comment: true
date: 2020-09-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where I use some of the [Cairo][] APIs for [Perl][] and figure out
> that it's not what I was after.

Starting from the example in the module's synopsis, I ended up with the
following:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Cairo;

use constant Xmin => 37.5;
use constant Ymin => 31;
use constant SquareLength => 260;
use constant StrongLine => 1.7;
use constant ThinLine => 0.2;

my $surface = Cairo::PdfSurface->create('example.pdf', 595, 842);
my $cr = Cairo::Context->create($surface);

$cr->set_source_rgb(1, 1, 1);
$cr->rectangle(0, 0, 595, 842);
$cr->fill;

$cr->set_source_rgb(0, 0, 0);

for my $x (0, 1) {
   for my $y (0, 1, 2) {
      my $xmin = Xmin + SquareLength * $x;
      my $ymin = Ymin + SquareLength * $y;
      my $sl4 = SquareLength / 4;

      $cr->set_line_width(StrongLine);
      $cr->set_dash(2 * (($x + $y) % 2), 2, 2);
      $cr->rectangle($xmin, $ymin, SquareLength, SquareLength);
      $cr->stroke;

      $cr->set_dash(0, 3, 3);
      $cr->set_line_width(ThinLine);
      $cr->move_to($xmin + 1 * $sl4, $ymin + 0 * $sl4);
      $cr->line_to($xmin + 1 * $sl4, $ymin + 2 * $sl4);
      $cr->line_to($xmin + 2 * $sl4, $ymin + 3 * $sl4);
      $cr->move_to($xmin + 3 * $sl4, $ymin + 4 * $sl4);
      $cr->line_to($xmin + 3 * $sl4, $ymin + 2 * $sl4);
      $cr->line_to($xmin + 2 * $sl4, $ymin + 1 * $sl4);
      $cr->stroke;

      $cr->set_dash(0);
      $cr->set_line_width(StrongLine);
      $cr->move_to($xmin, $ymin + $sl4);
      $cr->line_to($xmin + 1 * $sl4, $ymin + 2 * $sl4);
      $cr->line_to($xmin + 3 * $sl4, $ymin + 0 * $sl4);
      $cr->line_to($xmin + 3 * $sl4, $ymin + 2 * $sl4);
      $cr->line_to($xmin + 4 * $sl4, $ymin + 3 * $sl4);
      $cr->move_to($xmin + 3 * $sl4, $ymin + 2 * $sl4);
      $cr->line_to($xmin + 1 * $sl4, $ymin + 4 * $sl4);
      $cr->line_to($xmin + 1 * $sl4, $ymin + 2 * $sl4);
      $cr->stroke;
   }
}

$cr->show_page;
```

This is the final PDF product (actual file is [example.pdf][]):

![example image]({{ '/assets/images/cairo/example.png' | prepend: site.baseurl }})

What is this mess? They are (blank) faces of an *origami die*; there are
[instructions for folding and assembling][] online.

Anyway... I think this is where the adventure with the [Cairo library][]
stops for me, at least this time. My initial goal was to easily fit
square images in the squares that end up as the die's faces, and as I
see it there's no easy way to include a pre-existing image in the final
product. Not an easy one, anyway 🙄

[Cairo library]: https://cairographics.org/
[Perl]: https://www.perl.org/
[Cairo]: https://metacpan.org/pod/Cairo
[perl-cairo-play/builder]: registry.gitlab.com/polettix/perl-cairo-play/builder
[Docker]: https://www.docker.com/
[Alpine Linux]: https://www.alpinelinux.org/
[example.pdf]: {{ '/assets/images/cairo/example.pdf' | prepend: site.baseurl }}
[Instructions for folding and assembling]: https://worksheets.site/paper-color-dice.html
