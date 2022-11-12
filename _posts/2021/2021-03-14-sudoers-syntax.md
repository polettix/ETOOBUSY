---
title: Avoid password in sudo and more
type: post
tags: [ Linux, shell, sudo ]
comment: true
date: 2021-03-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> `%sudo ALL=(ALL:ALL) NOPASSWD: ALL`

**CAVEAT: Don't disable password asking from `sudo` by default, always think
carefully about it!**

It happened to me recently to work inside a few new virtual machines in my
laptop, i.e. a low-security situation. In these cases, I prefer to have
`sudo` just run without a password, because I usually have to run very
specific commands anyway (e.g. test commands in a specific software inside
the VM).

Invariably, I have to look for the right syntax to stop `sudo` from asking a
password.

Then I hit [Understanding sudoers(5) syntax], which is very well-written,
complete and contains a good **TL;DR** section at the beginning. I took the
liberty to redact it a bit to form *my* own TL;DR section at the beginning
of this post.

The page is very interesting and easy to follow; it gives a sense to all the
different sections in a natural way, and yes, I think *that* should actually
be the manpage.

Happy reading!

[Understanding sudoers(5) syntax]: https://toroid.org/sudoers-syntax
