---
title: Alpeanuts
type: post
tags: [ dibs, docker ]
comment: true
date: 2021-11-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I finally added stuff to [alpeanuts][].

[alpeanuts][] is a collection of scripts that leverage [dibs][] to build
small utility containers, based on [Alpine Linux][].

The typical script is like this, to build an image that contains both
[bash][] and [OpenSSH][]:

```
#!/bin/sh
md="$(dirname "$(readlink -f "$0")")"
ENTRYPOINT=/bin/bash \
   LIST='bash, openssh' \
   TAGS=alpeanuts:bassh   \
   "$md/alpeanuts"
```

The building script is `alpeanuts`, of course... and it is driven by a
few environment variables:

- `ENTRYPOINT` is what will be set as the... `entrypoint` of the
  [Docker][] image that is generated;
- `LIST`: the list of packages that should be added to the image;
- `TAGS`: the name(s) of the image to be generated.

It should be as easy as running each shell script ending in `.sh`. If
not... please open an [Issue][]!

If you just need one of the images... they're avaible in the
repository's [registry][].

Stay safe folks!

[alpeanuts]: https://gitlab.com/polettix/alpeanuts
[Alpine Linux]: https://www.alpinelinux.org/
[dibs]: https://github.com/polettix/dibs
[Docker]: https://www.docker.com/
[Issue]: https://gitlab.com/polettix/alpeanuts/-/issues
[bash]: https://www.gnu.org/software/bash/
[OpenSSH]: https://www.openssh.com/
[registry]: https://gitlab.com/polettix/alpeanuts/container_registry/2492317
