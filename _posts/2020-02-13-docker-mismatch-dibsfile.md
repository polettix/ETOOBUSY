---
title: Dibs file for docker-mismatch
type: post
tags: [ docker, dibs ]
comment: true
date: 2020-02-13 00:02:09 +0100
published: true
---

**TL;DR**

> Curious about how the images in [polettix/docker-mismatch] were generated?

There's a [dibs][] file for it:

<script src="https://gitlab.com/polettix/notechs/snippets/1939499.js"></script>

[Local version here].

Want to try it out? OK:

- save as `dibs.yml` in an empty directory
- change the target names if you want..
- run `dibs -A default alt`

Easy 😄

[polettix/docker-mismatch]: https://hub.docker.com/repository/docker/polettix/docker-mismatch
[here]: https://gitlab.com/polettix/notechs/snippets/1939499
[dibs]: https://github.com/polettix/dibs
[Local version here]: {{ '/assets/other/2020-02-13.dibs.yml' | prepend: site.baseurl | prepend: site.url }}
