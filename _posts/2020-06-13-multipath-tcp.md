---
title: Multipath TCP - reminder to study
type: post
tags: [ networking, mptcp ]
comment: true
date: 2020-06-13 18:21:47 +0200
mathjax: false
published: true
---

**TL;DR**

> Multipath TCP is something I should understand better.

This is kind of a reminder blog post to poke me and study [Multipath
TCP][] better, and possibly write it here. Hence, I expect this blog
post to be supplemented (hopefully) by other posts.

The gist I got so far is that the implementation aims as being
transparent for TCP-based applications. To this regard, I'm curious
whether this is *really* the case - i.e. for example what if an
application gets its data parameters about the socket to communicate
them to some peer around (like it would be the case for FTP).

In addition to the [Wikipedia page][Multipath TCP], one good
"theoretical" starting point will hopefully be [RFC 6824][], but for my
doubt I think that I'll need to set up some experimentation.


[Multipath TCP]: https://en.wikipedia.org/wiki/Multipath_TCP
[RFC 6824]: https://tools.ietf.org/html/rfc6824
