---
title: 'Term::QRCode'
type: post
tags: [ perl, qr codes ]
series: ASCII QR codes
comment: true
date: 2021-09-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Term::QRCode][] generates QR Codes on the terminal.

Well, that shouldn't come as a surprise, given that it's *literally* the
name of the module.

It does its job nicely:

<script id="asciicast-436744" src="https://asciinema.org/a/436744.js" async></script>

If the animation above does not work for any reason, the following
picture should give a hint of what it does:

![Term::QRCode example]({{ '/assets/images/term-qrcode.png' | prepend: site.baseurl }})

It's interesting that the difference in size between the height and the
width of the terminal characters is addressed by *doubling* the inputs
so that *one pixel* is represented by *two characters*. I'd say it works
pretty find in the terminals I use.

The workhorse is [Text::QRCode][], which is a wrapper around
`libqrencode` that provides an output in an... *interesting* format.
Anyway, it does its job with XS so I'm grateful it exists.

And you, are you grateful for something? Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Term::QRCode]: https://metacpan.org/pod/Term::QRCode
[Text::QRCode]: https://metacpan.org/pod/Text::QRCode
