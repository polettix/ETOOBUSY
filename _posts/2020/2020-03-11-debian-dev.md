---
title: debian-dev
type: post
tags: [ coding, debian ]
comment: true
date: 2020-03-11 00:43:06 +0100
published: true
---

**TL;DR**

> I plan to use [debian-dev][] for trying out things in the future.

I recently created the [debian-dev][] project in [GitLab][] to keep track of
a [Docker][] image useful for trying things out without cluttering my main
virtual machine.

The [Docker][] image is built with [dibs][]. While I initially started with
a more complex setup leveraging [dibspack-basic][], I eventually opted for a
much simpler design. You can still find the former in the [devel][] branch,
while the [master][] branch holds the simpler design.

This image starts from [debian:9-slim][] and installs the basic building
environment, as well as [Perl][] (including libraries for compiling), and
[git][]. I should probably do something based on a more recent version of
[Debian][], probably.

[debian-dev]: https://gitlab.com/polettix/debian-dev
[GitLab]: https://gitlab.com/
[Docker]: https://www.docker.com/
[dibs]: http://blog.polettix.it/hi-from-dibs/
[dibspack-basic]: https://github.com/polettix/dibspack-basic
[devel]: https://gitlab.com/polettix/debian-dev/-/tree/devel
[master]: https://gitlab.com/polettix/debian-dev/-/tree/master
[debian:9-slim]: https://hub.docker.com/layers/debian/library/debian/9-slim/images/sha256-061d959e814c2dbc0e47c6ceeee621ff5ae53d109728bb7767916eda20b5f459?context=explore
[Perl]: https://www.perl.org/
[git]: https://git-scm.com/
[Debian]: https://www.debian.org/
