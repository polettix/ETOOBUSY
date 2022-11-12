---
title: suexec with user id 0
type: post
tags: [ dibs, docker, suexec ]
comment: true
date: 2020-06-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where [suexec][] plays nicely with user id `0`.

As explained in [Command-line Docker Applications - A way forward][], I
rely heavily on a small shell wrapper [suexec][] to adjust the internals
of the container and cope with some *impedance mismatch* at the
interface.

My typical usage is to rely upon a bind-mounted directory in the
container (usually `/mnt`) to seek for the user id and group id of the
caller, and adjust the internal user's id and group id(s) accordingly.

What happened when I did *not* do the bind mounting, though, was to get
an annoying error:

```shell
$ docker run --rm registry.gitlab.com/polettix/dokyll
cannot associate id '0' to 'jekyll' in '/etc/passwd'

$ echo $?
1
```

The problem is, when *not* doing the bind-mounting, the `/mnt` directory
is owned by `root`, which has user identifier `0`. Simply put, I cannot
change the internal user's (`jekyll`, in this case) identifier to `0`,
because that's `root`'s very special identifier. Ouch.

The newer version of [suexec][] does not suffer from this problem any
more. It will still warn you about the impossibility to remap the
internal user to a different identifier though:

```shell
$ docker run --rm docker.pkg.github.com/polettix/skfold/skf

*** WARNING: not remapping user <urist> to user id 0

...
```
so that you can still remember that you have to do the bind-mounting, at
some time!


[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl | prepend: site.url }}
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
