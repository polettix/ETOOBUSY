---
title: 'Imager::QRCode'
type: post
tags: [ perl, qr codes ]
comment: true
date: 2022-04-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I tried out [Imager::QRCode][].

Overall, it does its job straight from the SINOPSYS:

```
use Imager::QRCode;
 
my $qrcode = Imager::QRCode->new(
    size          => 2,
    margin        => 2,
    version       => 1,
    level         => 'M',
    casesensitive => 1,
    lightcolor    => Imager::Color->new(255, 255, 255),
    darkcolor     => Imager::Color->new(0, 0, 0),
);
my $img = $qrcode->plot("blah blah");
$img->write(file => "qrcode.gif")
  or die "Failed to write: " . $img->errstr;
```

The `size` parameter is the size of each little tiny square representing
a unit of information in the QR Code. I write this down because future
me is going to get puzzled *again* by what `Horizontal and vertical size
of module(dot)` means, possibly thinking that it has something to do
with the *overall* size of the generated QR image.

One thing that makes me a bit uneasy is the upper limit for the data to
be encoded. According to [here][], a full 177x177 8-bit image in High
redundancy mode should be capable of holding up to 1273 octets, but I
only managed to put 1268 in. Go figure.

Have fun!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Imager::QRCode]: https://metacpan.org/pod/Imager::QRCode
[here]: https://www.qrcode.com/en/about/version.html
