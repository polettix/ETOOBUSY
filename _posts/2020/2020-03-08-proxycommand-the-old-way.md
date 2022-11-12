---
title: ProxyCommand - The Old Way
type: post
tags: [ security, ssh, toolbox ]
comment: true
date: 2020-03-08 08:00:00 +0100
published: true
---

**TL;DR**

> In [ProxyCommand][] we saw an alternative to [ProxyJump][] for older
> releases of [OpenSSH][]. What if we need to go even backwards in time?

The solution described in [ProxyCommand][] relies upon the `-W` option
for `ssh` (well, [OpenSSH][]'s `ssh`, of course), which was introduced
*exactly* 10 years ago (8th of March, 2010) in [release-5.4][]:

> Added a 'netcat mode' to ssh(1): "ssh -W host:port ..."

I wholeheartedly wish you don't need to go any backwards in time, but
just in case rest assured that `-W` is a *nice to have* but not
necessarily a *must*.

As a matter of fact - as also [observed by crimson-egret][] - it's
possible to *not* rely upon the *'netcat mode'* and use Netcat directly.
This is how our example would have to be changed:

```
Host jumphost
   HostName jumphost.local
   User bar
   IdentityFile ~/.ssh/jumphost.key
Host target
   HostName target.internal
   User galook
   IdentityFile ~/.ssh/target.key
   ProxyCommand ssh jumphost nc %h %p
```

This, of course, *requires* to have `nc` installed in the *jumphost*,
which might not always be the case. A few ideas about it:

- first, check whether Netcat is installed with a different name in
  *jumphost*. It might be there as `ncat` or `netcat`, for example;
- then, if the *jumphost* is Linux-based and you can place an executable
  there, you can put a *statically compiled binary* version and avoid
  intrusive installations of packages.

If you go for the second route, you might be interested into [Busybox -
multipurpose executable][], a component of the [#toolbox][] which
contains an implementation of `nc` that should do the trick.

Cheers!


[Busybox - multipurpose executable]: {{ '/2019/09/29/busybox-multipurpose-executable/' | prepend: site.baseurl | prepend: site.url }}
[ProxyJump]: {{ '/2020/02/27/proxyjump' | prepend: site.baseurl | prepend: site.url }}
[ProxyCommand]: {{ '/2020/02/28/proxycommand' | prepend: site.baseurl | prepend: site.url }}
[OpenSSH]: https://www.openssh.com/
[release-7.3]: https://www.openssh.com/txt/release-7.3
[release-5.4]: https://www.openssh.com/txt/release-5.4
[observed by crimson-egret]: https://superuser.com/questions/1253960/replace-proxyjump-in-ssh-config/1254668#1254668
[#toolbox]: {{ '/tagged/#toolbox' | prepend: site.baseurl | prepend: site.url }}
