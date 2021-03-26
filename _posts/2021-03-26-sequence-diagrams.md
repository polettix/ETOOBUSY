---
title: "Poor man's sequence diagrams"
type: post
tags: [ perl, coding, graphics ]
comment: true
date: 2021-03-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> An old piece of code to draw sequence-diagram-ish.

I resumed some code from about 13 years ago... and polished it *a bit*, but
not completely. It's a toy to draw sequence diagrams, that lived within a
module designed for my computer science engineering thesis. It draws
sequence-diagram like stuff, with no pretense of adherence to any standard.
Just provide pairs of actors and there will be arrows.

This:

```perl
   my @messages = (
      ['Thorrilo'  => 'Forgogrim', 'ororbisrod()'],
      ['Forgogrim' => 'Thorrilo',  'foradurdir()'],
      ['Thorrilo'  => 'Violetas',  'hobgoon()'],
      ['Violetas'  => 'Forgogrim', 'ereritur()'],
   );
```

becomes this:

![sequence-diagram]({{ '/assets/images/sequence-diagram.png' | | prepend: site.baseurl }})

The code (a [local version is here][]) is the following:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2039724.js"></script>

Cheers!

[local version is here]: {{ '/assets/code/SequenceDiagram.pm' | prepend: site.baseurl }}
