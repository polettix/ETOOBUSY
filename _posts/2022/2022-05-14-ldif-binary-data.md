---
title: LDIF binary data
type: post
tags: [ ldap, ldif ]
comment: true
date: 2022-05-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Binary data in a [LDIF][] file: add a `:` and [base64][] the data.

I took a look at a few files in [LDIF][] format lately and some
attributes were specified with a **double** colon, like this:

```
foo:: blaHblaH
```

I initially thought it was a typo (I was looking at examples) but I
later realized that it was not, because it was all around.

So yes, I admit at having had a totally pragmatic approach to [LDIF][]
so far: copy and change based on common sense.

It turns out that a double colon indicates that the data is encoded with
[base64][]:

```
attrval-spec             = AttributeDescription value-spec SEP

value-spec               = ":" (    FILL 0*1(SAFE-STRING) /
                                ":" FILL (BASE64-STRING) /
                                "<" FILL url)

...

BASE64-CHAR              = %x2B / %x2F / %x30-39 / %x3D / %x41-5A /
                           %x61-7A
                           ; +, /, 0-9, =, A-Z, and a-z
                           ; as specified in RFC 2045

BASE64-STRING            = [*(BASE64-CHAR)]
```

Now I have that *matrixesque* feeling like *I know... how to fit binary
data in [LDIF][]!*.

Stay safe folks!


[LDIF]: https://www.ietf.org/rfc/rfc2849.txt
[base64]: {{ '/2020/08/13/base64/' | prepend: site.baseurl }}
