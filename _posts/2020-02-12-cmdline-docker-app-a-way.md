---
title: Command-line Docker Applications - A way forward
type: post
tags: [ docker, command line ]
comment: true
date: 2020-02-12 08:00:00 +0100
published: false
---

**TL;DR**

> In [Command-line Docker Applications][] we laid out an issue about running
> [Docker][] images for daily jobs that have to work on files in the *host*.
> Here's one possible way forward, if you trust starting your containers as
> `root`.

The solution I usually adopt is to rely on a *wrapper* shell script inside
the container, to be run as `root`. It will make sure that there is a user
*inside the container* matching the requests from the outside (this is
flexible) and then it will run the *real* command as *that user*, using
[su-exec][] to avoid having intermediate executors.

The *wrapper* itself is included in the repository [dibspack-basic][] as
[suexec][]. It *still* does not have proper documentation (my fault!) but
you can see it in action here:

<script id="asciicast-299480" src="https://asciinema.org/a/299480.js" async></script>

So... the wrapper makes sure that there is a suitable user inside the
container, even though the image was not created with that user inside in
the first place.

(If you're wondering, yes the test image above is available at
[polettix/docker-mismatch] with tag `alt-1.0`).

Of course there's a drawback: the container has to be started with user
`root` (see the `-u root` in the [asciinema][] above?), so that it can
manipulate `/etc/passwd` (if needed) and do the magic.

In a service/generic setup this would be a big, Big, BIG problem: we should
always strive to run containers with the least privilege needed. In this
case, though, we're talking about running interactive commands... so your
mileage may vary depending on the *host* you are on and the permissions that
have been granted.

In a virtual machine inside your PC... I guess it's OK. What do you think?

[Command-line Docker Applications]: {{ '/2020/02/11/cmdline-docker-app' | prepend: site.baseurl | prepend: site.url }}
[Docker]: https://www.docker.com/
[polettix/docker-mismatch]: https://hub.docker.com/repository/docker/polettix/docker-mismatch
[su-exec]: https://github.com/ncopa/su-exec
[dibspack-basic]: https://github.com/polettix/dibspack-basic
[suexec]: https://github.com/polettix/dibspack-basic/blob/master/wrapexec/suexec
[asciinema]: https://asciinema.org/
[polettix/docker-mismatch]: https://hub.docker.com/repository/docker/polettix/docker-mismatch
