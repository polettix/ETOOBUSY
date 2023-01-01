---
title: 'Gitolite image - Helm chart inside'
type: post
tags: [ gitolite, git, helm, kubernetes ]
comment: true
date: 2022-03-18 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> The [gitolite-dibs][] image now contains the [Helm][] chart too.

I'm playing with building a [Docker][] image for [Gitolite][], stored at
[gitolite-dibs][]. Images are also available in the [container
registry][].

Since version `0.2.1`, the image also contains a [Helm][] chart that can
be used to deploy it. At the end of the day, a [Docker][] image is a
*glorified archive of files*, so why not include the image too? This is
a strategy that I adopted in the past, with success I think (I'm always
sure to have all I need when I bring the image with me).

The [entrypoint][] program includes a `chart` (aliased `helm`)
sub-command to get this [Helm][] chart, like this:

```
$ VERSION='0.2.1'   # or whatever you want after this
$ IMAGE="registry.gitlab.com/polettix/gitolite-dibs:$VERSION"
$ docker run --rm "$IMAGE" chart | tar x
```

Piping to `tar` makes sure that the only file inside the TAR archived
that is printed out by the `docker` command is extracted locally; this
trick allows preserving the file name of the chart.

The version of the chart *might* be different from that of the image...
because the chart has its own life and evolution, independently of how
it is shipped.

I guess it's everything for this post... stay safe!

[Perl]: https://www.perl.org/
[Gitolite]: https://gitolite.com/gitolite/
[Docker]: https://www.docker.com/
[Kubernetes]: https://kubernetes.io/
[dibs]: https://github.com/polettix/dibs
[Helm]: https://helm.sh/
[Gitolite - a dibs repository]: {{ '/2022/02/21/gitolite-dibs/' | prepend: site.baseurl }}
[gitolite-dibs]: https://gitlab.com/polettix/gitolite-dibs
[Gitweb]: https://git-scm.com/docs/gitweb
[Gitea]: https://gitea.io/
[gitweb-theme]: https://github.com/kogakure/gitweb-theme
[container registry]: https://gitlab.com/polettix/gitolite-dibs/container_registry
[entrypoint]: https://gitlab.com/polettix/gitolite-dibs/-/blob/61c9ae2c925e1852a8ca446ae1331d073d20c598/src/entrypoint#L145
