---
title: Docker image generation for skfold reshaped
type: post
tags: [ dibs, docker, skfold ]
comment: true
date: 2020-07-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The [Docker][] image generation for [skfold][], done via [dibs][], has
> been made a bit cleaner.

After having finally produced a couple of base images for doing stuff
with [Perl][] (see [Docker base images for Perl][]), I moved the
[skfold][] generation of a [Docker][] image on to use those images.

This means that the fatpacked version is produced *inside* the
container, which in my opinion is a bit saner than before. Not too much.
It also means that the whole process should be usually faster, because I
don't have to re-create the builder environment from scratch every time.

I'm still using the fatpacked version because it's smaller and saves
about 800 kbyte according to a rule of thumb. With this new way of
generating images, though, it will be much easier to revert to a
`local`-based setup like most of my other [Perl][] projects brought in
[Docker][].

[Docker base images for Perl]: {{ '/2020/07/01/perl-docker-bases' | prepend: site.baseurl }}
[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
[Docker]: https://www.docker.com/
[dibs]: https://github.com/polettix/dibs/
