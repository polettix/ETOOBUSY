---
title: RDAP is the new WHOIS
type: post
tags: [ web, dns ]
comment: true
date: 2023-06-20 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [RDAP][] is the new [WHOIS][].

So... the [WHOIS][] protocol is kind of a joke and its *too free form*
basically led to a situation that is not easily addressed with code.

As a result, the [RDAP][] (Registration Data Access Protocol) was designed
to supersede it with something that is *modern* and *structured*.

The *structure* comes from two things:

- using [JSON][] syntax;
- sticking to a specific structure in the JSON.

The *modern* comes from the adoption of the HTTP REST model.

This will hopefully make API-level consumption of data easier. Nowadays,
almost all API-level endpoints are ad-hoc services that provide some form of
pre-parsed data, usually at a cost (although sometimes with a free tier).
Moving to [RDAP][] helps define a standard response and stimulate
registries to provide data in a code-friendly way out of the box.

Let's cross fingers and... stay safe!


[RDAP]: https://datatracker.ietf.org/doc/html/rfc7480
[WHOIS]: https://datatracker.ietf.org/doc/html/rfc3912
[JSON]: https://datatracker.ietf.org/doc/html/rfc8259
[RDAP response]: https://datatracker.ietf.org/doc/html/rfc9083
