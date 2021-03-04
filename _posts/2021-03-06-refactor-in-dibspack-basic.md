---
title: Refactor in dibspack-basic
type: post
tags: [ dibs, perl, coding, docker ]
comment: true
date: 2021-03-06 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> From time to time I add stuff to [dibspack-basic][].

For a small project I have in mind I'll probably need to work a bit with
[dibs][] using [OpenSUSE][] images and installing modules inside them.

To do this, my set of tools of election is [dibspack-basic][], but it is
lacking a suitable wrapper for [zypper][]. Well, it *was* lacking:

```shell
#!/bin/sh
update_package_database() { $SUDO zypper refresh         ; }
install_packages()        { $SUDO zypper install -y "$@" ; }
. "$(dirname "$0")/generic.sh"
```

While I was at it, I noticed that all current wrappers shared *a lot* of
code in a cut-and-pastish way that had abundantly passed the threshold
for refactoring. Hence, the common part has now been poured into
[generic.sh][]:

```shell
#!/bin/sh
exec 1>&2
set -e

script="$(readlink -f "$0")"
scriptdir="$(dirname "$script")"
basedir="$(dirname "$scriptdir")"

. "$basedir/lib.sh"
export_all_enviles

# This must be already provided in the environment
update_package_database

# Cope with "virtual" pacakges from dibspack-basic
while [ $# -gt 0 ] ; do
   case "$1" in
      (--suexec|--dockexec|--profilexec)
         name="${1#--}"
         $SUDO cp "$basedir/wrapexec/$name" /
         $SUDO chmod +x "/$name"
         shift
         ;;
      (--)
         shift
         break
         ;;
      (*)
         break
         ;;
   esac
done

# This must be already provided in the environment
install_packages "$@"
```

At this point, any wrapper just has to define two simple functions
`update_package_database` and `install_packages`, and then *source*
[generic.sh][] to let it do the job.

I have mixed feelings about the possibly stray [wrapexec.sh][] script
that has been left in the directory. On the one hand, it's been there
for a while and it *might* have been used. On the other hand, there is
less chance that this actually happened than, say, I'll start getting
younger by the day. You never know 😅

I hope this has been an effective refresher... *future me* 🙄

[dibspack-basic]: https://github.com/polettix/dibspack-basic
[dibs]: http://blog.polettix.it/hi-from-dibs/
[OpenSUSE]: https://www.opensuse.org/
[zypper]: https://software.opensuse.org/package/zypper
[generic.sh]: https://github.com/polettix/dibspack-basic/blob/bbad0792342d02b2769bf4e8244837c9bb0a7906/package/generic.sh
[wrapexec.sh]: https://github.com/polettix/dibspack-basic/blob/bbad0792342d02b2769bf4e8244837c9bb0a7906/package/wrapexec.sh
