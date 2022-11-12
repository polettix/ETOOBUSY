---
title: Quick-and-dirty capturing of STDOUT in Perl
type: post
tags: [ perl ]
comment: true
date: 2020-08-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A quick-and-dirty way to capture `STDOUT` in [Perl][] code.

Sometimes you might have a section of code that prints stuff out to
`STDOUT` and you wonder... why you didn't put all the stuff in a
variable that you can later *decide* to print or use otherwise.

This is a proof-of-concept of how to do this in a quick and rather dirty
way:

<script src='https://gitlab.com/polettix/notechs/-/snippets/2004718.js'></script>

Lines 9 through 14 are executed in a separate scope, which allows us to
*localize* `STDOUT` (line 10) and avoid messing up with the `STDOUT` in
the outer scope (e.g. at lines 15 and 17).

At this point, it suffices to open `STDOUT` to send stuff to the
variable (line 11) and we are done, prints in the [Perl][] code from now
on will go to our string (lines 12 and 13).

Example run:

```
$ perl qnd-capture.pl 
hello, this is shown immediately
grabbed: <in the middle...>
farewell, this is shown immediately
```

There are *a lot* of restrictions:

- might require some tweaking with previous versions of `perl`
- does not capture output from sub-processes
- I have no clue on how this works with XS code

but I guess it's fair for a quick-and-dirty solution!

[Perl]: https://www.perl.org/
