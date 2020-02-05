---
title: Intermediate CAs are hard!
type: post
tags: [ security, openssl ]
comment: true
date: 2020-02-01 07:56:04 +0100
published: true
---

**TL;DR**

> If signing a certificate for a server with "your" *Root Certification
> Authority* is quite easy (as shown in [Bare-bones Root CA][]), moving onto
> a more sophisticated setup with an *Intermediate Certification Authority*
> is definitely tricky.

In a real-world scenario, you will rarely have your certificate signed by a
*Root CA*; more likely, the Root CA will have signed and *Intermediate CA*'s
certificate some time ago, then this latter CA will sign your server (or
client!) certificate. So, if you want to reproduce this (e.g. for testing
purposes), the trick in [Bare-bones Root CA][] has to be extended.

## It can't be that hard... or can it?

Let's just try to start simple:

- generate the Root CA key/certificate just like before
- generate the Intermediate CA key and certificate request, then have the
  Root CA generate the Intermediate CA certificate from it;
- generate the Server key and certificate request, then have the
  Intermediate CA generate the Server certificate from it.

The Root CA bit is the same as before, we will just make it clear that we're
dealing with it by prefixing an `r`:

```shell
openssl req -new -x509 -out rca.crt -days 3650 \
   -subj '/CN=root-ca.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Root' \
   -newkey rsa:2048 -nodes -keyout rca.key
```

Now the Intermediate CA, *without* the `-x509` option that would otherwise
generate a self-signed certificate, and with a different prefix `i`:

```shell
openssl req -new -out ica.csr -days 3650 \
   -subj '/CN=intermediate-ca.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Interm' \
   -newkey rsa:2048 -nodes -keyout ica.key
openssl x509 -req -in ica.csr  -out ica.crt \
   -CA rca.crt -CAkey rca.key -CAcreateserial
```

So far, so good. Now on with the server certificate:

```shell
openssl req -new -out srv.csr -days 3650 \
   -subj '/CN=srv.example.org/C=IT/ST=Roma/L=Roma/O=What/OU=Interm' \
   -newkey rsa:2048 -nodes -keyout srv.key
openssl x509 -req -in srv.csr  -out srv.crt \
   -CA ica.crt -CAkey ica.key -CAcreateserial
```

Note that we used `ica.crt`/`ica.key` this time, so that we have the
following signature chain:

```text
Root ==signed==> Intermediate ==signed==> Server
```

At this point we have three certificate/key pairs: the Root CA, the
Intermediate CA, and the Server.

## Let's try!

To give it a try, we leverage our [Bare-bones Web Server][], with proper
configuration.

There are two things to keep in mind:

- the Root CA certificate MUST be provided to the client as *trusted*,
  otherwise it will complain about not being able to verify the whole chain;
- the Intermediate CA certificate MUST be concatenated to the Server
  certificate, because it is the *bridge* between the Root CA certificate
  (that the client *trusts* because of the previous bullet) and the Server
  certificate.

Let's start with the server side, do the concatenation first:

```shell
cat srv.crt ica.crt > srv-ica.chain.crt
```

and then use this certificates bundle to start our sample server:

```shell
perl -I local/lib/perl5 sample-server.pl daemon \
   -l 'https://*:3000?cert=./srv-ica.chain.crt&key=./srv.key'
```

On to the client:

```shell
$ curl https://localhost:3000/
curl: (60) SSL certificate problem: unable to get local issuer certificate
...
```

D'ho! After repeating it multiple times, I forgot to set the Root CA
certificate in the client. It's pretty easy with [curl][], let's try again:

```shell
$ curl --cacert rca.crt https://localhost:3000/
curl: (60) SSL certificate problem: invalid CA certificate
...
```

Well... *Houston we have a problem*. There's something fishy with one of the
certificates (there are three of them in this chain), the title of this post
somehow gives out which and we have to find out what... stay tuned!!!


[Bare-bones Root CA]: {{ '/2020/01/30/bare-bones-root-ca' | prepend: site.baseurl | prepend: site.url }}
[Bare-bones Web Server]: {{ '/2020/01/31/bare-bones-web-server' | prepend: site.baseurl | prepend: site.url }}
[curl]: https://curl.haxx.se/
