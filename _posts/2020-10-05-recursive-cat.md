---
title: Recursive cat
type: post
tags: [ shell ]
comment: true
date: 2020-10-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The `cat` will `find` them all.

Scavanging in an old virtual machine, and in particular inside the
`~/bin` directory I had at the time, I discovered a little utility that
might come useful in some vague future. I call it [cat-r][]:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2021677.js"></script>

You provide a path (either a directory or a file, but it gives its best
with a directory) and it finds all *files* in that subtree, then prints
them out in a way that makes you actually see what stuff is where.

[cat-r]: {{ '/assets/code/cat-r' | prepend: site.baseurl }}
