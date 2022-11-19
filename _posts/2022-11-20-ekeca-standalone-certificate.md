---
title: ekeca standalone certificate for a server
type: post
tags: [ security, openssl ]
comment: true
date: 2022-11-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> The logical conclusion: `ekeca server_standalone ...`

It's one of those times where... you saw it coming.

In [TLS for devs: mkcert and ekeca][] we saw a possible use case for
"standalone" certificate chains with one Root CA certificate to install
inside clients and other stuff to install on the server side.

This is now available in [ekeca][], with the new sub-command
`server_standalone`:

> `server_standalone [<common-name> [<alt-name> [...]]]`
>> create a standalone server certificate, complete with the Root CA
>> certificate to install into the client. This is one-shot with no
>> leftovers or space for renewals. Installing the Root CA certificate
>> should be fine because we ditch the corresponding private key and no
>> further certificates can be generated for it.

Let's see it in action:

```shell
$ ekeca server_standalone whatever.com '*.whatever.com'
# ... stuff happens

$ ls whatever.com
root-for-clients.crt  server.crt  server.key
```

Enjoy!

[ekeca]: {{ 'https://etoobusy.polettix.it/2020/02/08/ekeca/' | prepend: site.baseurl }}
[TLS for devs: mkcert and ekeca]: {{ '/2022/11/19/mkcert-and-ekeca/' | prepend: site.baseurl }}
