---
title: Project Gutenberg in Italy
type: post
tags: [ gutenberg, copyright, madness ]
comment: true
date: 2023-01-31 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Project Gutenberg][] is blocked in Italy.

Let's take a look:

```
# via Google DNS
$ dig gutenberg.org +noall +answer @8.8.8.8
gutenberg.org.		20851	IN	A	152.19.134.47 

$ dig www.gutenberg.org +noall +answer @8.8.8.8
www.gutenberg.org.	21530	IN	CNAME	gutenberg.org.
gutenberg.org.		21530	IN	A	152.19.134.47


# via an Italian ISP's DNS
$ dig gutenberg.org +noall +answer @"$ITAISP"
gutenberg.org.		900	IN	A	XX.XXX.XX.XX
$ dig www.gutenberg.org +noall +answer @"$ITAISP" | wc -l
0
```

Needless to say, the address provided back from the Italian ISP DNS is a
black hole:

```
$ nc -w 5 XX.XXX.XX.XX 443
(UNKNOWN) [XX.XXX.XX.XX] 443 (https) : Connection timed out
```

So why is this? From [what I got online][], in May 2020 a judge deemed
the site to be at the same level as many sites with pirated material.
Sure, copyright laws in Italy are different from those in the US, but
*at least taking a look, folks?!?*

The hilariously sad thing is that the only thing needed to go around
this "block" is... changing DNS. Yup, if one puts a different global DNS
instead of the one provided by the ISP, they can go there again. So...
not only that was a sloppy decision based on *not giving a f\*ck* about
weighting the pros and cons, but even the execution was sloppy.

This is so depressing.


[Project Gutenberg]: https://gutenberg.org/
[what I got online]: https://www.wired.it/internet/web/2020/06/30/progetto-gutenberg-sequestro/
