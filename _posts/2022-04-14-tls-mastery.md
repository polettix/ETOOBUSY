---
title: TLS Mastery
type: post
tags: [ tls, security, openssl ]
comment: true
date: 2022-04-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I bought [TLS Mastery][] by [Michael W Lucas][mwl] and it seems amazing.

It's no secret that I'm intrigued by TLS (e.g. see the series starting
at [Bare-bones Root CA][]), and it's *also* no secret that I'm an
amateur at best. More space to learn and improve, take that Gurus!

I recently bought [TLS Mastery][] by [Michael W Lucas][mwl] and I only
started looking at it, but right now I'm already happy about the
purchase. I'm keen to see how I can enhance the [ekeca][] test script
from the suggestions, in addition to learn more about the whole thing of
managing a lab CA.

Yes, a *lab* CA, because (start of chapter 10):

> Certificate Authorities are run by people. No, not people like you and
> I. Running a CA requires both discipline and meticulous attention to
> detail, qualities most of us only think we have. When given a choice
> between using an external Certificate Authority and running your own,
> you should almost certainly use an outside one for public facing
> systems.

This, at least, I was already aware of. Probably with the exception that
for public facing system, in my case `s/you should almost
certainly/MUST/`.

Just going a bit further into the chapter, it's clear that I *need* this
book. It talks about the OCSP responder and I'm like *What the heck is
an OCSP responder?!?* I'll see.

Stay safe!

[TLS Mastery]: https://www.tiltedwindmillpress.com/product/tls/
[mwl]: https://mwl.io/
[Bare-bones Root CA]: /2020/01/30/bare-bones-root-ca/
