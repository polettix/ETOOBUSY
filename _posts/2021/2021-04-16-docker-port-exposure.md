---
title: Docker port exposure
type: post
tags: [ docker ]
comment: true
date: 2021-04-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Host shoots first, just like Han.

*Presto!* What is the port in the host that is mapped onto the port in
the container?

```
docker run -p 12345:54321 ...
```

Yep, port `12345` in the *host* is mapped onto port `54321` in the
*container*. You have just been awarded a... *Bravo!*

Fact is that I *keep* forgetting it. I hope to remember it better with
**Host shoots first**, [just like Han][hsf].

On a more serious note, I found a very interesting article: [A Brief
Primer on Docker Networking Rules: EXPOSE, -p, -P, --link][primer],
which I strongly recommend.

Among the rest, it provides this nugget:

> The `-p` flag can take a few different formats:
>
>     ip:hostPort:containerPort  | ip::containerPort \
>       | hostPort:containerPort | containerPort

So it turns out I've always been using the *third* form and never knew
about it!

[primer]: https://www.ctl.io/developers/blog/post/docker-networking-rules/
[hsf]: https://en.wikipedia.org/wiki/Han_shot_first
