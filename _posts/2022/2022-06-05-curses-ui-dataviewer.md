---
title: 'Curses::UI data viewer'
type: post
tags: [ perl, curses ]
series: Terminal data viewer
comment: true
date: 2022-06-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An example application with [Curses::UI][].

After much sweating (also due to the rising temperatures in Rome) I
managed to get to an *acceptable* point with a data viewer application
using [Curses::UI][]:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2343795.js"></script>

[Local version here][].

I'll probably comment parts of the code in some future posts, for now:

- start by running the program
- top line allows writing a shell command that is supposed to produce
  valid JSON in standard output
- when data is available, it is shown in the bottom part. The middle
  part allows selecting items in an array (if the data is an array),
  then it's assumed to contain objects.

Well... enough sweating for now, stay safe!

[Perl]: https://www.perl.org/
[Curses::UI]: https://metacpan.org/pod/Curses::UI
[Local version here]: {{ '/assets/code/dataview.pl' | prepend: site.baseurl }}
