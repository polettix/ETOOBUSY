---
title: Intermediate CA Investigation
type: post
tags: [ security, openssl ]
comment: true
date: 2020-02-05 22:48:20 +0100
published: true
---

**TL;DR**

> We left [Intermediate CAs are hard!][] with a mystery, and we're
> determined to understand what's going on!

We left with this:

```shell
$ curl --cacert rca.crt https://localhost:3000/
curl: (60) SSL certificate problem: invalid CA certificate
...
```

The hint is pretty clear: the CA certificate is invalid! Our suspect is the
*Intermediate CA* certificate, simply because we had no problem with the
*Root CA* certificate before.

Let's take a closer look:

```shell
$ openssl x509 -text -noout -in ica.crt
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number:
            ed:b9:f0:28:23:17:70:8d
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=root-ca.example.org, C=IT, ST=Roma, L=Roma, O=What, OU=Root
        Validity
            Not Before: Feb  5 21:50:23 2020 GMT
            Not After : Mar  6 21:50:23 2020 GMT
        Subject: CN=intermediate-ca.example.org, C=IT, ST=Roma, L=Roma, O=What, OU=Interm
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    ...
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         ...
```

In my deep ignorance... I see nothing wrong! This is another hint though...
what should I expect? Let's take a look at the *Root CA* certificate
instead:

```shell
$ openssl x509 -text -noout -in rca.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            c2:f0:f9:31:43:b4:46:16
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=root-ca.example.org, C=IT, ST=Roma, L=Roma, O=What, OU=Root
        Validity
            Not Before: Feb  5 21:50:23 2020 GMT
            Not After : Feb  2 21:50:23 2030 GMT
        Subject: CN=root-ca.example.org, C=IT, ST=Roma, L=Roma, O=What, OU=Root
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    ...
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                EF:10:12:70:B2:91:37:64:F7:9F:D6:6A:AF:74:BE:EC:55:14:3D:1B
            X509v3 Authority Key Identifier: 
                keyid:EF:10:12:70:B2:91:37:64:F7:9F:D6:6A:AF:74:BE:EC:55:14:3D:1B

            X509v3 Basic Constraints: 
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
         ...
```

This section is particularly interesting:

```text
Certificate:
    ...
    Signature Algorithm: sha256WithRSAEncryption
        ...
        X509v3 extensions:
            ...
            X509v3 Basic Constraints: 
                CA:TRUE
```

So *it seems* that CAs should have the x509v3 extension that marks them
as... CAs to be considered valid by the client.

It turns out that the story is a bit more complicated than this: at least
for `curl`, self-signed certificates (like the Root CA certificate) are also
considered valid for signing other certificates, independently of the
`CA:TRUE` presence or not. In the case of the Intermediate CA certificate
this does not apply any more, so we have to explicitly mark it as `CA:TRUE`
or we will get the error message.

Now we have found the culprit... we will shortly find a solution, stay
tuned!

*Want to know more? Read on to [Intermediate CA Solution][] 😎*

[Intermediate CAs are hard!]: {{ '/2020/02/01/intermediate-cas-are-hard' | prepend: site.baseurl | prepend: site.url }}
[Intermediate CA Solution]: {{ '/2020/02/07/intermediate-ca-solution' | prepend: site.baseurl | prepend: site.url }}
