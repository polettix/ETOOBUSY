---
title: Enter entr
type: post
tags: [ linux, perl ]
comment: true
date: 2020-10-23 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [entr][] runs arbitrary commands when files change

In post ([perl-c-ontinuous][]) I described a little script that monitors
the filesystem for a change in a target file, and runs `perl -c` (the
compilation check) over the file, just to make sure I don't introduce
syntax errors as I modify it.

I don't know where, but I was later pointed towards [entr][], which
generalizes this very idea in a program. It can control multiple files
(the list is read in standard input) and do interesting things, like
e.g. run a command only on a file that actually changed:

```shell
ls *.pl | entr perl -c /_
```

I did appreciate that the choice of the "file name placeholder" `/_` has
this explanation:

> The special /_ argument (somewhat analogous to $_ in Perl) ...

I'm always glad when I see this kind of references to [Perl][] ❤️

[entr][] seems to work out of the box on BSD, Linux and Mac OS, as well
on the Linux Subsystem for Windows and Docker for Mac, although with a
few restrictions (see [the GitHub page][]).

All in all, it seems amazing and worth checking out! Thanks to whoever
drove my attention to it!



[entr]: https://eradman.com/entrproject/
[perl-c-ontinuous]: {{ '/2020/10/11/perl-c-ontinuous/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[the GitHub page]: https://github.com/eradman/entr
