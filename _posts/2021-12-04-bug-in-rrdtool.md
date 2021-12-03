---
title: A (possible) bug in RRDTool
type: post
tags: [ rrdtool ]
comment: true
date: 2021-12-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I might have hit a bug in [RRDTool][].

In a nutshell, this:

![wrong picture](https://gist.github.com/polettix/96261795e95d6097ee8e614325775722/raw/375df32da9e42b69d9f7c4dc790a9ddd7b1c2ceb/prova-available-over-user.png)

should actually look much more like this:

![correct picture](https://gist.github.com/polettix/96261795e95d6097ee8e614325775722/raw/375df32da9e42b69d9f7c4dc790a9ddd7b1c2ceb/prova-available-over-user.no-gradient.png)

To read about the details, you can go straight to the [Issue 1145][],
where I reported the bug.

**The bottom line** is that we might benefit from standing clear of
using gradients, at least until the problem is solved.

[RRDTool]: https://oss.oetiker.ch/rrdtool/index.en.html
[Issue 1145]: https://github.com/oetiker/rrdtool-1.x/issues/1145
