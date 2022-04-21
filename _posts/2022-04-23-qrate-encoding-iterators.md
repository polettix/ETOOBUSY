---
title: QRate - iterators for encoding
type: post
tags: [ qr codes, perl ]
series: QRate
comment: true
date: 2022-04-23 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Dealing with the iterators for encoding in QRate.

We already saw that assembling the PDF is done based on an iterator
function that is supposed to provide PNG images:

```perl
sub encode ($input, $output) {
   my $data = compress(path($input)->slurp_raw, 9) or die "compress()\n";
   assemble_pdf(qrcoder_it(slicer_it($data)))->save($output);
   return 0;
}
```

As we can see, there are two nested iterators at play:

- `qrcoder` returns the QR codes as PNG images, based on a
  right-sized slice of data provided by
- `slicer`, which takes the overall data and slices it accordingly.

Function `qrcoder_it` is a *factory* function, i.e. one that returns a
function to be called later:

```perl
sub qrcoder_it ($it) {
   my $qrcode = Imager::QRCode->new(
      size          => 8,
      margin        => 2,
      mode          => '8-bit',
      version       => 1,
      level         => 'H',
      casesensitive => 1,
      lightcolor    => Imager::Color->new(255, 255, 255),
      darkcolor     => Imager::Color->new(0, 0, 0),
   );
   return sub {
      my $data = $it->() // return;
      my $img = $qrcode->plot($data)->to_paletted;
      my $retval;
      $img->write(data => \$retval, type => 'png')
        or die "Failed to write: " . $img->errstr;
     return $retval;
   }
}
```

As we can see, the whole point is to call the *inner* iterator to get
the next chunk of data, and using [Imager::QRCode][] to do the right
magic. The returned value is a PNG image in memory.

Last, let's take a look at the other *factory* function, i.e. the input
data slicer:

```perl
use constant LINES_PER_SLICE => 16;

sub slicer_it ($data) {
   my @encoded = split m{\n}mxs, encode_base64($data);
   my $n_slice = 0;
   return sub {
      return unless @encoded;
      my @payload = splice @encoded, 0, LINES_PER_SLICE;
      my $header = $n_slice++ . (@encoded ? '+' : '.');
      return join "\n", $header, @payload, '';
   };
}
```

Again, it's a *factory* because it returns a sub that can be called to
gather all the different pieces. In addition to slicing, ths function
also does some *framing*, i.e. it puts a small header on top of each
slice to keep track of which slice we are dealing with. In particular,
we're adding a sequence number and an indicator of wheter more slices
are in line (with the `+` mark) or not (the final slice has marker `.`).
This will come handy later, when we will reassemble the whole thing
(possibly from unsorted scannerized pictures).

The choice to fit 16 lines per slice comes from the limit of a
High-redundancy QR code for binary data, which for [Imager::QRCode][] is
set at 1268 bytes as we saw in a [previous post][]

So... we're done with the encoding!

[Perl]: https://www.perl.org/
[previous post]: {{ '/2022/04/16/imager-qrcode/' | prepend: site.baseurl }}
[Imager::QRCode]: https://metacpan.org/pod/Imager::QRCode
