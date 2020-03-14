---
title: GitHub has a Docker Registry too
type: post
tags: [ github, docker, dibs ]
comment: true
date: 2020-03-14 23:03:19 +0100
published: true
---

**TL;DR**

> If you were wondering whether [GitHub][] provides a [Docker][] registry
for keeping images, you should already know by now.

So it happens that I found a bug in [dibs][], and of course [I fixed
it][dibs-commit]. As it happens, I *also* release it as a [Docker][] image,
of course produced with [dibs][] itself (self-hosting for the win!), which
is hosted at the [Docker Hub][] (in particular, it's image
[polettix/dibs][]).

It would be so good to host the produced image in GitHub, close to the
code... if only it were possible...

Well, yes it **is** possible. so now the [dibs repository][] has a
[packages][] section... with the [Docker][] images. Yay!


[GitHub]: https://www.github.com/
[Docker]: https://www.docker.com/
[dibs]: http://blog.polettix.it/hi-from-dibs/
[dibs-commit]: https://github.com/polettix/dibs/commit/b3fd1452838b00f044daecbe50a2dd4c90cd339e
[Docker Hub]: https://hub.docker.com/
[polettix/dibs]: https://hub.docker.com/r/polettix/dibs
[dibs repository]: https://github.com/polettix/dibs
[packages]: https://github.com/polettix/dibs/packages
