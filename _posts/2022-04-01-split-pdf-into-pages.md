---
title: Split a PDF into individual pages
type: post
tags: [ pdf, perl ]
comment: true
date: 2022-04-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Two ways to split a PDF file into individual pages.

So I needed to split a PDF into individual pages files. First I found
[this][], and in 2022 it works great:

```
gs -sDEVICE=pdfwrite -dSAFER -o outname.%d.pdf input.pdf
```

Then I thought... why not [Perl][]? With a little help from
[PDF::API2][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use PDF::API2;
use File::Basename 'basename';
my $ifile = shift or die "$0 <PDF file>\n";
my $ipdf = PDF::API2->open($ifile);
my $count = $ipdf->page_count;
my $digits = length $count;
for my $pi (1 .. $count) {
   my $ofile = sprintf "%s.%0${digits}d.pdf", basename($ifile), $pi;
   say {*STDERR} "$pi/$count -> $ofile";
   my $opdf = PDF::API2->new;
   $opdf->import_page($ipdf, $pi);
   $opdf->save($ofile);
}
```

Stay safe everyone!

[Perl]: https://www.perl.org/
[this]: https://stackoverflow.com/questions/10228592/splitting-a-pdf-with-ghostscript
[PDF::API2]: https://metacpan.org/pod/PDF::API2
