---
title: QRate - decoding
type: post
tags: [ qr codes, perl ]
series: QRate
comment: true
date: 2022-04-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The decoding part of QRate.

We already had a look at the decoding process, i.e. going from a PDF
file with images back to the original data:

```perl
sub decode ($input, $output) {
   my $data = assemble_data(slice_reader_it(pdf_reader_it($input)));
   path($output)->spew_raw(uncompress($data));
   return 0;
}
```

As before, there are two iterators at play (provided by `pdf_reader_it`
and `slice_reader_it`), as well as a function that takes all the input
slices and reassembles them back into the desired data
(`assemble_data`).

Let's start from the PDF reader:

```perl
sub pdf_reader_it ($file) {
   my $magick = Image::Magick->new();
   die if $magick->Read($file); # returns 0 on success
   my $n = 0;
   return sub {
      return if $n > $magick->$#*;
      return $magick->[$n++];
   };
}
```

As already observed in [PerlMagick PDF pages][], [Image::Magick][]
provides us back with a (blessed) reference to an array when there are
multiple images (or, in our case, multiple pages). This means that our
iterator just needs to provide each page back, in order.

A page from the PDF is consumed by a *slice reader*, which turns the
page's image back into "actionable" data thanks to [Barcode::ZBar][],
which we already saw in the past ([Reading QR Codes from Perl][]):

```perl
sub slice_reader_it ($it) {
   my $scanner = Barcode::ZBar::ImageScanner->new();
   $scanner->parse_config("enable");
   return sub {
      my $page = $it->() or return;

      my $image = Barcode::ZBar::Image->new();
      $image->set_format('Y800');
      $image->set_size($page->Get(qw(columns rows)));
      $image->set_data($page->ImageToBlob(magick => 'GRAY', depth => 8));

      my $n = $scanner->scan_image($image);

      return map {
         my ($header, $data) = split m{\n}mxs, $_->get_data, 2;
         my ($n, $more) = $header =~ m{\A (\d+) ([+.]) \z}mxs;
         return {
            n => $n,
            last => ($more eq '.' ? 1 : 0),
            data => $data,
         };
      } $image->get_symbols;
   }
}
```

Here, we have to remember of our *framing* overhead, which added a
sequence number to each slice, as well as an indicator of whether more
slices are expected or this was the last one. This accounts for the
small processing of the data read from the QR code, which is split into
the sequence number (`n`), the indicator for the last slice (`last`) and
the payload data itself.

Last, let's take a look at the function to reassemble all pieces. It
receives the iterator for the slices:

```perl
sub assemble_data ($it) {
   my @slices;
   while (my $slice = $it->()) {
      print {*STDERR} '.';
      push @slices, $slice;
   }
   print {*STDERR} "\n";
   @slices = sort { $a->{n} <=> $b->{n} } @slices;
   for my $n (0 .. $#slices) {
      die "missing slice $n\n" if $slices[$n]{n} != $n;
   }
   die "missing trailing slices\n" unless $slices[-1]{last};
   my $data = join '', map { $_->{data} } @slices;
   return decode_base64($data);
}
```

The initial part is just amassing all slices into array `@slices`. Then
we sort them according to their sequence number and perform some sanity
check to see if there are missing pieces. If not, we can return the data
by decoding it from Base-64.

I hope you enjoyed the ride so far!

[Perl]: https://www.perl.org/
[PerlMagick PDF pages]: {{ '/2022/04/17/perlmagick-pdf-pages/' | prepend: site.baseurl }}
[Image::Magick]: https://imagemagick.org/script/perl-magick.php
[Reading QR Codes from Perl]: {{ '/2020/01/22/zbar/' | prepend: site.baseurl }}
[Barcode::ZBar]: https://metacpan.org/pod/Barcode::ZBar
