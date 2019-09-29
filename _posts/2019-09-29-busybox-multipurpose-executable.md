---
title: Busybox - multipurpose executable
type: post
tags: [ linux, toolbox ]
comment: true
date: 2019-09-29 18:30:27 +0200
---

[Busybox] is a multi-purpose binary, i.e. a single binary that is
capable of doing *a lot* of things. This is the description that can be
found in the website:

> BusyBox combines tiny versions of many common UNIX utilities into a
> single small executable. It provides replacements for most of the
> utilities you usually find in GNU fileutils, shellutils, etc. The
> utilities in BusyBox generally have fewer options than their
> full-featured GNU cousins; however, the options that are included
> provide the expected functionality and behave very much like their GNU
> counterparts. BusyBox provides a fairly complete environment for any
> small or embedded system.

As of this writing, it is capable of providing most functionalities of
at least the following programs:

{% highlight text %}
Currently defined functions:
    [, [[, acpid, adjtimex, ar, arch, arp, arping, ash, awk,
    basename, bc, blkdiscard, blockdev, brctl, bunzip2, busybox,
    bzcat, bzip2, cal, cat, chgrp, chmod, chown, chroot, chvt, clear,
    cmp, cp, cpio, crond, crontab, cttyhack, cut, date, dc, dd,
    deallocvt, depmod, devmem, df, diff, dirname, dmesg,
    dnsdomainname, dos2unix, dpkg, dpkg-deb, du, dumpkmap,
    dumpleases, echo, ed, egrep, env, expand, expr, factor,
    fallocate, false, fatattr, fdisk, fgrep, find, fold, free,
    freeramdisk, fsfreeze, fstrim, ftpget, ftpput, getopt, getty,
    grep, groups, gunzip, gzip, halt, head, hexdump, hostid,
    hostname, httpd, hwclock, i2cdetect, i2cdump, i2cget, i2cset, id,
    ifconfig, ifdown, ifup, init, insmod, ionice, ip, ipcalc,
    ipneigh, kill, killall, klogd, last, less, link, linux32,
    linux64, linuxrc, ln, loadfont, loadkmap, logger, login, logname,
    logread, losetup, ls, lsmod, lsscsi, lzcat, lzma, lzop, md5sum,
    mdev, microcom, mkdir, mkdosfs, mke2fs, mkfifo, mknod, mkpasswd,
    mkswap, mktemp, modinfo, modprobe, more, mount, mt, mv, nameif,
    nc, netstat, nl, nologin, nproc, nsenter, nslookup, nuke, od,
    openvt, partprobe, passwd, paste, patch, pidof, ping, ping6,
    pivot_root, poweroff, printf, ps, pwd, rdate, readlink, realpath,
    reboot, renice, reset, resume, rev, rm, rmdir, rmmod, route, rpm,
    rpm2cpio, run-init, run-parts, sed, seq, setkeycodes, setpriv,
    setsid, sh, sha1sum, sha256sum, sha512sum, shred, shuf, sleep,
    sort, ssl_client, start-stop-daemon, stat, strings, stty, su,
    sulogin, svc, svok, swapoff, swapon, switch_root, sync, sysctl,
    syslogd, tac, tail, tar, taskset, tc, tee, telnet, telnetd, test,
    tftp, time, timeout, top, touch, tr, traceroute, traceroute6,
    true, truncate, tty, tunctl, ubirename, udhcpc, udhcpd, uevent,
    umount, uname, uncompress, unexpand, uniq, unix2dos, unlink,
    unlzma, unshare, unxz, unzip, uptime, usleep, uudecode, uuencode,
    vconfig, vi, w, watch, watchdog, wc, wget, which, who, whoami,
    xargs, xxd, xz, xzcat, yes, zcat
{% endhighlight %}

which probably makes it *the* item you want in a [#toolbox][].

## Using `busybox`

There are several ways to invoke the tools that are contained in
[Busybox][]. The most basic one is to provide the command and its
parameters as comand-line parameters to `busybox` itself, e.g. the
following example does what you would expect:

{% highlight text %}
$ busybox grep -i whatever *.txt
{% endhighlight %}

If you plan on using the tools interactively many times, typing
`busybox` over and over can be annoying, so you have two options. The
least invasive is to enter the shell provided by `busybox`, which is no
[bash][] but it's honest.  From there, all tools are just available by
magic:

{% highlight text %}
host-shell$ busybox sh
busybox-shell$ grep -i whatever *.txt | nl
{% endhighlight %}

If you don't like [Busybox][]'s shell (e.g. because you have a different
one, or want to invoke commands from somewhere else) then it's possible
to *install* the sub-commands as symbolic links to the `busybox`
executable itself. In fact, when it's run with a different name,
`busybox` *becomes* the program with that name. If this is your way,
option `--install` will be helpful.

## Why `busybox` In The [#toolbox][]?

You might wonder why you would ever want to include [Busybox][] in your
[#toolbox][], provided that it includes pretty basic tools.

One consideration is that some of those tools are slightly above *basic*
and might lack in a typical Linux installation. Two notable examples are
[ncat][] (as `nc`) and [xxd][], the former useful to set up quick TCP
connections towards a destination (and check if it's alive, how it
works, etc.), the former to get a better idea of the contents of a
(binary) file.

The shell itself, along with the "usual" Linux tooling, can come very
handy anyway. As an example, you might run into a very stripped down
[Docker][] image where there is a single "business logic" executable
only, and all tools are lacking; in this case, injecting [Busybox][] in
the container's filesystem is an invaluable help for troubleshooting.


[Busybox]: https://busybox.net/
[#toolbox]: {{ '/tagged/#toolbox' | prepend: site.baseurl | prepend: site.url }}
[ncat]: https://nmap.org/ncat/
[xxd]: https://github.com/vim/vim/blob/master/src/xxd/xxd.c
[Docker]: https://www.docker.com/
[bash]: https://www.gnu.org/software/bash/
