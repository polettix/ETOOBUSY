---
title: Hexdumping
type: post
tags: [ computer ]
comment: true
date: 2022-06-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> There's [hexdump][hd1]. Then there's [xxd][] (and
> [Data::HexDump::XXD][]).

I read about [manwar's journey to hexdumping][journey] and I discovered
that a plain call to `hexdump` might not always give back the same
result. At least on a Linux box and on a Mac:

```
# In a Linux box
$ printf ABCD | hexdump
0000000 4241 4443                              
0000004

# In Mac OS X
$ printf ABCD | hexdump
0000000 41 42 43 44
0000004
```

> I know, I know... by **Linux** I mean my Debian Linux installation in
> a virtual machine that runs over an Intel-based x86\_6 chip.

I initially thought that I was looking at two different implementations,
which can happen frequently in this kind of comparisons because Mac OS X
is based on BSD. Then I called `man hexdump` in the Linux box:

```
HEXDUMP(1)            BSD General Commands Manual            HEXDUMP(1)

NAME
     hexdump, hd — ASCII, decimal, hexadecimal, octal dump
...
```

OK, that was not the explanation for the difference. I guess they are
basically compiled with different defaults, as explained inside their
respective man pages:

```
########################################################################
# Linux man page

-x  Two-byte hexadecimal display.  Display the input offset in
    hexadecimal, followed by eight, space separated, four column,
    zero-filled, two-byte quantities of input data, in hexadecimal,
    per line.

...

If no format strings are specified, the default display is equivalent
to specifying the -x option.


########################################################################
# Mac OS X man page

If no format strings are specified, the default display is a one-byte
hexadecimal display.
```

As I read through the options list, `-C` would have probably helped
[manwar][] speed up the investigation:

```
-C  Canonical hex+ASCII display.  Display the input offset in
    hexadecimal, followed by sixteen space-separated, two column,
    hexadecimal bytes, followed by the same sixteen bytes in %_p format
    enclosed in ``|'' characters.
```

Let's test it in the two platforms:

```
# Linux
$ printf ABCD | hexdump -C
00000000  41 42 43 44                                       |ABCD|
00000004

# Mac OS X
$ printf ABCD | hexdump -C
00000000  41 42 43 44                                       |ABCD|
00000004
```

Anyway, I prefer [xxd][] to do the hex dumping:

```
$ printf ABCD | xxd
00000000: 4142 4344                                ABCD
```

I like it so much that I already wrote about it in
[Data::HexDump::XXD][]!

Stay safe folks!

[Perl]: https://www.perl.org/
[Data::HexDump::XXD]: {{ '/2021/03/28/xxd/' | prepend: site.baseurl }}
[hd1]: https://www.man7.org/linux/man-pages/man1/hexdump.1.html
[journey]: https://theweeklychallenge.org/blog/decode-hexdump/
[xxd]: https://linux.die.net/man/1/xxd
[manwar]: http://www.manwar.org/
