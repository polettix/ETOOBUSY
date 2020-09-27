---
title: An update to quenv
type: post
tags: [ docker, alpine ]
comment: true
date: 2020-09-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A couple touches to [quenv][].

In previous post [quenv - quick environment][] I introduced a small
[Docker][] image based on [Alpine Linux][] that contains a few small
tweaks to allow me start an *alternate* environment very quickly, while
preserving ownership of the files also in the host system. The image was
complemented by a small shell wrapper to call it - aptly named `quenv`.

A couple itches have been accumulating since March 2020, namely:

- a *lot* of times I use that image to try out some [Perl][] stuff, in
  particular installing a few modules using `carton` (see [Installing
  Perl Modules][] for more info) - which was consistently missing;

- having started with x86 stuff in the nineties using DOS, I'm so used
  to type `dir` instead of `ls` that I just define it as an alias
  *anywhere*. The shell in [Busybox][] does not use `.bashrc`, as
  expected.

Soooo... the image for [quenv][] has been updated to include `carton`
(should I need it) and the wrapper script had the addition of the `ENV`
variable:

```shell
#!/bin/sh
${DOCKER_COMMAND:-"docker"} run --rm -itv "$PWD:/mnt" -e ENV='/mnt/.ashrc' \
   registry.gitlab.com/polettix/quenv "$@"
```

So now, should I need it... I can save a `.ashrc` file in the current
directory from where I run [quenv][], and this will actually be loaded:

<script id="asciicast-362024" src="https://asciinema.org/a/362024.js" async></script>

Happy [quenv][]ing!

[quenv]: https://gitlab.com/polettix/quenv
[quenv - quick environment]: {{ '/2020/03/29/quick-environment/' | prepend: site.baseurl }}
[Try with Docker]: {{ '/2020/01/21/try-with-docker' | prepend: site.baseurl | prepend: site.url }}
[Docker]: https://www.docker.com/
[Alpine Linux]: https://www.alpinelinux.org/
[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl | prepend: site.url }}
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
[Perl]: https://www.perl.org/
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
[Busybox]: https://busybox.net/
