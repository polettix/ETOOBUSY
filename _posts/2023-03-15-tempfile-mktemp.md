---
title: tempfile and mktemp
type: post
tags: [ shell ]
comment: true
date: 2023-03-15 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> `tempfile` is deprecated and `mktemp` should be used instead.

After an upgrade, I was starting to see this message when running one little
shell wrapper program:

```
WARNING: tempfile is deprecated; consider using mktemp instead.
```

This was a bit odd for me, because I definitely remember checking the man
page for `tempfile` and actually reading:

```
tempfile creates a temporary file in a safe manner.
```

Alas, what I did *not* check, at the end of the very same man page, was
this:

```
tempfile is deprecated; you should use mktemp(1) instead.
```

So well, here's the TIL: use `mktemp` instead of `tempfile`.

> How come you all knew it and never told me?!? 😁

Stay safe everybody!
