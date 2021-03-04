---
title: A cheap terminal trick
type: post
tags: [ perl, terminal, shell, color ]
comment: true
date: 2021-03-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A cheap trick to highlight stuff in the terminal.

Sometimes a program has to output something and we want to be sure of
what we are reading *including spaces*. I mean, there might be
*trailing* spaces that are virtually impossible to see in the terminal,
right? Sometimes even *leading* spaces might puzzle.

My usual go-to solution in this case is to put two *boundary* characters
around the actual output, so that it's delimited unambiguously:

```
result: «  two spaces before and three after   »
```

Most terminals today provide support for colors... something that I
already discussed in [ANSI Color][]. This can be used to obtain the same
result but *without* the additional boundary characters:

```shell
# insert https://gitlab.com/polettix/notechs/-/snippets/2039857
# initializeANSI()
# { ...
initializeANSI
result='  two before and three after   '
printf 'result: %s\n' "$boldon$whitef$purpleb$result$reset"
```

This gives us the following:

<div style="background-color: black">
<tt>
<span style="background-color: purple; color: white; font-weight: bold">&nbsp;&nbsp;two before and three after&nbsp;&nbsp;&nbsp;</span>
</tt>
</div>

&nbsp;

Of course it's not necessary to be *this generic* and just rely on a
couple of copy-and-pasteable variable definitions to get the same:

```shell
highlight="$(printf %b \\033)[1;97;45m" reset="$(printf %b \\033)[0m"
result='  two before and three after   '
printf 'result: %s\n' "$highlight$result$reset"
```

This admittedly cheap trick is easy to translate in [Perl][] (*and I
guess in most of other languages!*):

```perl
my $highlight = "\e[1;97;45m"; my $reset = "\e[0m";
my $result = '  two before and three after   ';
say "result: $highlight$result$reset";
```

I know that I err *a bit too much* in the copy-and-paste land... but
sometimes that one line is really the only thing that's needed!

[ANSI Color]: {{ '/2020/11/17/ansi-color/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
