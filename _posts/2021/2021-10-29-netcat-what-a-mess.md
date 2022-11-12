---
title: 'Netcat... what a mess!'
type: post
tags: [ networking, linux ]
comment: true
date: 2021-10-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Netcat is a mess.

Netcat is a fantastic tool. You don't have to trust me... just read
[Wikipedia on netcat][]:

> `netcat` (often abbreviated to `nc`) is a computer networking utility
> for reading from and writing to network connections using TCP or UDP.
> The command is designed to be a dependable back-end that can be used
> directly or easily driven by other programs and scripts. At the same
> time, it is a feature-rich network debugging and investigation tool,
> since it can produce almost any kind of connection its user could need
> and has a number of built-in capabilities. 

But... there's more than one contender in town, and different
implementation can have wildly differing features.

The [Ports and reimplementations][] section basically says it all. On a
more practical note:

- the version that comes with [busybox][] is really *simple*
- the [GNU netcat][] has a wider feature set, but lacks support for
  using proxies;
- the [BSD netcat][] is more evolved, and supports proxies through the
  `-x` and `-X` options;
- the [Nmap netcat][ncat] (a.k.a. [ncat][]) is another alternative that
  is feature-packed, including support for proxies, although with
  different options (`--proxy` and `--proxy-type`).

So here we go, there's a lot of hints around the Internet... but we get
to know which alternative they're talking about!

[Wikipedia on netcat]: https://en.wikipedia.org/wiki/Netcat
[Ports and reimplementations]: https://en.wikipedia.org/wiki/Netcat#Ports_and_reimplementations
[busybox]: https://busybox.net/
[GNU netcat]: http://netcat.sourceforge.net/
[BSD netcat]: https://cvsweb.openbsd.org/cgi-bin/cvsweb/src/usr.bin/nc/
[ncat]: https://nmap.org/ncat/
