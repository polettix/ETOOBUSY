---
title: Rendering trees in the terminal
type: post
tags: [ terminal ]
comment: true
date: 2022-05-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little function for rendering textual trees in the terminal.

Here it is:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2337342.js"></script>

Here's the sample run in the program:

```
foo
\_ bar
|  \_ Bar
|  |  \_ Baaaar!
|  |_ BAR
|  \_ BaBaR
\_ baz
   \_ galook
```

Bigger trees with bigger depths might be hard to read, I'm thinking of
using different colors for different depths to make things easier.

Stay safe everybody!

[Perl]: https://www.perl.org/
