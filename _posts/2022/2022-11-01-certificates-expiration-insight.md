---
title: An insight about Certificates expirations
type: post
tags: [ security, web ]
comment: true
date: 2022-11-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> An insight about shortening the validity time for certificates.

In recent post [Certificates expiration][] I left with a doubt:

> \[Shortening certificates validity times\] seems to be somehow at odds
> with the recent trends that suggest to not change one’s password
> unless there are real reasons to do so. I understand that these are
> two different things, but I fail to grasp the reasons why the
> differences matter with respect to the validity time.

I'm glad I wrote down my doubt, because a gentle reader (Stefano
Tirabassi) shared their thoughts with me. I'll attempt a translation in
English, hoping not to lose too much:

> I guess that the validity time is related to how it can be
> expired otherwise. CRLs (Certificate Revocation Lists) were designed
> to this regard initially, so making a certificate invalid (for
> whatever reason) was as easy as putting it into the list of "bad
> certificates"... In practice, no one cares about these lists!
>
> Nowadays, renewing certificates is quick (and automatic), so it makes
> sense to stick to shorter validity times...

This is where it clicked for me. I mean, the underlying difference that
makes all the difference.

Changing a password just requires... doing it. You change the password
and, from that point on, the old one is gone for good. Well, unless
there's some caching somewhere, but I'm digressing.

On the other hand, changing a certificate can be much more troublesome.
Getting a new certificate for a domain does not *automatically* makes
the old one invalid. *It should*, but there's ample space for missing
it. As a consequence, somebody stealing a certificate (and its private
key, of course) might still be able to use it to trick people that do
not use CRLs.

As a consequence, it's just common sense to set a *security valve* and
restrict this time window in a sensible way. Which also made me think
that I already had [some hints since 2015][le2015]:

> \[short certificate lifetimes\] limit damage from key compromise and
> mis-issuance. Stolen keys and mis-issued certificates are valid for a
> shorter period of time.

Admittedly, the key insight was somehow *left as an exercise for the
reader*. Thanks Stefano for putting me on the right track!

[Certificates expiration]: {{ '/2022/10/29/certificates-expiration/' | prepend: site.baseurl }}
[le2015]: https://letsencrypt.org/2015/11/09/why-90-days.html
