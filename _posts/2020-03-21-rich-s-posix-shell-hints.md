---
title: 'Rich’s sh (POSIX shell) tricks'
type: post
tags: [ shell, coding ]
comment: true
date: 2020-03-21 08:00:00 +0100
published: true
---

**TL;DR**

> An invaluable resource to do POSIX shell programming a bit safer.

Some time ago I discovered [Rich’s sh (POSIX shell) tricks][] - a page that
I find so useful that it's worth putting a link to the [copy in the Internet
Archive Wayback Machine][copy-wayback].

There's some ranting about using the shell for programming, and I agree.
There's also some ranting about being at the same level of [Perl][], which
I **don't** agree by today's standards - I guess it's OK to *not* agree on
everything 🙄.

If I had to only highlight one and only one thing, it's the first hint
(*Printing the value of a variable*). Since I've read it, I've started
avoiding `echo` completely, for the more type-unfriendly but safer:

```shell
printf '%s\n' ...
```

I guess it's all for today!


[Rich’s sh (POSIX shell) tricks]: http://www.etalabs.net/sh_tricks.html
[copy-wayback]: https://web.archive.org/web/20200301180645/http://www.etalabs.net/sh_tricks.html
[Perl]: https://www.perl.org/
