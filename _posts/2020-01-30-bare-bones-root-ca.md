---
title: Bare-bones Root CA
type: post
tags: [ security ]
comment: true
date: 2020-01-30 07:06:48 +0100
preview: true
---

**TL;DR**

> Sometimes you want to test SSL/TLS on a server and you want to experiment
> a bit before getting the real stuff. In these cases, having a private
> Certification Authority (CA) can become handy to uncover errors early.

The script below aims at easing this task.

<script src="https://gitlab.com/polettix/notechs/snippets/1934697.js"></script>

Also found [locally][].

Easy to use, just 1 setup command and then only signing and certificate
creation.

Setup:

```shell
./root-ca.sh create
```

This will generate files `ca.key` (private key for the CA) and `ca.crt`
(certificate, with the public key inside). Keep `ca.key`, distribute
`ca.crt` to clients and make them *trust* it.

Certificates signing/generation:

```shell
# some-server.csr comes from a need to generate a certificate
./root-ca.sh sign some-server.csr
```

If you need to generate a server certificate on the fly, `openssl` can be
your friend again:

```shell
openssl req -new -out server.csr -days 3650 \
   -subj '/CN=server.example.com/C=IT/ST=Roma/L=Roma/O=What/OU=Ever' \
   -newkey rsa:2048 -nodes -keyout server.key
```

Cheers!

[local-carton]: {{ '/assets/code/root-ca.sh' | prepend: site.baseurl | prepend: site.url }}
