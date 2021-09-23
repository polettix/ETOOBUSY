---
title: 'QRcode.show'
type: post
tags: [ web, qr codes ]
series: ASCII QR codes
comment: true
date: 2021-09-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Handy QR Generator: [qrcode.show][]

Some days ago I was thinking about the possibility to have QR Codes on
the terminal,and I was considering whether some ASCII Art with `#` and
spaces would do the trick.

Then I discovered [qrcode.show][], which seems pretty much to address
the displaying part:

<script id="asciicast-436668" src="https://asciinema.org/a/436668.js" async></script>

Unfortunately... the embedded player for [asciinema][] leaves some
spaces that make it difficult to appreciate the result. Here is a
snapshot of how I see it from my terminal:

![QRcode.show example from the command line]({{ '/assets/images/qrcode.show-terminal.png' | prepend: site.baseurl }})

The nifty thing is that it's leveraging only three special characters,
plus the space:

- [FULL BLOCK][] `█`
- [UPPER HALF BLOCK][] `▀`
- [LOWER HALF BLOCK][] `▄`
- a simple space

This is a great idea, because terminal fonts are usually higher than
wide, hence it makes sense to pack two pixels in a single character.

It's a good starting point indeed...

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[qrcode.show]: http://qrcode.show/
[FULL BLOCK]: https://www.fileformat.info/info/unicode/char/2588/index.htm
[UPPER HALF BLOCK]: https://www.fileformat.info/info/unicode/char/2580/index.htm
[LOWER HALF BLOCK]: https://www.fileformat.info/info/unicode/char/2584/index.htm
[asciinema]: https://asciinema.org/
