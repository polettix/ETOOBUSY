---
title: Issue for RRDTool in Alpine Linux
type: post
tags: [ rrdtool, linux, Alpine ]
comment: true
date: 2022-01-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> There can be issues with [the RRDTool package][] for [Alpine Linux][].

While reporting [Issue 1145][] for [RRDTool][], I found out that I was
not using the latest-and-greatest version. What if this was a solved
problem?

"No worries!" said my *gullible* personality. "Surely we can use [Alpine
Linux][] to quickly figure that out!".

> Yes, after talking about hearing voices from the back of my head, now
> I'm talking about multiple personalities. 2021 is the year of coming
> out.

So I turned to [Docker][] to do a quick test:

```
host$ docker pull alpine:edge
host$ docker run --rm -itv "$PWD:/mnt" alpine:edge /bin/sh -l

container$ apk update
container$ apk add rrdtool
container$ sh rrd-graph.sh
```

The actual contents of shell program `rrd-graph.sh` are not important
here... it's just a command to generate a picture.

A horrible picture, actually:

![messy picture]({{ '/assets/images/rrdtool-alpine-fontissue.png' | prepend: site.baseurl }})

In case you're wondering, my *let's lose some time and sleep*
personality won the fight for trying to find out how many [Alpine
Linux][] releases had this problem. Well... *a lot*, and in particular
all that contain version 1.7.2 of [RRDTool][], which was basically what
I was after.

It seems that the basic font "Sony fixed" is somehow ignored.

The simplest solution that I found was to turn to another font, namely
[terminus-font][]:

```
container$ apk add terminus-font
container$ sh rrd-graph.sh
```

And now...

![correct picture]({{ '/assets/images/rrdtool-alpine-terminus-font.png' | prepend: site.baseurl }})

Yay!

Well... enough for today, see you soon folks!

[the RRDTool package]: https://pkgs.alpinelinux.org/packages?name=rrdtool&branch=edge
[Alpine Linux]: https://www.alpinelinux.org/
[RRDTool]: https://oss.oetiker.ch/rrdtool/index.en.html
[Issue 1145]: https://github.com/oetiker/rrdtool-1.x/issues/1145
[Docker]: https://www.docker.com/
[terminus-font]: https://pkgs.alpinelinux.org/packages?name=terminus-font&branch=edge
