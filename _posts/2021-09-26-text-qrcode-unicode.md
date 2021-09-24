---
title: 'Terminal QR Code with Unicode characters'
type: post
tags: [ perl, qr codes ]
comment: true
date: 2021-09-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A wrapper around [Text::QRCode][] to print QR codes on the terminal.

So it seems that [Text::QRCode][] bite the XS bullet to interface with
`libqrencode` and has then been used by a lot of modules (including
[Term::QRCode][], introduced [here][previous]).

The output of that module is a bit weird, in that it is a 2-dimensional
matrix (array of arrays) where each cell contains a single character,
that can be either a star `*` or a blank space.

I think it's weird because I would have expected...

- ... arrays of `1` and `0` (or otherwise *true* and *false* values), OR
- ... an array of *strings* for each line, OR
- ... a single string with nelines inside.

Anyway.

I thought to use the Unicode characters discovered from [QRcode.show][]
to produce something good for the terminal:

```perl
sub terminalize ($encoded) {
   state $char_for = [
      ' ',                    # 0
      "\N{LOWER HALF BLOCK}", # 1
      "\N{UPPER HALF BLOCK}", # 2
      "\N{FULL BLOCK}",       # 3
   ];
   my $first_row_id = 0;
   my @output;
   while ($first_row_id <= $encoded->$#*) {
      my $first_row = $encoded->[$first_row_id++];
      my $second_row = $first_row_id <= $encoded->$#*
         ? $encoded->[$first_row_id++]
         : [ (0) x scalar($first_row->@*) ];
      push @output, join '', '  ', map {
         my $id = $first_row->[$_] * 2 + $second_row->[$_];
         $char_for->[$id];
      } 0 .. $first_row->$#*;
      $output[-1] .= '  ';
   }
   my $blank = $output[0] =~ s{.}{ }grmxs;
   return [$blank, @output, $blank];
}
```

The input is the *encoded* form produced by [Text::QRCode][], and the
output is an array of lines.

A few remarks:

- each *pair* if input lines of pixels is encoded into a *single* line
  of characters, to account for the difference in width vs. height in
  the terminal (this is somehow the opposite choice taken by
  [Term::QRCode][], where each input pixel is represented by *two*
  characters);
- we're adding the *quiet zone* around the produced output, to avoid
  confusing the decoders.

Example result:

![example QR Code in the terminal]({{ '/assets/images/term-qrcode-unicode.png' | prepend: site.baseurl }})

Pretty neat, uh?

I guess it's all for today... stay safe folks!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Text::QRCode]: https://metacpan.org/pod/Text::QRCode
[previous]: {{ '/2021/09/25/term-qrcode/' | prepend: site.baseurl }}
[QRcode.show]: []: {{ '/2021/09/24/qrcode-show/' | prepend: site.baseurl }}
[Term::QRCode]: https://metacpan.org/pod/Term::QRCode
