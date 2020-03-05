---
title: Docker Run Here
type: post
tags: [ docker, command line ]
comment: true
date: 2020-03-05 21:07:06 +0100
preview: true
---

**TL;DR**

> Frequently running [Docker][] images with [suexec][] inside? Chances are
> you can benefit from this little one-line script.

While running [Docker][] images created for the shell (see [Command-line
Docker Applications - A way forward][] for some background), I often find
myself typing this over and over:

```shell
$ docker run --rm -itv "$PWD:/mnt" foo/bar-baz:latest ...
```

So why not put that in a shell script in `PATH`?

```shell
#!/bin/sh
${DOCKER_COMMAND:-"docker"} run --rm -itv "$PWD:/mnt" "$@"
```

You can also download [drhere][] and save it somewhere in `PATH`.

The use of the unquoted `DOCKER_COMMAND` environment variable is to allow
overriding the command from the environment, e.g. if you need to pre-pend
`sudo` to all your meaningful invocations of `docker`, like this:

```shell
host$ export DOCKER_COMMAND='sudo docker'
host$ drhere polettix/gnuplotter
container$ # ...
```

I guess this is it for today!

[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl | prepend: site.url }}
[suexec]: https://github.com/polettix/dibspack-basic/blob/master/wrapexec/suexec
[drhere]: {{ '/assets/code/drhere' | prepend: site.baseurl | prepend: site.url }}
[Docker]: https://www.docker.com/
