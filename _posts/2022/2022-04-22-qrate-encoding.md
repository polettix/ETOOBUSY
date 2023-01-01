---
title: QRate - encoding
type: post
tags: [ qr codes, perl ]
series: QRate
comment: true
date: 2022-04-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Encoding an input file in a PDF full of QR images.

We already took a sneak peek at the `encode()` sub:

```perl
sub encode ($input, $output) {
   my $data = compress(path($input)->slurp_raw, 9) or die "compress()\n";
   assemble_pdf(qrcoder_it(slicer_it($data)))->save($output);
   return 0;
}
```

The first part is just leveraging `compress` from [Compress::Zlib][] and
`path` from [Path::Tiny][], so nothing to add for them.

Function `assemble_pdf()` is supposed to receive an *iterator* providing
images and return a [PDF::API2][] object that can then be used to `save`
the whole generated PDF onto `$output`:

```perl
use constant PAGE_SIZE => 'A4';
use constant X_PAGE_SIZE => 595;
use constant Y_PAGE_SIZE => 842;
use constant MIN_MARGIN => 30;

sub assemble_pdf ($it) {
   my $x_margin = MIN_MARGIN;
   my $size = X_PAGE_SIZE - 2 * MIN_MARGIN;
   my $y_margin = int((Y_PAGE_SIZE - $size) / 2);
   my $pdf = PDF::API2->new;
   $pdf->default_page_size(PAGE_SIZE);
   while (my $png = $it->()) {
      print {*STDERR} '.';
      open my $fh, '<:raw', \$png or die "open(): $!\n";
      my $image = $pdf->image($fh);
      $pdf->page->object($image, $x_margin, $y_margin, $size, $size);
   }
   print {*STDERR} "\n";
   return $pdf;
}
```

As we can see, there's a bit of fiddling to find out the right margins
so that our QR code image is centered in the page and has sufficient
margins to avoid being cut during the printing process.

The `while` loop takes care to iterate over `$it`, taking all generated
PNG images and fitting them into a new page of the PDF. As this might
take some time, there's a very basic visual feedback in the form of dots
that are printed in the terminal.

So there we go, using [PDF::API2][] really made this a breeze! One thing
to note is that there's a specific conversion from `A4` dimensions in
millimiter and the units used by a PDF by default, which have been
encapsulated into constants. In particular, the values set are an
integer rounding of the actual values, calculated on the assumption that
there are 72 dots per inch, which means that:

$$
72 [dpi] \cdot \frac{21   [cm]}{2.54 [cm/inch]} = 595.2756 [dots] \approx 595 [dots] \\
72 [dpi] \cdot \frac{29.7 [cm]}{2.54 [cm/inch]} = 841.8898 [dots] \approx 842 [dots]
$$

Next time we'll look into these iterators, stay safe in the meantime!

[Perl]: https://www.perl.org/
[Compress::Zlib]: https://metacpan.org/pod/Compress::Zlib
[Path::Tiny]: https://metacpan.org/pod/Path::Tiny
[PDF::API2]: https://metacpan.org/pod/PDF::API2
