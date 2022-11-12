---
title: 'quenv - quick environment'
type: post
tags: [ docker, alpine ]
comment: true
date: 2020-03-29 08:05:40 +0200
published: true
---

**TL;DR**

> Sometimes I need a quick pristine environment to use some tool I don't
> want to install on some files in a directory. Here's how [quenv][] comes
> to help.

Remember the suggestion to [Try with Docker][]? I do follow that! Especially
when there is a tool I don't want around *permanently*, but in that precise
moment would be sooo useful...

So it struck me to create [quenv][]:

- it's a [Docker][] image leveraging [Alpine Linux][], so it's tight but it
  has a fairly impressive amount of available packages
- it contains [suexec][] (which we already discussed in [Command-line Docker
  Applications - A way forward][])

so it basically allows us to do this:

```shell
docker run --rm -it -v "$PWD:/mnt" registry.gitlab.com/polettix/quenv "$@"
```

Let's see it in action:

<script id="asciicast-313264" src="https://asciinema.org/a/313264.js" async></script>

The working directory inside the container is `/mnt`, which is also the
home of the internal user, whose id and group-id are set at the beginning
to reflect those of the caller in the host. This makes it easy to
bind-mount the current working directory over it (`-v "$PWD:/mnt"`) and
forget about permissions and ownership when exiting the container.

Have fun!

[quenv]: https://gitlab.com/polettix/quenv
[Try with Docker]: {{ '/2020/01/21/try-with-docker' | prepend: site.baseurl | prepend: site.url }}
[Docker]: https://www.docker.com/
[Alpine Linux]: https://www.alpinelinux.org/
[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl | prepend: site.url }}
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
