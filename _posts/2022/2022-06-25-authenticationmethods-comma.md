---
title: AuthenticationMethods... comma
type: post
tags: [ openssh, security ]
comment: true
date: 2022-06-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> `AuthenticationMethods`'s comma separator has a specific meaning.

TIL that in `sshd_config` this:

```
AuthenticationMethods publickey keyboard-interactive
```

is different from this:

```
AuthenticationMethods publickey,keyboard-interactive
```

I mean *sure they're different*, there's a comma (`,`) in the second! I
realized that the comma has a different *meaning* than a plain space, in
that:

- the comma separates authentication methods that must *all* be applied,
  in order, using AND semantics with short-circuiting;
- the space sparates authentication methods that are *alternative* to
  one another, using OR semantics with short-circuiting.

It was not a secret, though, because the manual page in my system is
quite clear about it:

> **AuthenticationMethods**
>
> Specifies the authentication methods that must be successfully
> completed for a user to be granted access.  This option must be
> followed by one or more comma-separated lists of authentication method
> names, or by the single string any to indicate the default behaviour
> of accepting any single authentication method.  If the default is
> overridden, then successful authen‐ tication requires completion of
> every method in at least one of these lists.
>
> For example, "publickey,password publickey,keyboard-interactive" would
> require the user to complete public key authentica‐ tion, followed by
> either password or keyboard interactive authentication.  Only methods
> that are next in one or more lists are offered at each stage, so for
> this example it would not be possible to attempt password or
> keyboard-interactive authen‐ tication before public key.
>
> For keyboard interactive authentication it is also possible to
> restrict authentication to a specific device by appending a colon
> followed by the device identifier **bsdauth**, **pam**, or **skey**,
> depending on the server configuration.  For example,
> "keyboard-interactive:bsdauth" would restrict keyboard interactive
> authentication to the bsdauth device.
>
> If the publickey method is listed more than once, sshd(8) verifies
> that keys that have been used successfully are not reused for
> subsequent authentications.  For example, "publickey,publickey"
> requires successful authentication using two different public keys.
>
> Note that each authentication method listed should also be explicitly
> enabled in the configuration.

Very good to know indeed.

Stay safe!

[Perl]: https://www.perl.org/
