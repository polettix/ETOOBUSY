---
title: A skfold module for Mojolicious applications
type: post
tags: [ perl, mojolicious, skfold ]
series: skfold
comment: true
date: 2022-06-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I uploaded a module to generate [Mojolicious][] applications using
> [skfold][].

[Mojolicious][] comes with its minting application that allows getting
started with it, but I found that over and over I was settling onto a
common pattern and I wanted to *grasp* it into something more reusable.

Additionally, I wanted to *optionally* include support for [Minion][]
too, which can be done with a command-line option.

If [skfold][] is already installed (not the Docker image, sorry!), it's
easy to add this module:

```shell
mkdir -p ~/.skfold/modules
cd ~/.skfold/modules
git clone https://github.com/polettix/skfold-module-mojo.git mojo
```

I hope you will find it useful... *future me* 🙄

[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[skfold]: https://github.com/polettix/skfold
[Minion]: https://metacpan.org/pod/Minion
