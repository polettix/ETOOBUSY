---
title: Intermediate CA Solution
type: post
tags: [ security, openssl ]
comment: true
date: 2020-02-07 22:13:25 +0100
published: true
---

**TL;DR**

> Tired of the long march to a valid *Intermediate CA*? We're at the end of
> our journey. In real TL;DR spirit, just look at [OpenSSL Certificate
> Authority][]. Or read on.

We learned that [Intermediate CAs are hard!][]. We figured out why with our
[Intermediate CA Investigation][]. Now it's time for solutions.

The big inspirer for whatever you find here is the website [OpenSSL
Certificate Authority][]. Big kudos, very clear.

## Use `openssl ca`, Luke!

The bottom line is that we need to fit those `x509v3` extensions *at least*
in the *Intermediate CA* certificate, and to do this we cannot just sign its
certificate request with `openssl x509`. At least, I didn't find a way to do
this.

We have to resort to another sub-command: `ca`. This time, anyway, we want
to take full control of calling it, i.e. we don't want to rely upon defaults
that may vary from distribution to distribution, or even [across different
versions of the same distribution][go-back]. It's time that we use
*configuration files*.

### Root CA

This is our minimal configuration file for the *Root CA*, aptly named
`rca.cnf`:

```text
[ ca ]
default_ca             = CA_default

[ CA_default ]
new_certs_dir          = .
database               = rca.x.database
serial                 = rca.x.serial
RANDFILE               = rca.x.RANDFILE
private_key            = rca.key
certificate            = rca.crt
default_md             = sha256
default_days           = 42
preserve               = no
policy                 = policy
copy_extensions        = copy

[ policy ]
countryName            = match
stateOrProvinceName    = match
organizationName       = match
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ req ]
default_bits           = 2048
prompt                 = no
distinguished_name     = distinguished_name
string_mask            = utf8only
default_md             = sha256
x509_extensions        = rca_extensions

[ distinguished_name ]
countryName            = IT
stateOrProvinceName    = RM
localityName           = Roma
organizationName       = Everish
organizationalUnitName = Root
commonName             = Everish Root CA

[ rca_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical,CA:true
keyUsage               = critical,digitalSignature,cRLSign,keyCertSign

[ ica_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical,CA:true,pathlen:0
keyUsage               = critical,digitalSignature,cRLSign,keyCertSign
```

A lot of the stuff is *mandatory* so it's there for this reason. E.g.
section `policy`, or a bunch of filename in `CA_default`.

Section `req` is read when issuing the `req` sub-command, which happens when
we generate the self-signed certificate for the *Root CA*:

```shell
openssl req -x509 -new -config rca.cnf -out rca.crt -days 42 \
   -newkey rsa:2048 -nodes -keyout rca.key
```

Note that we're setting `-config` to point to our file `rca.cnf`.

The `-x509` parameter instructs on using the `x509_extensions` which, in our
case, map onto section `rca_extensions` in the configuration file. This
turns on the flags for being a CA on the root certificate too, even though
we saw that at least `curl` does not seem to be picky about this. Better
play it safe and future proof, anyway.

The `ca` section is for the `ca` sub-command, as you might already have
guessed. This will be discussed a bit down on the road, tough. The same goes
for the `ica_extensions` section. Be patient!

### Intermediate CA

At the very last, we're there! We will first use the following `ica.cnf`
configuration file to generate a certificate request file:

```text
[ ca ]
default_ca             = CA_default

[ CA_default ]
new_certs_dir          = .
database               = ica.x.database
serial                 = ica.x.serial
RANDFILE               = ica.x.RANDFILE
private_key            = ica.key
certificate            = ica.crt
default_md             = sha256
default_days           = 42
preserve               = no
policy                 = policy
copy_extensions        = copy

[ policy ]
countryName            = supplied
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ req ]
default_bits           = 2048
prompt                 = no
distinguished_name     = distinguished_name
string_mask            = utf8only
default_md             = sha256

[ distinguished_name ]
countryName            = IT
stateOrProvinceName    = RM
localityName           = Roma
organizationName       = Everish
organizationalUnitName = Intermediate
commonName             = Everish Intermediate CA

[ srv_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:false
keyUsage               = critical,digitalSignature,keyEncipherment
```

The structure is similar to the `rca.cnf` file, only we have a bit less
configurations. Section `srv_extensions` will be used later together with
the `ca` sub-command and section.

Let's generate the certificate request then:

```shell
openssl req -new -config ica.cnf -out ica.csr -days 42 \
   -newkey rsa:2048 -nodes -keyout ica.key
```

This triggers the `req` section in the `ica.cnf` file, which sets the right
Common Name, etc. Time for signing from the *Root CA*:

```shell
openssl ca -batch -config rca.cnf -extensions ica_extensions -days 42 \
   -in ica.csr -out ica.crt
```

We are using the `ca` sub-command with `rca.cnf` here, because we are
putting the "hat" of the *Root CA* in this signing action. We are also using
explicitly the `ica_extensions` here, i.e. from the `rca.cnf` file:

```text
[ ica_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical,CA:true,pathlen:0
keyUsage               = critical,digitalSignature,cRLSign,keyCertSign
```

This means that the certificate is set as a `CA:true` one (alas!), but also
that it can *not* be used to create *further* CAs (due to `pathlen:0`). In
this way, the *Root CA* retains its capabilities, while only delegating the
*Intermediate CA* to sign client/server certificates.

This is the resulting certificate:

```text
Certificate:
    ...
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=IT, ST=RM, L=Roma, O=Everish, OU=Root, CN=Everish Root CA
        ...
        Subject: C=IT, ST=RM, O=Everish, OU=Intermediate, CN=Everish Intermediate CA
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                03:4E:37:FD:8C:84:E2:E3:64:42:EE:55:75:3A:D1:B1:5C:04:E4:B2
            X509v3 Authority Key Identifier: 
                keyid:DE:2A:AB:95:54:9F:A6:56:34:2B:13:B1:CE:9D:B1:30:CA:37:11:9B

            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
    ...
```

At the very last we have a *good* certificate for the Intermediate CA!

### Server Certificate?

Now that we have unlocked the power of configuration files for [OpenSSL][],
why stop here? We can use use one also for generating our certificate
request for the server using `srv.cnf`:

```text
[ req ]
default_bits           = 2048
prompt                 = no
distinguished_name     = distinguished_name
string_mask            = utf8only
default_md             = sha256

[ distinguished_name ]
countryName            = IT
stateOrProvinceName    = RM
localityName           = Roma
organizationName       = Everish
organizationalUnitName = Server
commonName             = srv.example.com

[ extensions ]
subjectAltName         = DNS:localhost,DNS:srv.example.com
```

While the stuff in `distinguished_name` might be put inside the command
line, the `extensions` section is interesting because it allows us to set
some extensions also in a server's (or client's) certificate.

Let's generate the request then:

```shell
openssl req -new -config srv.cnf -out srv.csr -days 42 \
   -reqexts extensions -newkey rsa:2048 -nodes -keyout srv.key
```

Did you take note of the `-reqexts` option set to `extensions`? Here we just
set the name of the corresponding section inside `srv.cnf` to make sure that
the `subjectAltName` finds its way inside the request:

```text
Certificate Request:
    Data:
        ...
        Subject: C=IT, ST=RM, L=Roma, O=Everish, OU=Server, CN=srv.example.com
        ...
        Requested Extensions:
            X509v3 Subject Alternative Name: 
                DNS:localhost, DNS:srv.example.com
    ...
```

This `subjectAltName` is a very handy option that allows us to mark the
certificate as valid for a variety of names, instead of the Common Name only
as it would be by default. And yes... we have to put the Common Name in the
list too.

Let's sign it with our *Intermediate CA*. Again, this time we use the more
powerful `ca` sub-command, leveraging the *Intermediate CA* configuration
file `ica.cnf` to do this (because we have to put on the *Intermediate CA*
hat when doing the signing):

```shell
openssl ca -batch -config ica.cnf -extensions srv_extensions -days 42 \
   -in srv.csr -out srv.crt
```

This time we are asking to take the `srv_extensions` section of `ica.cnf`,
i.e. the following:

```text
[ srv_extensions ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:false
keyUsage               = critical,digitalSignature,keyEncipherment
```

This will make sure that the certificate cannot sign other certificates
(i.e. it's a *leaf* in our tree of signatures). This isn't sufficient,
though: we also have to make sure that other extensions in the request (like
the `subjectAltName` we saw above) make their way into the generated
certificate, which is why we have this in `ica.cnf`:

```text
[ CA_default ]
...
copy_extensions        = copy
```

Let's take a look at the generated certificate then:

```text
Certificate:
    ...
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=IT, ST=RM, O=Everish, OU=Intermediate, CN=Everish Intermediate CA
        ...
        Subject: C=IT, ST=RM, O=Everish, OU=Server, CN=srv.example.com
        ...
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                D3:43:48:62:D1:E8:DB:2D:AF:44:C6:48:76:5C:AD:5A:F3:11:E4:B9
            X509v3 Authority Key Identifier: 
                keyid:21:45:8F:0B:7C:6B:12:17:43:EA:02:B8:B2:2A:0C:28:3B:BB:C8:0E

            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:localhost, DNS:srv.example.com
    ...
```

How amazing! Both extensions from the certificate request (`X509v3 Subject
Alternative Name`) and from the *Intermediate CA* (basically, all the other
ones) are included.


## Give it a try!

If you want to try this in action, use version 1.2 (or later) of the
[polettix/certificate-example][dimage] image, which now includes a
`right-intermediate` sub-directory! This should get you started, hopefully:

<script id="asciicast-299094" src="https://asciinema.org/a/299094.js" async></script>

Happy learning!


[OpenSSL Certificate Authority]: https://jamielinux.com/docs/openssl-certificate-authority/index.html
[Intermediate CAs are hard!]: {{ '/2020/02/01/intermediate-cas-are-hard' | prepend: site.baseurl | prepend: site.url }}
[Intermediate CA Investigation]: {{ '/2020/02/05/intermediate-ca-investigation' | prepend: site.baseurl | prepend: site.url }}
[go-back]: {{ '/2020/02/04/going-back-on-alpine' | prepend: site.baseurl | prepend: site.url }}
[Try with Docker]: {{ '/2020/01/21/try-with-docker' | prepend: site.baseurl | prepend: site.url }}
[dimage]: https://hub.docker.com/repository/docker/polettix/certificate-example
[Example on Certificates]: {{ '/2020/02/02/certificate-example' | prepend: site.baseurl | prepend: site.url }}
[OpenSSL]: https://www.openssl.org/
