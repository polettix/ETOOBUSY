---
title: 'SVG to PDF::Collage'
type: post
tags: [ pdf, svg, perl ]
comment: true
date: 2023-05-10 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A very raw workflow to generate [PDF::Collage][] starters from [SVG][]
> files.

After talking about it for a couple of posts, here's a possible way to
generate a template for [PDF::Collage][] in a graphical-*ish* way.

[InkScape][] can import PDF files, which can be put in the background. Then
we can text boxes in the right places and save as [SVG][].

At this point, run this:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2540496.js"></script>

[Local version here][].

It will give out something like this:

```json
   {
      "align" : "end",
      "font" : "FreeSans",
      "font-size" : "12",
      "op" : "add-text",
      "text-template" : "[% whatever %]",
      "x" : "521.33",
      "y" : "707.23"
   },
   {
      "align" : "start",
      "font" : "FreeSerif",
      "font-size" : "9",
      "op" : "add-text",
      "text-template" : "This is where I write more things here.",
      "x" : "100.30",
      "y" : "639"
   },
   {
      "align" : "start",
      "font" : "FreeSans",
      "font-size" : "9",
      "op" : "add-text",
      "text-template" : "Here [% too %]",
      "x" : "193.08",
      "y" : "558.29"
   }
]
```

A good starting point, right? Now maybe some additional things at the
beginning to start with... and we have something useful.

Stay safe!

[Perl]: https://www.perl.org/
[PDF::Collage]: https://metacpan.org/pod/PDF::Collage
[Local version here]: {{ '/assets/code/svg2collage.pl' | prepend: site.baseurl }}
[SVG]: https://www.w3.org/Graphics/SVG/
[InkScape]: https://www.inkscape.org/
