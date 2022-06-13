---
title: A long due interface change in skfold
type: post
tags: [ perl, coding, skfold ]
series: skfold
comment: true
date: 2022-06-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Correcting a thing that bite me way too much.

About two years ago I wrote [Restart from skfold][], introducing...
[skfold][], a small program aimed at *scaffolding anything*. This is a
term I use for what the rest of the world probably calls *minting*.
In the hindsight of 2022, I'm happy to have chosen a different word and
stay distant from anything NFT.

Apart from defending my choice of the wording, I write this to log that
I did a small yet big change in the interface, swapping the first two
parameters. So instead of this:

```shell
# NOT SUPPORTED ANY MORE FROM 0.5 ON
skf new-thingie module-name [module options...]
```

we have this:

```shell
# NEW BEHAVIOUR FROM 0.5 ON
skf module-name new-thingie [module options...]
```

I can see why, from an aesthetic point of view, I've been lured into
choosing the former alternative in the first place. Anyway, it just does
*not* click with me, and I invariably find it irritating. I hope this
change will scratch this particular itch.

That's all for today!

> Fun fact: today's post is the 900th 😎

[Perl]: https://www.perl.org/
[Restart from skfold]: {{ '/2020/06/20/restart/' | prepend: site.baseurl }}
[skfold]: https://github.com/polettix/skfold
