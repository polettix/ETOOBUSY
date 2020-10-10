---
title: perl-c-ontinuos
type: post
tags: [ perl, shell, linux ]
comment: true
date: 2020-10-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little shell script to keep a [Perl][] program under check.

When I'm working on a [Perl][] program, every now and then I do some
basic check to see if it *compiles* and its syntax is OK:

```shell
$ perl -c some-program.pl
some-program.pl syntax OK
```

That's because... well, sometimes a syntax error actually gets in:

```shell
$ perl -c some-other-program.pl
Global symbol "$whatever" requires explicit package name...
...
BEGIN not safe after errors--compilation aborted ...
```

It can be useful to keep a program under *continuous check*, in the
sense that I want to figure out quickly when it breaks the compilation.
The following script does exactly this in a Linux machine with
[inotifywait][] (part of [inotify][]) installed:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2021681.js"></script>

[Local version here][].

Use it by passing the name of the [Perl][] program you want to monitor:

```shell
$ perl-c-ontinuous whatever.pl 

/path/to/whatever.pl syntax OK
-------------------

syntax error at /path/to/whatever.pl line 8, near "my "
Global symbol "$original" requires explicit package name ...
...
BEGIN not safe after errors--compilation aborted ...
-------------------

/path/to/whatever.pl syntax OK
-------------------
```

At each save, the `perl -c` command is executed, and in case of syntax
errors... an error message is printed. Thanks to [inotify][] this can
happen only upon saving the file, sparing system resources.

[Perl]: https://www.perl.org/
[Local version here]: {{ '/assets/code/perl-c-ontinuos' | prepend: site.baseurl }}
[inotifywait]: https://linux.die.net/man/1/inotifywait
[inotify]: https://en.wikipedia.org/wiki/Inotify
