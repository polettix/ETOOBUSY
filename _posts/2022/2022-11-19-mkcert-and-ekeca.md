---
title: 'TLS for devs: mkcert and ekeca'
type: post
tags: [ security, ssl, openssl, shell ]
comment: true
date: 2022-11-19 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Thoughts about [mkcert][] and [ekeca][].

A [recent tweet][tweet] brought [mkcert][] to my attention:

> [mkcert][] is a simple tool for making locally-trusted development
> certificates. It requires no configuration.

It's one of those times where *from great power comes great
responsibility*. To be honest, even knowing about it does not make me
truly confident, because I use the browser so much that it triggers my
FUD.

There's nothing wrong with [mkcert][] *per-se*, I just don't like the
idea of leaving around keys for a CA my browser trusts.

It's probably *irrational* - there are much worse things that can
backfire in my system, right? On the other hand, it's probably
*rational* to default to something that is not going to harm us by
default - much like we keep scissors and knives in a safe place, instead
of lying around.

For this kind of use cases --generate a locally accepted certificate
overriding the *real* certificate out on the web-- I recently turned to
a different one-shot solution based on [ekeca][]:

<script id="asciicast-536315" src="https://asciinema.org/a/536315.js" async></script>


Full transcript:

```shell
# let's work in a sub directory
mkdir example
cd example

# create the Root CA and the Intermediate CA
ekeca boot
ls -l

# generate the server certificates, including a wildcard as SAN
ekeca server_create example.com '*.example.com'
ls -l

# collect relevant pieces
mv rca/certificate.pem root-for-clients.crt
mv example.com/key.pem server.key
mv example.com/certificates-chain.pem server.crt

# remove the rest
rm -rf rca ica example.com

# this is what we should use around
ls -l
```

The idea is to generate a new Root CA and an Intermediate CA (to
"simulate the real world") just for the specific certificate and then
throw everything away except the strict necessary. This includes
deleting the private keys for the Root CA and the Intermediate CA.

The artifacts that are preserved are:

- `root-for-clients.crt` is the Root CA certificate that should be
  installed into the clients (browser(s), curl, ...). This will let them
  accept our server certificate.
- `server.key` is the server's private key, to be installed in the
  server.
- `server.crt` is the *certificates chain* including both the server's
  proper certificate *and* the Intermediate CA's certificate (it's easy
  to separate the two if needed).

There's no automation for installing the Root CA certificate because...
well, I'm still not at the point that this is something I feel [needs][]
[automation][].

Stay safe!

[tweet]: https://twitter.com/apag/status/1586410738733678594?s=20&t=HgK7ZHge0rV6SlzV01CN0A
[mkcert]: https://github.com/FiloSottile/mkcert
[ekeca]: {{ '/2020/02/08/ekeca/' | prepend: site.baseurl }}
[automation]: https://xkcd.com/1319/
[needs]: https://xkcd.com/1205/
