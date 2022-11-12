---
title: 'Crypt::LE update'
type: post
tags: [ perl, tls, acme2, letsencrypt ]
comment: true
date: 2021-03-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I updated to a new release of [Crypt::LE][].

I'm using [Let's Encrypt][letsencrypt] to get free TLS certificates for my
website. No big deal.

Except that I was still using the previous version of the [ACME protocol][],
which is going for good by June. I actually like very much how the sunset is
being done - getting errors from now and then. I started receiving these
errors in my mailbox, and with plenty of time I've been finally able to take
a look at it.

Long story short, [Crypt::LE][] is capable of handling the latest protocol
version (i.e. [ACME v2][], a.k.a. [RFC 8555][ACME v2]), so after about 5
years I did the upgrade with a few hiccups (including the total
restructuring of the underlying data model for [dibs][] which happened in
the meantime 😅).

If you're getting those nagging notifications... the new [Crypt::LE][] is
(so far!) highly suggested!

[Crypt::LE]: https://metacpan.org/pod/Crypt::LE
[letsencrypt]: https://letsencrypt.org/
[ACME protocol]: https://letsencrypt.org/docs/acme-protocol-updates/
[ACME v2]: https://tools.ietf.org/html/rfc8555
[dibs]: https://blog.polettix.it/hi-from-dibs/
