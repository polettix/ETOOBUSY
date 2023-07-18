---
title: Name Constraints
type: post
tags: [ tls, security ]
comment: true
date: 2023-07-18 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I discovered about [Name Constraints][].

It seems to be able to create a root certification authority that is
constrained to only emit certificates for a restricted (although still
possibly unbounded) set of *things*.

It comes with some caveats, the first and foremost being that it's been a
kind of an afterthought and clients might not have implemented that widely.
At least according to some help posts from about *ten years ago*.

So I guess it's fair to use it in a small and largely controlled environment
where clients are updated and more than this they can be tested. Still, it
makes me uneasy to install a root CA certificate.

It [can be set via OpenSSL][ossl], like this in an extensions part:

```
[ req]
x509_extensions = ca_extensions
...

[ ca_extensions ]
nameConstraints = permitted;DNS:*.example.com
...
```

It can be set in *permit* or in *exclude* mode. I like the first better
because it works like an allow list, where everything is denied and only few
selected things pass.

Stuff for studying!


[Name Constraints]: https://www.rfc-editor.org/rfc/rfc5280#section-4.2.1.10
[ossl]: https://www.openssl.org/docs/man1.0.2/man5/x509v3_config.html
