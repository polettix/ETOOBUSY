---
title: dibs update to 0.5.4
type: post
tags: [ dibs, docker ]
comment: true
date: 2020-03-07 17:52:47 +0100
published: true
---

**TL;DR**

> I recently uploaded an updated [dibs][] image that can be run with
> [Docker][].

It's on the [Docker Hub][] as [dibs][dibs-hub], tags `0.5`, `0.5.4`, or
`latest` (unless, of course, you want to use the full date tag
`20200307-095549-18837`).

The driver script can be *slightly* simplified with respect to what
described in [dibs][]:

```shell
#!/bin/sh
docker run --rm \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v "$PWD:/mnt" \
   -e "DIBS_HOST_REMAP_DIR=/mnt:$PWD" \
   -- polettix/dibs:0.5 "$@"
```

[Local version here][] - save as `dibs` somewhere in `PATH`, set the
execution bit, and you're done - you have a wrapper around [dibs][] that
will work in the current directory.

Requires `root` permissions to run - but only to run [suexec][] as described
in [Command-line Docker Applications - A way forward][].

[dibs]: http://blog.polettix.it/hi-from-dibs/
[Docker]: https://www.docker.com/
[Docker Hub]: https://hub.docker.com/
[dibs-hub]: https://hub.docker.com/repository/docker/polettix/dibs
[Local version here]: {{ '/assets/code/dibs' | prepend: site.baseurl | prepend: site.url }}
[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl | prepend: site.url }}
[suexec]: https://github.com/polettix/dibspack-basic/blob/master/wrapexec/suexec
