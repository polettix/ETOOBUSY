---
title: 'Pounded by #'
type: post
tags: [ rakulang ]
comment: true
date: 2021-08-31 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I've been hit by [an alleged no-bug][] in [Raku][].

While doing some parsing for [Advent of Code][] [2018][aoc-2018] [puzzle
4][aoc-2018-04] I ended up with the following regular expression:

```raku
/Guard \s+ \# (\d+)/
```

Alas, this does not work in [Raku][]. The `#` character is considered to
be starting a comment *despite* the preceding backslash, eventually
making the rest of the line invisible to the parser and making the
compilation fail spectacularly:

```
$ raku
Welcome to 𝐑𝐚𝐤𝐮𝐝𝐨™ v2021.07.
Implementing the 𝐑𝐚𝐤𝐮™ programming language v6.d.
Built on MoarVM version 2021.07.

To exit type 'exit' or '^D'
> '[1518-11-01 00:00] Guard #10 begins shift' ~~ /Guard \s+ \# (\d+)/
===SORRY!===
Regex not terminated.
at line 2
------> <BOL>⏏<EOL>
Unable to parse regex; couldn't find final '/'
at line 2
------> <BOL>⏏<EOL>
    expecting any of:
        infix stopper
```

I looked around and it seems that there is no plan to fix this in
[Rakudo][]: ['#' literals in Grammars: syntax error][previous-bug]. So I
opened a [documentation issue][] about this.

The [workaround][] is to put the `#` character in *quotes*:

```raku
/Guard \s+ '#' (\d+)/
```

which works fine:

```
> '[15818-11-01 00:00+ Guard #10 begins shift' ~~ /Guard \s+ '#' (\d+)/
｢Guard #10｣
 0 => ｢10｣
```

Actually, *workaround* is a bit of a misnomer, as it's really a
different, approved and maybe even suggested way of doing this kind of
things. But you know, conciseness.

Another way of doing this might be to create a *character class*
for the character, like this:

```raku
/Guard \s+ <[#]> (\d+)/
```

Is it any better? I don't know, maybe it's a bit too *line-noisy*...

Anyway, if you need to put `#` in your [Raku][] regular expressions...
*quote it* or, at least, *don't escape it*!

Stay safe and have `-Ofun` people!

[an alleged no-bug]: https://github.com/rakudo/rakudo/issues/1324
[Raku]: https://www.raku.org/
[Rakudo]: https://rakudo.org/
[Advent of Code]: https://adventofcode.com/
[aoc-2018]: https://adventofcode.com/2018/
[aoc-2018-04]: https://adventofcode.com/2018/day/4
[previous-bug]: https://github.com/rakudo/rakudo/issues/1324
[documentation issue]: https://github.com/Raku/doc/issues/3947
[workaround]: https://github.com/rakudo/rakudo/issues/1324#issuecomment-353042088
