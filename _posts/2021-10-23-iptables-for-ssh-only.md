---
title: iptables for SSH only
type: post
tags: [ linux, ssh, security ]
comment: true
date: 2021-10-23 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A basic [iptables][] setup to allow only incoming SSH traffic.

Sometimes you need only the very basic, bare-bones remote service of
being able to *log in* via SSH.

In these cases... it can be handy to use the following configuration for
[iptables][]:

```
*filter
:INPUT   DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT  DROP [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
COMMIT
```

It's basically... *everything drops*, except what is expressely allowed.

The loopback stuff is brought up to avoid weird things happening in
internal services.

The only additional allowed input (on all interfaces) is TCP traffic on
port 22, a.k.a. SSH traffic. On the output side... it's the same, but
with a catch: it has to belong to an already-established session. That
is: connections cannot *start* from the server.

If we save the file above in `/etc/iptables.rules`, we can install them
with this:

```
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.rules
```

This might be saved in `/etc/network/if-pre-up.d/iptables.startup`, or
anywhere else your [Linux][] distro will run it automatically.

And now... credits:

- [minimal-iptables][] contains the rules restoration mechanism as well
  the file I used to get started with 'iptables.rules`;

- the actual rules are taken from [this post][], adapted for
  `iptables-restore`.

I hope it can be useful!

[iptables]: https://www.netfilter.org/projects/iptables/index.html
[Linux]: https://www.kernel.org/
[minimal-iptables]: https://github.com/paulRbr/minimal-iptables
[this post]: https://serverfault.com/a/214998/370418
