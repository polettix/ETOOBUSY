---
title: 'nip.io, sslip.io, and the like'
type: post
tags: [ networking, development ]
comment: true
date: 2022-10-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> `*.10.20.30.40.nip.io` resolves to `10.20.30.40`.
> `*.10.20.30.40.sslip.io` too.

When experimenting (e.g. with [Dokku][]) it's useful to be able and set
up some *resolvable* DNS name that maps onto a specific address, without
the need to get our own domain.

Enter [nip.io][], [sslip.io][] and - if all that you need back is just
`127.0.0.1`, everything that still works in [this gist][].

There are a few variations that can be useful, let's see some examples
assuming that our target IP address is `10.20.30.40`.

- For something *really* intuitive and quick, just put your IPv4 address
  and follow it with `.nip.io`:

```
10.20.30.40.nip.io   # --> 10.20.30.40
```

- everything that comes *before* it is valid too, i.e. there are
  wildcards all down the rabbit hole:

```
www.10.20.30.40.nip.io        # --> 10.20.30.40, a regular service
whatever.10.20.30.40.nip.io   # --> 10.20.30.40, first-level wildcard
app1.dokku.10.20.30.40.nip.io # --> 10.20.30.40, second-level wildcard
```

- if all these dots are likely to annoy your application, it's possible
  to substitute them with dashes. It's still quick, although possibly a
  little less intuitive:

```
10-20-30-40.nip.io            # --> 10.20.30.40, look, dashes!
whatever.10-20-30-40.nip.io   # --> 10.20.30.40, *dot* after whatever
whatever-10-20-30-40.nip.io   # --> 10.20.30.40, *dash* after whatever
```

- Too long to type? Hexadecimal representation to the rescue! The
  hexadecimal counterpart of `10.20.30.40` is `0a141e28`, so:

```
0a141e28.nip.io            # --> 10.20.30.40, look, hexadecimal!
whatever.0a141e28.nip.io   # --> 10.20.30.40, *dot* after whatever
whatever-0a141e28.nip.io   # --> 10.20.30.40, *dash* after whatever
```

> Want to transform your dotted representation into hex? No problem:
>
> ```
> $ perl -e 'printf "%02x%02x%02x%02x\n", split /\./, shift' 10.20.30.40
> 0a141e28
> ```

- Need support for IPv6? Shift to `sslip.io`, two additional chars to
  type but you're asking for 6 instead of 4, so you have to give 2 more!
  In this case, you can only go with dashes:

```
--1.sslip.io                  # --> ::1
2a01-4f8-c17-b8f--2.sslip.io  # --> 2a01:4f8:c17:b8f::2
```

- In a local development environment, you can also leverage many more
  services that support wildcards and just answer with `127.0.0.1`:

```
here.fbi.com
what.ever.localtest.me
hey.mama.lacolhost.com
```

So now, future me... you will not forget!

To everyone else: stay safe folks!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Dokku]: https://dokku.com/
[this gist]: https://gist.github.com/tinogomes/c425aa2a56d289f16a1f4fcb8a65ea65
[nip.io]: https://nip.io/
[sslip.io]: https://sslip.io/
