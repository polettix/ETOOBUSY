---
title: Certificates expiration
type: post
tags: [ security, web ]
comment: true
date: 2022-10-29 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Certificates should expire within about 13 months.

Some time ago I was helping a colleague set up a fake certificate for a
development environment. He just thought it better to have the
certificate last for a very long time and forget about it (keeping the
*real* certificate up to date is somebody else's job).

So he eventually settled for 10 years and it *seemed* to be working.

Except that then another colleague needed to access the same development
environment and was getting this error from Chrome:

```
NET::ERR_CERT_VALIDITY_TOO_LONG
```

At first (non-)sight it seemed we had messed up with making the
certificate accepted, but then of course we *actually read* the error
and figured that the complaint was not about the chain of trust but on
the validity period.

> Kudos to us for figuring this out, it's just **literally** written in
> the error and it was a hard fish to catch.

So, as of September 1, 2020, [Maximum Lifespan of SSL/TLS Certificates
is 398 Days][] from a practical point of view.

I'm kind of neutral to this type of decision, to be honest. This seems
to be *somehow* at odds with the recent trends that suggest to *not*
change one's password unless there are real reasons to do so. I
understand that these are two different things, but I fail to grasp the
reasons why the differences matter with respect to the validity time.

I'll try to think of a few:

- Violating a certificate is much more attractive than violating a
  single password, because of the reach. Making it a moving target
  *might* help to limit exposure windows.
- Changing a certificate usually involves generating a new key by the
  computer. As long as we trust the randomness source and the
  algorithms, each key should be as good as any other. On the other
  hand, humans might tend to settle for increasingly simpler passwords
  if they are requested to change them frequently

Any pointer to some elaboration would be much appreciated!

[Maximum Lifespan of SSL/TLS Certificates is 398 Days]: https://thehackernews.com/2020/09/ssl-tls-certificate-validity-398.html
