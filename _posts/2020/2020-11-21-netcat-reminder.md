---
title: 'Reminder: how to listen with netcat'
type: post
tags: [ networking, netcat, toolbox ]
comment: true
date: 2020-11-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A little reminder on how to put [netcat][] in listen mode.

It occurred to me that I needed to setup a little listener on a machine to
see if traffic was going through correctly. What better tool than [netcat][]
to do this?!?

It turns out that I didn't remember *almost at all* how to use it. I first
tried this:

```shell
netcat -l 10.0.0.1 54321
```

Nice try, Flavio! But to *listen* to port `54321` you need to use option
`-p`, so...

```shell
netcat -l -p 54321 10.0.0.1
```

... is closer but still *not correct*, because to set the listening address
you need to use option `-s`, which leads us to...

```shell
netcat -l -p 54321 -s 10.0.0.1
```

... which, in the end, *is* correct.

Then, of course, take a deep look at your `iptables -vnL`, because traffic
might get trapped there!

Oh My!

[netcat]: https://en.wikipedia.org/wiki/Netcat
