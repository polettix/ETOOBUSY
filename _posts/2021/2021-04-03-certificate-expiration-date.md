---
title: Certificate expiration date
type: post
tags: [ security, OpenSSL ]
comment: true
date: 2021-04-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Getting the expiration date of a TLS certificate.

The `openssl` command from [OpenSSL][] has a lot of options, including the
possibility to print the expiration date of a TLS certificate on standard output:

```shell
$ openssl x509 -noout -enddate -in mycert.pem
notAfter=May 10 03:09:21 2021 GMT
```

This can be combined with automated fetching of a remote certificate, again
via `openssl` using the `s_client` sub-command:

```shell
$ openssl s_client \
        -connect polettix.it:443 \
        -servername polettix.it \
        </dev/null 2>/dev/null \
    | openssl x509 -noout -enddate
```

A few hints that might save you some time:

- the `-connect` option is only used to locate where to connect, putting a
  FQDN here will not do what you mean. Or at least, what **I** mean. If you
  have a virtualhosts environment where multiple domains lye on the same IP
  Address, you *MUST* use the `-servername` option too, so that the right
  (virtual) host will be selected;
- by default, `s_client` opens a connection and waits for input to be sent
  to the other side. In this case we are interested only in the "handshake
  stuff", so we get our standard input from `/dev/null` so that the program
  closes the connection and exists as soon as the initial phase is
  completed.

Of course we can wrap it into a shell function:

```
certificate_expiration_date() {
   local target="$1"
   local domain="${target%:*}"
   local port="${target#*:}"
   [ "$port" != "$target" ] || port='443'
   
   openssl s_client \
         -connect "$domain:$port" \
         -servername "$domain" \
         </dev/null 2>/dev/null \
      | openssl x509 -noout -enddate

}
```

This accepts both a plain domain name - defaulting to port 443 - or a full
target which includes the port number:

```shell
$ /tmp/ced.sh polettix.it:443
notAfter=May 10 03:09:21 2021 GMT

$ /tmp/ced.sh polettix.it
notAfter=May 10 03:09:21 2021 GMT

$ /tmp/ced.sh google.com
notAfter=Jun  3 14:54:06 2021 GMT
```

Stay safe everyone!

[OpenSSL]: https://www.openssl.org/
