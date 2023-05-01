---
title: Romeo - interface consistency
type: post
tags: [ romeo, perl ]
series: Romeo
comment: true
date: 2023-05-01 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some thoughts about interface consistency.

Most commands in [Romeo][] accept inputs and provide outputs. Most times,
inputs come from files, but from time to time they might come directly from
the command line.

One such example is the sub-command for validating the *Codice Fiscale*, an
identification code that is used in Italy for several "official" reasons.

I initially designed the interface for the whole set of commands like this:

- output is specified with option `-o`/`--output`
- inputs are straight command-line arguments (i.e. those without a switch).

This works fine for most "read many and transform" commands, but it's
sub-optimal for stuff like the *Codice Fiscale* validation because it's way
easier and intuitive to write this:

```
romeo cf bcadfe70a01h501j
```

instead of any of these:

```
# explicit command-line switch
romeo cf -c bcadfe70a01h501j

# read standard input
echo bcadfe70a01h501j | romeo cf

# shell redirection
romeo cf <( echo bcadfe70a01h501j )
```

Plus, having a difference in how inputs and outputs are handled always made
me uneasy in other scenarios, like ImageMagick or ffmpeg. Should I put `-i`
for inputs or `-o` for outputs? I always have to look how to do it.

So, I eventually switched to using explicit command-line switches for inputs
and outputs, at the expense of providing multiple inputs with multiple
occurrences of `-i`/`--input`. Which is totally fine, I think.

Cheers and... stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
