---
title: 'OpenSSH Server: understanding Allow* and Deny* stuff'
type: post
tags: [ OpenSSH, security ]
comment: true
date: 2021-10-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I decided to *really* understand what goes on with options
> `DenyUsers`, `AllowUsers`, `DenyGroups`, and `AllowGroups` in an
> [OpenSSH][] server.

Options `DenyUsers`, `AllowUsers`, `DenyGroups`, and `AllowGroups` in an
[OpenSSH][] server give some knobs for restricting how users are allowed
in the system. I have to admit that I didn't *really* understand them so
far.

The manpage in my system reads like this:

> The allow/deny directives are processed in the following order:
> `DenyUsers`, `AllowUsers`, `DenyGroups`, and finally `AllowGroups`.

This sounds a little ambiguous to be honest, at least *for me*. And I
also think that this *is* a little ambiguous, because people might have
different walks of life.

The bottom line to understand that statement is that [OpenSSH][] will
try hard to argue for *denying* the access attempt. Think of it like
some super-picky bureaucrat that will refuse to process your application
because you forgot to put a dot on one "i". At that point, it becomes
clear that **all** four directives are used to find a reason to *block*
access, *even* the `Allow` ones.

The comment at the beginning of the [relevant function][] put is very
clearly:

```
/*
 * Check if the user is allowed to log in via ssh. If user is listed
 * in DenyUsers or one of user's groups is listed in DenyGroups, false
 * will be returned. If AllowUsers isn't empty and user isn't listed
 * there, or if AllowGroups isn't empty and one of user's groups isn't
 * listed there, false will be returned.
 * If the user's shell is not executable, false will be returned.
 * Otherwise true is returned.
 */
```

So there you go, here's the steps in order. At any step, a user's access
request might be rejected, or move on to the following step.

- `DenyUsers`: if the user's *account name* matches any pattern in it,
  they get a `REJECT`.
- `AllowUsers`: this is used as a kind of *inverted `DenyUsers`*. If the
  user's *account name* does not match any pattern in it, they get a
  `REJECT`.
- `DenyGroups`: if *any* of the user's *group names* matches any pattern
  in it, they get a `REJECT`.
- `AllowGroups`: this is used as a kind of *inverted `DenyGroups`*. If
  *none* of the user's *group names* matches any of the patterns in it,
  they get a `REJECT`.

I was initially tricked by thinking that `Allow` means... *allow*, i.e.
that getting the name or group into the right list would lead to a grant
for access. It turns out that it just means "it can go to the next
stage", which makes perfect sense in hindsight.

![Granting roadblocks]({{ '/assets/images/sshd-deny-allow.png' | prepend: site.baseurl }})

The figure tries to picture this process: at any stage, part of the
requests will be rejected (turning away from their straight path) and
others will be allowed to go to the next step.

Looking at the picture, it's clear that the order in which the
directives are evaluated does not really change the result: only
requests that are able to get clearance at each roadblock will be
allowed, and everything else will be torn down at one point or another.

Maybe this contributed to my initial misunderstanding, who knows? What
about you? Did you get it right from the beginning?

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[OpenSSH]: https://www.openssh.com/
[relevant function]: https://github.com/openssh/openssh-portable/blob/d575cf44895104e0fcb0629920fb645207218129/auth.c#L91
