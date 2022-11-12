---
title: Bare-bones Root CA
type: post
tags: [ security, openssl ]
series: Playing with CAs
comment: true
date: 2020-01-30 07:06:48 +0100
published: true
---

**TL;DR**

> Sometimes you want to test SSL/TLS on a server and you want to experiment
> a bit before getting the real stuff. In these cases, having a private
> Certification Authority (CA) can become handy to uncover errors early.

The script below aims at easing this task.

<script src="https://gitlab.com/polettix/notechs/snippets/1934697.js"></script>

Also found [locally][].

Easy to use, just one setup command and then only signing and certificate
creation.

## Setup

```shell
./root-ca.sh create
```

This will generate files `ca.key` (private key for the CA) and `ca.crt`
(certificate, with the public key inside). Keep `ca.key`, distribute
`ca.crt` to clients and make them *trust* it.

## Certificates signing/generation

```shell
# some-server.csr comes from a need to generate a certificate
./root-ca.sh sign some-server.csr
```

Again, remember that your clients will need to trust `ca.crt`...

## Anything else

If you need to generate a server certificate on the fly, `openssl` can be
your friend again:

```shell
openssl req -new -out server.csr -days 3650 \
   -subj '/CN=server.example.com/C=IT/ST=Roma/L=Roma/O=What/OU=Ever' \
   -newkey rsa:2048 -nodes -keyout server.key
```

Cheers!

*Want to know more? [Intermediate CAs are hard!][] is a follow-up post on
this topic.* 😎

[locally]: {{ '/assets/code/root-ca.sh' | prepend: site.baseurl | prepend: site.url }}
[Intermediate CAs are hard!]: {{ '/2020/02/01/intermediate-cas-are-hard' | prepend: site.baseurl | prepend: site.url }}
