---
title: Timezone notes
type: post
tags: [ coding, shell, perl, timezone, dokku, docker, alpine ]
comment: true
date: 2020-06-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Setting that little timezone can be really upsetting!

Setting the timezone in my computer - including the Linux virtual
machine - is pretty much straightforward. Is it equally easy... in the
containers?

# Dokku

[Dokku][] relies on [herokuish][], which is ultimately based on Ubuntu:

```shell
herokuishuser@ebe0a6ba7bee:~$ cat /etc/os-release | grep PRETTY_NAME
PRETTY_NAME="Ubuntu 18.04.4 LTS"
```

So... no big deal (let's get rid of the prompt on the way...):

```shell
$ [ -n "${TZ+x}" ] || printf 'TZ is unset\n'
TZ is unset
$ date
Mon Jun  1 14:46:45 UTC 2020
$ perl -E 'say scalar localtime'
Mon Jun  1 14:46:58 2020
```

Variable `TZ` to the rescue:

```shell
$ TZ=Europe/Rome date
Mon Jun  1 16:47:53 CEST 2020
$ TZ=Europe/Rome perl -E 'say scalar localtime'
Mon Jun  1 16:48:13 2020
```

This is interesting, because we can control it directly inside the
process (should we need it):

```shell
$ perl -E '$ENV{TZ} = "Europe/Rome"; say scalar localtime'
Mon Jun  1 16:48:36 2020
```

# Beware the Docker Alpine!

It turns out that [Alpine Linux][] in a [Docker][] image (i.e. [this
image][]) is *really* tiny. So tiny that, by default, it does not
support what we saw for [herokuish][]:

```shell
$ date
Mon Jun  1 17:15:18 UTC 2020
$ TZ='Europe/Rome' date
Mon Jun  1 17:15:30 UTC 2020
```

This is easily addressed though, just install the `tzdata` package:

```shell
$ apk add --no-cache tzdata
fetch http://dl-cdn.alpinelinux.org/alpine/v3.8/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.8/community/x86_64/APKINDEX.tar.gz
(1/1) Installing tzdata (2020a-r0)
Executing busybox-1.28.4-r2.trigger
OK: 8 MiB in 14 packages
$ date
Mon Jun  1 15:21:50 UTC 2020
$ TZ=Europe/Rome date
Mon Jun  1 17:21:59 CEST 2020
```

And I guess this is it!


[Dokku]: http://dokku.viewdocs.io/dokku/
[herokuish]: https://github.com/gliderlabs/herokuish
[Docker]: https://www.docker.com/
[Alpine Linux]: https://www.alpinelinux.org/
[this image]: https://hub.docker.com/_/alpine
