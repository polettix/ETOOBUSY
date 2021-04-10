---
title: A few considerations about CoreDNS
type: post
tags: [ dns, coding ]
comment: true
date: 2021-04-10 17:27:13 +0200
mathjax: false
published: true
---

**TL;DR**

> Thinking about a simple backend for [CoreDNS][].

I *might* have to use [CoreDNS][] for a work-related issue and I started
looking at it.

On the one hand, it's a cool project, whose adoption by the
[Kubernetes][] project says a lot about the trust that there is in this
technology.

On the other hand... I'm not totally sure it's the right choice for a
more generic project. I mean, it's working fine in [Kubernetes][], but
the backend is totally not reusable, so I seem to be a bit out of luck
if I need a more common DNS that I need to manipulate with some RESTish
API.

I saw that there are a few more *traditional* ways to support a
different backend:

- [etcd][] - the plugin page seems discouraging;
- [plain host-files][host] - very quick to setup and pre-integrated plugin,
  but the interface is *really* low-level;
- [other][auto] [file-based][file] alternatives - still quick to setup, but *files*...

Ideally I'd like something that I can then install inside another
[Kubernetes][] cluster and have some kind of persistence, so my choice
so far is to use the [Postgresql][] backend [pdsql][]. Which, by the
way, is **not** included in the binary by default, so I have to
recompile [CoreDNS][]...

It's a lot of work for something that I was expecting to *work out of
the box* 😅

[CoreDNS]: https://coredns.io/
[Kubernetes]: https://kubernetes.io/
[Postgresql]: https://www.postgresql.org/
[host]: https://coredns.io/plugins/hosts/
[etcd]: https://coredns.io/plugins/etcd/
[auto]: https://coredns.io/plugins/auto/
[file]: https://coredns.io/plugins/file/
[pdsql]: https://coredns.io/explugins/pdsql/
