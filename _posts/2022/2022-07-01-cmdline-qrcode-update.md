---
title: 'Reverse printing the QR Code in the terminal'
type: post
tags: [ perl, qr codes ]
comment: true
date: 2022-07-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> There's an update to [Terminal QR Code with Unicode
> characters][previous].

In post [Terminal QR Code with Unicode characters][previous] I
introduced a small program to print QR codes in the terminal, leveraging
some clever Unicode characters.

Then I used it and I got mixed results. Using the camera from my
smartphone, the QR code was being read fine. Using another application
from the same phone... no. I guess they are using different libraries,
and the latter program has a less advanced algorithm.

It turned out that the chocking program was expecting to read *black
contents on a white background*, whereas the camera was fine with the
reverse too (white on black). So I introduced a little update to the
program to address this, setting the *reverse* option to a true value
because... I like my terminal windows to have a black background.

The code has been updated but it's still in its former location:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2181597.js"></script>

[Local version here]({{ '/assets/code/qrterm' | prepend: site.baseurl
}}).

I guess this is it for today, stay safe!



[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[previous]: {{ '/2021/09/26/text-qrcode-unicode/' | prepend: site.baseurl }}
