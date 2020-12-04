---
title: ekeca additions
type: post
tags: [ security, openssl, shell ]
comment: true
date: 2020-12-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Remember [ekeca][ekeca-post]? I added a couple things to it.

So... it's almost 10 (ten!) months that I wrote about [ekeca][ekeca-post],
and I eventually remembered about it! Mission accomplished!

I did a couple of additions:

- it's now possible to generate also *client certificates*, because well...
  I need to experiment a bit with them!

- There is a new handy function to check whether a *private* key
  correspondes to a certificate (that is, to the *public* key carried by the
  certificate).

I'm somehow surprised that the last thing isn't implemented natively in
[OpenSSL][], but whatever it's quite simple: the two keys correspond if they
share the same *modulus*.

A lot of the hints around calculated a checksum over the modulus; this is a
quick hack to compare something "short" instead of the modulus in its full
width. This helps a lot when comparing stuff visually... but I guess the
program can do without this slight teensy possibility of a collision.

You can find the code [here][ekeca-line-18]; using the function is simple,
just pass the key and the certificate file paths as arguments (in any
order):

```shell
ekeca check_association /path/to/key /path/to/certificate
```

Enjoy!

[ekeca-post]: {{ '/2020/02/08/ekeca' | prepend: site.baseurl }}
[ekeca]: https://github.com/polettix/ekeca
[OpenSSL]: https://www.openssl.org/
[ekeca-line-18]: https://github.com/polettix/ekeca/blob/master/ekeca#L18
