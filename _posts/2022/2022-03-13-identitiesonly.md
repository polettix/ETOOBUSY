---
title: OpenSSH IdentitiesOnly
type: post
tags: [ ssh, security, OpenSSH ]
comment: true
date: 2022-03-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I discovered option [IdentitiesOnly][] in [ssh\_config][sshconfig].

Recently I was hit by a problem in using [OpenSSH][] where I defined two
different `Host` sections, pointing to the same host but setting
different `IdentityFile`s:

```
Host foo bar
    HostName ssh.example.com
    User foobar
Host foo
    IdentityFile ~/.ssh/id_rsa-foo
Host bar
    IdentityFile ~/.ssh/id_rsa-bar
```

This can be a common arrangement when using [Gitolite][], because we
might have two separate identities (one as `admin` and one as regular
user).

The problem? Even when accessing via the `bar` alias, the [OpenSSH][]
client was still offering the key for `foo`.

Luckily for me, someone already thought of asking and this came out:
[How could I stop ssh offering a wrong key?][serfault] The problem is
that I was also relying upon [ssh-agent][ssh-agent(1)] and it was
*adding* its stored keys *in addition* to the ones set as
`IdentityFile`s in the configuration file.

This is where option [IdentitiesOnly][] comes to the rescue:

> Specifies that [ssh(1)][] should only use the configured
> authentication identity and certificate files (either the default
> files, or those explicitly configured in the `ssh_config` files or
> passed on the [ssh(1)][] command-line), even if [ssh-agent(1)][] or a
> `PKCS11Provider` or `SecurityKeyProvider` offers more identities. The
> argument to this keyword must be `yes` or `no` (the default). This
> option is intended for situations where ssh-agent offers many
> different identities.

Hence, as suggested in [the accepted answer][], I added this at the end
of the configuration file:

```
Host *
   IdentitiesOnly yes
```

Now the right key is selected, yay!

[sshconfig]: https://man.openbsd.org/ssh_config
[IdentitiesOnly]: https://man.openbsd.org/ssh_config#IdentitiesOnly
[ssh(1)]: https://man.openbsd.org/ssh.1
[ssh-agent(1)]: https://man.openbsd.org/ssh-agent.1
[OpenSSH]: https://www.openssh.com/
[serfault]: https://serverfault.com/questions/450796/how-could-i-stop-ssh-offering-a-wrong-key
[Gitolite]: https://gitolite.com/gitolite/
[the accepted answer]: https://serverfault.com/a/450807/370418
