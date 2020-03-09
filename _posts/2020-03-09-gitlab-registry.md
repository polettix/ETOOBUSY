---
title: GitLab Registry
type: post
tags: [ gitlab, docker, dibs ]
comment: true
date: 2020-03-09 07:35:08 +0100
published: true
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

If you are curious and want to take a look at an example, you can just open
[debian-dev][], which we will hopefully discuss a bit shortly.

By the way, installing [dibs][] is really, *really*, **really** easy: just
download the driver script described in [dibs update to 0.5.4][] and you are
all set!

[dibs]: http://blog.polettix.it/hi-from-dibs/
[Docker]: https://www.docker.com/
[Docker Hub]: https://hub.docker.com/
[dibs update to 0.5.4]: {{ '/2020/03/07/dibs-update' | prepend: site.baseurl | prepend: site.url }}
[GitLab]: https://gitlab.com/
[debian-dev]: https://gitlab.com/polettix/debian-dev
