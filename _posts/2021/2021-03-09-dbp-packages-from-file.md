---
title: dibspack-basic enhancement for packages
type: post
tags: [ dibs, perl, docker ]
comment: true
date: 2021-03-09 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I recently added a small feature in [dibspack-basic][].

I sometimes write about [dibs][], a *maximum overkill* system I use to
build [Docker][] images. Which, by the way, prevented me from learning
about what the rest of the world is doing to this regard (e.g. I heard
about [buildah][]).

One nice byproduct of it is the standalone [dibspack-basic][], which
contains a set of programs that can be useful *inside* a container, e.g.
to build [Perl][] stuff, manage prerequisites, copy stuff around, etc.

I extended the package management common part to also get inputs from a
file, in addition to the argument list. You know, [the classic
`-f`/`--from` option][option] that is found in so many places around:

```
(-f|--from)
   [ $# -gt 1 ] || LOGDIE "cannot honor $1"
   shift
   if [ -r "$1" ] ; then
      modules_list="$modules_list $(encode_array $(cat "$1"))"
   fi
   if [ -n "$AUTO_PACKAGE" -a -r "$1.$AUTO_PACKAGE" ] ; then
      modules_list="$modules_list $(encode_array $(cat "$1.$AUTO_PACKAGE"))"
   fi
   shift
   ;;
```

On a slightly more annoying side, the recent addition of support for
[zypper][] is actually not very helpful. I discovered that some things
that other distrubution handle as *virtual packages* (which are just
plain packages, from the point of view of the casual user), these have a
distinct *type* for [zypper][]. Dang.

Well, enough for today!

[dibspack-basic]: https://github.com/polettix/dibspack-basic
[buildah]: https://buildah.io/
[Docker]: https://www.docker.com/
[dibs]: https://blog.polettix.it/hi-from-dibs/
[Perl]: https://www.perl.org/
[option]: https://github.com/polettix/dibspack-basic/blob/27ad78326c8ac70fb374613f5415c5b7340f93ea/package/generic.sh#L26
[zypper]: https://software.opensuse.org/package/zypper
