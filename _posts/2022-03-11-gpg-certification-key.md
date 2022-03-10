---
title: GPG Certification Key
type: post
tags: [ gpg, openpgp, security ]
comment: true
date: 2022-03-11 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> TIL about Key Certification in [OpenPGP][].

So... it was probably clear to most, but I just figured that in
[OpenPGP][] only the main "root" key can be used to sign other keys. In
other terms, *subkeys* can not be used for this.

This is made clear in [section 12.1][]:

> In a V4 key, the primary key MUST be a key capable of certification.
> The subkeys may be keys of any other type. [...]

This also means that in a "split" setup where the master "main" private
key is kept secret somewhere offline, and only subkeys are used around,
signing received public keys must be done... offline, where the master
key with the `C` (key certification) capability enabled.

Stay safe and... certified!

[Perl]: https://www.perl.org/
[OpenPGP]: https://datatracker.ietf.org/doc/html/rfc4880
[section 12.1]: https://datatracker.ietf.org/doc/html/rfc4880#section-12.1
