---
title: 'Term::ANSIColor and (lack of) the terminal'
type: post
tags: [ perl ]
comment: true
date: 2020-08-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little note on [Term::ANSIColor][].

Sometime it's handy to spice up the terminal output with some color,
e.g. to underline some important part. Doing this has been super-easy
since a long time in [Perl][], thanks to the core module
[Term::ANSIColor][]:

```perl
use Term::ANSIColor ':constants';
say BOLD, BLUE, 'wha',
    RED,        'tev',
    GREEN,      'ah!';
say RESET,      '(back...)';
```

![output with color]({{'/assets/images/term-ansicolor-1.png' | prepend: site.baseurl }})

This is implemented by interspersing *escape sequences* in the output,
that are intercepted by the terminal application to e.g. change to bold
or switch to a different color.

While useful, this can be detrimental when you look for data (e.g. with
`grep`), because escape sequences will get in the way. For example,
this:

```shell
$ ./ta.pl | grep whatevah
```

produces no output:

![grep fails]({{'/assets/images/term-ansicolor-2.png' | prepend: site.baseurl }})

We need the escape sequences to be disabled when the output is not to a
terminal... which is what the `-t` test function helps us doing! So we
can do this (order is important, put it *before* loading [Term::ANSIColor][]!):

```perl
BEGIN{ $ENV{ANSI_COLORS_DISABLED} = 1 unless -t STDOUT }
use Term::ANSIColor ':constants';
say BOLD, BLUE, 'wha',
    RED,        'tev',
    GREEN,      'ah!';
say RESET,      '(back...)';
```

Setting environment variable `ANSI_COLORS_DISABLED` to a true vaue
before loading the module (note the `BEGIN` block) puts the module in
*quiet* mode and everything works as expected:

![grep goes]({{'/assets/images/term-ansicolor-3.png' | prepend: site.baseurl }})

Or... just use [Term::ANSIColor::Conditional][] from [CPAN][] 🤫

[Term::ANSIColor]: https://metacpan.org/pod/Term::ANSIColor
[Term::ANSIColor::Conditional]: https://metacpan.org/pod/Term::ANSIColor::Conditional
[CPAN]: https://metacpan.org/
[Perl]: https://www.perl.org/
