---
title: Generalized quenv
type: post
tags: [ shell, docker ]
comment: true
date: 2020-10-15 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A small generalization for [quenv][] (the script).

I seem to have talked even too much about [quenv][] ([quenv - quick
environment][] and [An update to quenv][]), but after 
[A cheap trick to manipulate PERL5LIB][] I got the idea to make the
wrapper script *slightly* more general.

Here it is in its current form:

```shell
#!/bin/sh
${DOCKER_COMMAND:-"docker"} run --rm -itv "$PWD:/mnt" -e ENV='/mnt/.ashrc' \
   "$(basename "$0"):active" "$@"
```

The news are that the image name is no more hardwired but deduced from
the name of the *executable*. This is an old trick to have a polyform
executable do stuff depending on its name (much like [busybox][] does).

In this way, I can:

- tag a [Docker][] image with `<name>:active`
- create a symbolic link to the [quenv][] wrapper

and enjoy the image as a command line item (provided that it has the
machinery to work like this, see [Command-line Docker Applications - A
way forward][] for more on this topic).


[quenv]: https://gitlab.com/polettix/quenv
[quenv - quick environment]: {{ '/2020/03/29/quick-environment/' | prepend: site.baseurl }}
[An update to quenv]: {{ '/2020/09/28/quenv-update/' | prepend: site.baseurl }}
[A cheap trick to manipulate PERL5LIB]: {{ '/2020/10/12/perl5lib-cheap-trick' | prepend: site.baseurl }}
[busybox]: https://busybox.net/
[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl }}
[Docker]: https://www.docker.com/
