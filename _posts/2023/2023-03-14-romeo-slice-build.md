---
title: Romeo - slice build
type: post
tags: [ perl, romeo ]
series: Romeo
comment: true
date: 2023-03-14 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> More on [Romeo][]'s slicing support.

In [Romeo - slice][] we took a look at [Romeo][]'s slicing capabilities,
i.e. to extract some selected pieces out of a lot.

We saw that it has two capabilities:

- loading slice definitions from a file, to be used over and over, and
- an *interactive mode* to choose data directly from the first record of a
  series (or the only one present, if the input data is a hash).

It was just too natural to use the same *interactive* mode that we already
saw to generate the definitions that we can reuse over and over, right?

Enter `romeo slice-build`. It has pretty much the same interface, but
instead of printing out slices out the input data, it provides us with the
*definitions* that can then be reused later.

Let's see it in action:

<script async id="asciicast-566848" src="https://asciinema.org/a/566848.js"></script>

I hope this can be helpful, stay safe!

[Perl]: https://www.perl.org/
[Romeo - slice]: {{ '/2023/03/13/romeo-slice/' | prepend: site.baseurl }}
[Romeo]: https://codeberg.org/polettix/Romeo
