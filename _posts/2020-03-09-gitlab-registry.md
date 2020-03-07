---
title: GitLab Registry
type: post
tags: [ gitlab, docker, dibs ]
comment: true
date: 2020-03-09 08:00:00 +0100
preview: true
---

**TL;DR**

> I didn't know (well... remember) that [GitLab][] projects also get a
> [Docker][] registry - it seems very good for [dibs][] projects 😎

I usually upload [Docker][] images produced with [dibs][] on the [Docker
Hub][] - after all, it's easy to use and it's the default one in [Docker][]
installations.

I recently discovered (well, maybe re-discovered) that projects in
[GitLab][] also get a registry to upload images. So, it seems the perfect
way to host a [dibs][] project and also the produced images.

By the way, installing [dibs][] is really, *really*, **really** easy: just
download the driver script described in [dibs 0.5.4][] and you are all set!

[dibs]: http://blog.polettix.it/hi-from-dibs/
[Docker]: https://www.docker.com/
[Docker Hub]: https://hub.docker.com/
[dibs 0.5.4]: {{ '/2020/03/07/dibs-update' | prepend: site.baseurl | prepend: site.url }}
[GitLab]: https://gitlab.com/
