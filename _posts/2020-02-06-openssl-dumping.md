---
title: Easy dumping of OpenSSL "stuff"
type: post
tags: [ openssl, shell ]
comment: true
date: 2020-02-06 19:53:21 +0100
published: true
---

**TL;DR**

> I was tired of always typing the same stuff with `openssl ...` and here's
> a small simplification.

When working with certificates in [OpenSSL][], I keep writing this over and over:

```shell
openssl x509 -text -noout -in whatevah.crt
```

Sometimes it's a certificate request instead, which takes pretty much the same parameters but has a different subcommand:

```shell
openssl req -text -noout -in whatevah.csr
```

So why don't make the shell do what it does best?

<script src="https://gitlab.com/polettix/notechs/snippets/1937110.js"></script>

[Local version here][]

[OpenSSL]: https://www.openssl.org/
[Local version here]: {{ '/assets/code/ssldump' | prepend: site.baseurl | prepend: site.url }}
