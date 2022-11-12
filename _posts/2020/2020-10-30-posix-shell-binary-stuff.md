---
title: POSIX shell binary stuff
type: post
tags: [ shell, coding ]
comment: true
date: 2020-10-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> One of those times where you discover a bug in some important
> software... and also discover that it has been solved.

I was interested into how to deal with *writing* arbitrary binary data
into a file in a POSIX-compliant shell, and it occurred to me that
[Rich's sh (POSIX shell) tricks][] might... do the trick.

It does, indeed.

The adequately named section *Writing bytes to stdout by numeric value*
gives us this little gem:

```shell
writebytes () { printf %b `printf \\\\%03o "$@"` ; }
```

You can pass a lot of different stuff, all that is supported by the
integer conversion in the *inner* `printf`, which turns stuff into
octals. This is needed because basically format `b` in the outer
`printf` insists on getting octals in input.

There's a slight *nit-pick* to address to `writebytes` actually, in that
the inner `printf` does not actually spit out stuff that is adherent to
the standard (at least according to this [printf][] page):

> "\0ddd", where ddd is a zero, one, two, or three-digit octal number
> that shall be converted to a byte with the numeric value specified by
> the octal number

So, a more correct `writebytes` seems to be this, where each input
integer is expanded to *four* characters, which is allowed *and* ensures
that the first one is a `0` if we play it nice and feed only values up
to 255 (decimal) in:

```shell
writebytes () { printf %b `printf \\\\%04o "$@"` ; }
```

As I went to try this out in the shell in my virtual machine... It
didn't! It turns out I was using a version of [dash][] that suppresses
the printing of *NUL*s, which is something that has been solved in more
recent version (at least the bug disappeared in version `0.5.10.2-5`.

So... you might be writing POSIXly correct stuff... but you might still
have to fight bugs!

[Rich’s sh (POSIX shell) tricks]: {{ '/2020/03/21/rich-s-posix-shell-hints/' | prepend: site.baseurl }}
[printf]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html
[dash]: http://gondor.apana.org.au/~herbert/dash/
