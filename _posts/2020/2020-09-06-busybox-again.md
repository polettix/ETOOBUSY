---
title: 'Busybox (again)'
type: post
tags: [ linux, toolbox, dokku ]
comment: true
date: 2020-09-06 12:24:21 +0200
mathjax: false
published: true
---

**TL;DR**

> Another post about [Busybox][], this time more pragmatic.

It happened to me to debug a few things inside a running image (yes, a sin but
it was only temporary and saved a lot of time with re-building the whole thing
at all rounds). Fact is that I couldn't find how to install a new package
inside [herokuish][] when inside the container... and I needed an editor.

So presto! [Busybox - multipurpose executable][] does include a tiny version of
`vi`, so I downloaded it (luckily enough [herokuish][] includes `curl`) and
made a link to it named `vi`, living in `$PATH`. Yay!

Anticipating that I will need it also in the future... here's a small snippet:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2012229.js"></script>

[Local version here][] (pointing to a local version of the [Busybox][] binary,
good for X86\_64).

I actually included a slightly different version of the above script in the
source for the image, inside a standalone directory that is in `$PATH` inside
the container:

```shell
#!/bin/sh
cd "$(dirname "$(readlink -f "$0")")"
curl -Lo busybox 'https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64'
chmod +x busybox
./busybox --install .
```

It removes the checks and makes sure to install [Busybox][] in the same
directory where the script lives... whichever is more useful is totally up to
you!

[Busybox - multipurpose executable]: {{ '/2019/09/29/busybox-multipurpose-executable' | prepend: site.baseurl }}
[Busybox]: https://busybox.net/
[Local version here]: {{ '/assets/code/install-busybox.sh' | prepend: site.baseurl }}
[herokuish]: https://github.com/gliderlabs/herokuish
