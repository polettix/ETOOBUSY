---
title: HMAC in Perl
type: post
tags: [ security, perl ]
comment: true
date: 2020-08-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> If you need to compute [HMAC][]s, [Perl][] gets you covered.

In previous post [HMAC][hmac-post] we took a brief look at [HMAC][]s:

> In cryptography, an HMAC (sometimes expanded as either keyed-hash
> message authentication code or hash-based message authentication code)
> is a specific type of message authentication code (MAC) involving a
> cryptographic hash function and a secret cryptographic key. As with
> any MAC, it may be used to simultaneously verify both the data
> integrity and the authenticity of a message. 

So, from a practical point of view... how to compute them? With
[Perl][]?!?

Module [Digest::SHA][] has everything you need to get started. In
particular, all functions whose name starts with `hmac_` are coded
exactly with this goal in mind. From the applicable synopsis:

```perl
use Digest::SHA qw(hmac_sha1 hmac_sha1_hex ...);
 
$digest = hmac_sha1($data, $key);
$digest = hmac_sha224_hex($data, $key);
$digest = hmac_sha256_base64($data, $key);
```

No excuses for not using [HMAC][] when needed, or reinvent any wheel!

[hmac-post]: {{ '/2020/08/20/hmac' | prepend: site.baseurl }}
[HMAC]: https://en.wikipedia.org/wiki/HMAC
[Perl]: https://www.perl.org/
[Digest::SHA]: https://metacpan.org/pod/Digest::SHA
