---
title: transfer.sh
type: post
tags: [ web, terminal ]
comment: true
date: 2023-03-26 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [transfer.sh][] can come helpful from time to time.

In my quest for discovering and collecting useful pieces around the internet
(I also stealed a title for one previous post, i.e. [Software Tools for
Hobby-Scale Projects][post]), much like the Wall-E robot, I stumbled on
[transfer.sh][], which provides (in its own word):

> Easy file sharing from the command line

The interface is as simple as it can get: upload a file, get a link to it
back. The link will be up for `336h0m0s`, which according to my calculations
should be 14 days. Two weeks. Just one day below a fortnight.

Simplicity does not come at the expense of doing the right thing. In a few
tests, when I uploaded a text file with a smiley inside I got this back when
downloading the file:

```
content-type: text/plain; charset=utf-8
```

while I got this doing the round-trip with a PNG image:

```
content-type: image/png
```

I don't know about other esoteric file formats, but it seems to behave well
with the basic ones anyway.

I also like the touch that it allows setting the file name, which helps in
all those occasions where the downloader expects to "see" a specific
filename or filename extension. The interface deviates a little from the
pure REST, in that the file name is used as a *container* while uploading,
only to get it at the end of the URL while downloading. A nice twist and one
occasion to say that there's the rule and the exception to the rule.

It seems perfect for the kind of one-shot transfers that can arise from time
to time, with the benefit of doing its own housekeeping for anything that
does not need to stay up for too long.

The first use case that came to mind is as a backend for an application that
generates something (like a happy birthday card, ...) for you to download
and keep around if you just happened to delete the file after downloading
it, but will be ok re-generating in a few days.

Stay safe!


[transfer.sh]: https://transfer.sh
[post]: {{ '/2022/10/31/hobby-scale-projects/' | prepend: site.baseurl }}
