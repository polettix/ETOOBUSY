---
title: Self-signed wildcard certificates
type: post
tags: [ openssl, security ]
comment: true
date: 2023-04-19 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A [useful gist][] for generating a self-signed certificate with wildcards.

Using self-signed certificates *can* be a viable solution, especially in
development environments. Sometimes... it can also be useful to have these
certificates supporting wildcards.

This [useful gist][] is very interesting for doing this.

It sort-of overlaps with [ekeca standalone certificate for a server][], only
producing one less artifact (i.e. the one-foff Root CA certificate), forcing
to install the generated certificate inside the pool of available ones in
the client machine. This might or might not be useful, so let's just keep it
in the bag.

Cheers!

[useful gist]: https://gist.github.com/dmadisetti/16006751fd6e1526fa9c2f2e1660e8e3
[ekeca standalone certificate for a server]: {{ '/2022/11/20/ekeca-standalone-certificate/' | prepend: site.baseurl }}
