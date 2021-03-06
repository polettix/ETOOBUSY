---
title: Package Installers for dibspack-basic
type: post
tags: [ dibs, docker ]
comment: true
date: 2020-03-02 07:32:02 +0100
published: true
---

**TL;DR**

> Where we discuss of a quicker way of installing distribution-related
> packages with [dibs][].

When packaging stuff with [dibs][], I often stumble(d) in the following
pattern with [dibspack-basic][]:

- install pre-requisites;
- install [suexec][] (see [Command-line Docker Applications - A way
  forward][] for the reason why I include it in many container images).

The pre-requisites installation method via [prereqs][] works fine and is
very general - you basically provide scripts for managing
pre-requisites - but most of the times it's just installing modules with
a specific package manager. So why not provide a shortcut consumable
from the dibsfile?

Enter [package][], a set of three (as of now) wrappers for `apk`,
`apt-get` and `yum` respectively, which also provide a shortcut to
install [suexec][] while we're at it.

In particular, they accept as command-line options a list of packages to
be installed. If the initial element(s) of the list is(/are) one of the
three strings `--suexec`, `--dockexec`, or `--profilexec`, then the
corresponding program from [wrapexec][] will be installed. You can
insist on passing one of these strings by tossing a `--`, which will
interrupt the scanning.

Examples:

```yaml
# ...
packs:
  basic:
    type: git
    origin: https://github.com/polettix/dibspack-basic.git

actions:

  whatever:
    - from: alpine:3.9

    # this installs packages gnuplot, ffmpeg, and su-exec in Alpine
    # Linux
    - pack: basic
      path: package/apk
      args:
        - gnuplot
        - ffmpeg
        - su-exec

    # this installs suexec from dibspack-basic and perl from Alpine
    # Linux
    - pack: basic
      path: package/apk
      args:
         - --suexec
         - perl
```

You get the idea... cheers!

[dibs]: https://github.com/polettix/dibs
[dibspack-basic]: https://github.com/polettix/dibspack-basic
[dibspack-basic]: https://github.com/polettix/dibspack-basic
[prereqs]: https://github.com/polettix/dibspack-basic#prereqs
[package]: https://github.com/polettix/dibspack-basic/tree/master/package
[wrapexec]: https://github.com/polettix/dibspack-basic/tree/master/wrapexec
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
[Command-line Docker Applications - A way forward]: {{ '/2020/02/12/cmdline-docker-app-a-way' | prepend: site.baseurl | prepend: site.url }}
