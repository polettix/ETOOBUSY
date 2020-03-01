---
title: A Gnuplot Docker Image
type: post
tags: [ gnuplot, docker, alpine, dibs ]
comment: true
date: 2020-03-01 00:31:41 +0100
publish: true
---

**TL;DR**

> If you are intrigued by [Gnuplot][] (e.g. after reading [Gnuplot
> Headache][], you might be interested into a [Docker][]
> [image][gnuplotter] for it.

The [dibs][dibs] file is pretty straightforward:

```
---
name: gnuplotter

packs:
  basic:
    type: git
    origin: https://github.com/polettix/dibspack-basic.git

actions:
  default:
    - from: alpine:3.9
    - pack: basic
      path: wrapexec/install
      args: ['suexec']
    - pack: basic
      path: prereqs-fromlist
      args: ['alpine', 'gnuplot', 'ttf-freefont', 'ffmpeg', 'su-exec']
      commit:
        entrypoint: ['/suexec', '--reference', '/mnt', '--']
        cmd: ['/bin/sh', '-l']
        workdir: /mnt
    - image_name: polettix/gnuplotter
      tags: ['latest', '1.0']
```

As usual, invoked as:

```shell
$ dibs -A
```

and yes, I'm regretting not making *alien mode* the default one.

If you want to use the [gnuplotter][] image, the suggestion is to mount
a host directory (e.g. `$PWD`) on `/mnt` inside the container:

```shell
$ docker run --rm -itv "$PWD:/mnt" polettix/gnuplotter
```

This has two effects:

- it allows you to use an editor in the host, and get the output files
  easily, and
- it allows the container to set the user *inside* the container to
  match the one of the mounted directory, so that you will not have
  permission problems.

All of this thanks to [suexec][], which you might remember from
[Documentation for suexec][].

That's all folks!

[Alpine Linux]: https://www.alpinelinux.org/
[Gnuplot]: http://gnuplot.info/
[Docker]: https://www.docker.com/
[Try with Docker]: {{ '/2020/01/21/try-with-docker' | prepend: site.baseurl | prepend: site.url }}
[Gnuplot Headache]: {{ '/2020/02/26/gnuplot-headache' | prepend: site.baseurl | prepend: site.url }}
[gnuplotter]: https://hub.docker.com/repository/docker/polettix/gnuplotter
[dibs]: https://github.com/polettix/dibs
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
[Documentation for suexec]: {{ '/2020/02/14/docs-for-suexec' | prepend: site.baseurl | prepend: site.url }}
