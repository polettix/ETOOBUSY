---
title: 'LDAP filter to search for absence of an attribute'
type: post
tags: [ ldap ]
comment: true
date: 2022-01-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> It's simple to match for the absence of one or more attributes in an
> LDAP filter.

I found this in the internet, although I can't really point to the
precise location because... I forgot 🙄

Anyway, I had the problem of finding all entries in a LDAP directory
that *lacked* one or more attributes. It turns out that the syntax is
pretty simple.

Where this means *having whatever value for attribute `foo`*:

```
(foo=*)
```

this means *lacking attribute `foo` altogether*:

```
(!(foo=*))
```

I guess it's fair, although I have to admit my *utter* ignorance as to
whether attributes are allowed to take empty values. Whatever, that
works.

Looking for multiple possible missing attributes is easy with the *OR*
operator:

```
(!(!(foo=*))(!(bar=*)))
```

By the way, in my attempts I found that using spaces liberally worked in
my specific setup, althogh I understand that I was definitely lucky:

```
( |
    (!(foo=*))
    (!(bar=*))
)
```

Much more readable IMHO!!!

Stay safe folks!
