---
title: ProtoWebz
type: post
tags: [ perl, mojolicious, web ]
comment: true
date: 2022-02-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Where I introduce [ProtoWebz][].

[ProtoWebz][] is a toy project with the ambitious aim to support faster
prototyping *in some cases*. These cases mostly being trying out ideas
for APIs to expose stuff that is inside databases.

It has been sitting there for a couple of months and it's about time
that I start writing about it, unless I really want to forget about it.

Just a bird's eye view for now:

- the whole thing is built on top of [Mojolicious][] because it just
  makes sense.
- APIs are described in OpenAPI, thanks to the excellent
  [Mojolicious::Plugin::OpenAPI][].
- The [Docker][] image is built with [dibs][] and includes the
  batteries, including an example API specification and an example
  database, as well as the stuff to add and consume documentation more
  easily.
- The basic included modules allow [defining SQL queries with
  placeholders and bindings][query example] directly in the [OpenAPI][]
  specification, within extensions. This is where the "prototyping
  assertion" comes from.

Well... I'll now be publicly shamed if I don't elaborate more and help
future me!

In the meantime, stay safe!

[Perl]: https://www.perl.org/
[ProtoWebz]: https://gitlab.com/polettix/protowebz
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Mojolicious::Plugin::OpenAPI]: https://metacpan.org/pod/Mojolicious::Plugin::OpenAPI
[Docker]: https://www.docker.com/
[dibs]: http://blog.polettix.it/dibs-saga/
[OpenAPI]: https://www.openapis.org/
[query example]: https://gitlab.com/polettix/protowebz/-/blob/7b8cd0753709cd1998cef21e88d9a39ba3c2c026/openapi.yaml#L157
