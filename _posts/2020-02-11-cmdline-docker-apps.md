---
title: Command-line Docker Applications
type: post
tags: [ docker, command line ]
series: Command-line Docker Applications
comment: true
date: 2020-02-11 08:45:59 +0100
published: true
---

**TL;DR**

> [Docker][] paved the way to encapsulating applications so that you don't
> have to go through the dependency hell. This is smoother for services or
> non-interactive stuff though, and some extra steps are required for
> command-line applications.

Most of the times I interact with containers, it's for some service that can
live cozily inside its own space pretending it's a separate server from the
rest of the world. It's no surprise that many people wonder whether it's
better to use containers or virtual machines when seen from this angle.

Many times, though, I code little programs and I appreciate the
*portability* that [Docker][] gives me. Just make sure that the program
works properly inside the container, and you get it working wherever
[Docker][] can run that container, without worrying about the dependency
hell. Sounds amazing, right?

Alas, in those cases I still want to work on stuff (e.g. files) that are on
the *host* machine, not inside the container. This is where [Docker][]'s
option `-v`/`--volume` comes very handy, allowing to bind-mount a directory
inside the *host* in some place of the container's filesystem. A typical
pattern I adopt is something like this:

```shell
docker run -v "$PWD:/mnt" ...
```

i.e. I bind-mount the current directory in the *host* to the `/mnt` path of
the container, so that I can work on files in the local directory and
whatever can be reached from there.

Problem solved? Not so fast.

There is still a mismatch with users and file permissions. When you run a
container, you become a *different* user inside the container - normally, a
user that makes sense inside the container, which means either `root` in the
default case or some user that is included in the *container*'s
`/etc/passwd` file.

This is where the portability somehow breaks. When setting up the container
image, I have to *decide* which user I want when I install stuff or when I
will run the container, which means not just deciding a *name*/*group* for
the user (which is the least problem) but also committing to *identifiers*
for them. From the operating system's point of view, these identifiers are
the only things that mean something. And, again, these identifiers live
inside the *container* but will affect files in the *host*.

Example time:

<script id="asciicast-299430" src="https://asciinema.org/a/299430.js" async></script>

This mismatch needs some solution to make stuff work smoothly on the command
line too... we cannot just rely upon luck and hope that the user identifiers
in the *host* and in the *container* match, can we?!?

In case you're wondering, you can repeat the whole experience above using
the [Docker][] image [polettix/docker-mismatch][] and tag `1.0`. Enjoy!

[Docker]: https://www.docker.com/
[polettix/docker-mismatch]: https://hub.docker.com/repository/docker/polettix/docker-mismatch
