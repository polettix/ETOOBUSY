---
title: dibspack-basic auto package management
type: post
tags: [ dibs, docker, Linux ]
comment: true
date: 2021-03-12 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Yet another post on [dibspack-basic][]. Probably alpha-stage stuff
> though.

For reasons that I'll probably write about shortly, I've been trying out
a few different designs to ease expressing package requirements from the
distribution point of view, in a way that allows to address multiple
distributions at the same time.

The current one in [auto][] is not the most clever or the cleanest, but
works.

```shell
#!/bin/sh
exec 1>&2
set -e

script="$(readlink -f "$0")"
scriptdir="$(dirname "$script")"
basedir="$(dirname "$scriptdir")"

. "$basedir/lib.sh"
export_all_enviles

prereqs_dir="$DIBS_DIR_SRC"
[ -z "PREREQS_DIR" ] || prereqs_dir="$prereqs_dir/$PREREQS_DIR"

. /etc/os-release
packman=''
case "$ID" in
   (alpine)
      packman='apk'
      ;;
   (opensuse*)
      packman='zypper'
      ;;
   (debian)
      packman='apt-get'
      ;;
   (centos)
      packman='yum'
      ;;
   (*)
      printf >&2 '%s\n' "unknown OS '$ID'"
      exit 1
      ;;
esac

full_packman="$scriptdir/$packman"
target_list="$prereqs_dir/prereqs.$packman"
target_script="$target_list.sh"
if [ -x "$target_script" ] ; then
   "$target_script" "$@"
elif [ "$#" -gt 0 ] ; then
   "$full_packman" "$@"
fi
if [ -r "$target_list" ] ; then
   "$full_packman" -f "$prereqs_dir/prereqs.$packman"
fi
```

It auto-detects which package manager should be used based on the
contents of `/etc/os-release`, then makes sure to load all modules from
a file if it's present.

If a suitable shell file is present, it is executed. I know, this is so
low-level... but addresses a little misunderstanding I had with
[zypper][] without the need to wait for another week of weighting
designs.

Stay safe!

[auto]: https://github.com/polettix/dibspack-basic/blob/27ad78326c8ac70fb374613f5415c5b7340f93ea/package/auto
[zypper]: https://software.opensuse.org/package/zypper
[dibspack-basic]: https://github.com/polettix/dibspack-basic
