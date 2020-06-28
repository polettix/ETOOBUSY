---
title: Docker base images for Perl
type: post
tags: [ perl, docker, dibs ]
comment: true
date: 2020-07-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> At long last, I saved a couple of base images to ease my workflow of
> bringing [Perl][] software in [Docker][] images.

You can find:

- a repository: [perldi][] (*[Perl][] [Docker][] Images)
- [Docker][] images: [perldi/packages][]

Images are based on [Alpine Linux][] and follow the same versionining,
plus an additional *patch* level just in case (optional). So, you can
simply do this:

```text
FROM docker.pkg.github.com/polettix/perldi/builder:3.11
```

and get a visual clue that you're working on [Alpine Linux][] version
3.11 below.

Brought to you thanks to [dibs][].

[perldi]: https://github.com/polettix/perldi/
[perldi/packages]: https://github.com/polettix/perldi/packages/
[Perl]: https://www.perl.org/
[Docker]: https://www.docker.com/
[dibs]: https://github.com/polettix/dibs/
[Alpine Linux]: https://www.alpinelinux.org/
