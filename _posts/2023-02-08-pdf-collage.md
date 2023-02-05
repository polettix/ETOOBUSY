---
title: 'PDF::Collage on Codeberg'
type: post
tags: [ perl, pdf ]
comment: true
date: 2023-02-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I shared [PDF-Collage][] on [Codeberg][]

After playing a bit with [pdfunnel][], I figured that having a module
would be extremely useful for embedding that kind of capability into
wider programs.

Hence, I started working on [PDF-Collage][], which aims at supporting a
wide and extensible set of possible ways of providing "input" templates.

At the very basic level, one template is *just* a sequence of
*commands*, each represented by a hash reference with an `op` key to
tell what the command is about, as well as its parameters. This is
copied almost verbatim from [pdfunnel][], because it works.

The big itch to scratch was how to gather the different pieces, e.g.
pages from a template PDF, because at this point we have to manage how
we make sure that the commands in some JSON file remain "close" to the
PDF template.

I started playing with the idea of *embedding* the commands in the PDF,
as metadata, and it was working. Anyway it does seem a bit brittle,
because I have no way to tell a regular PDF from one ready for being
used with [pdfunnel][].

This is basically the reason why I started working on
[Data::Resolver][], so I could abstract this aspect from the actual PDF
manipulation.

I still have to write tests and documentation... so this is more or less
alpha. I hope to write more in the coming days.

Stay safe and... cheers!

[Perl]: https://www.perl.org/
[PDF-Collage]: https://codeberg.org/polettix/PDF-Collage
[Codeberg]: https://codeberg.org/
[pdfunnel]: {{ '/2022/11/09/pdfunnel/' | prepend: site.baseurl }}
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
