---
title: ProxyCommand
type: post
tags: [ security, ssh ]
comment: true
date: 2020-02-28 01:04:51 +0100
published: true
---

**TL;DR**

> What if your [OpenSSH][] `ssh` is before [release-7.3][] and you
> cannot use [ProxyJump][]? You can try with `ProxyCommand`!

As [observed by crimson-egret][]:

> `ProxyJump` was added in OpenSSH 7.3 but is nothing more than a
> shorthand for using `ProxyCommand`

Hence, the example from [ProxyJump][] can be adapted to work back up to
(and including) [release-5.4][], like this:

```
Host jumphost
   HostName jumphost.local
   User bar
   IdentityFile ~/.ssh/jumphost.key
Host target
   HostName target.internal
   User galook
   IdentityFile ~/.ssh/target.key
   ProxyCommand ssh -W %h:%p jumphost
```

See also: [Old Methods of Passing Through Jump Hosts][].

[OpenSSH]: https://www.openssh.com/
[release-7.3]: https://www.openssh.com/txt/release-7.3
[release-5.4]: https://www.openssh.com/txt/release-5.4
[ProxyJump]: {{ '/2020/02/27/proxyjump' | prepend: site.baseurl | prepend: site.url }}
[observed by crimson-egret]: https://superuser.com/questions/1253960/replace-proxyjump-in-ssh-config/1254668#1254668
[Old Methods of Passing Through Jump Hosts]: https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Proxies_and_Jump_Hosts#Old_Methods_of_Passing_Through_Jump_Hosts
