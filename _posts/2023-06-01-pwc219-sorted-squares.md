---
title: PWC219 - Sorted Squares
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-01 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#219][]. Enjoy!

# The challenge

> You are given a list of numbers.
>
> Write a script to square each number in the list and return the sorted
> list, increasing order.
>
> **Example 1**
>
>     Input: @list = (-2, -1, 0, 3, 4)
>     Output: (0, 1, 4, 9, 16)
>
> **Example 2**
>
>     Input: @list = (5, -4, -1, 3, 6)
>     Output: (1, 9, 16, 25, 36)

# The questions

Well, possibly I'd ask the range/domain of the input numbers, to figure out
whether I have to get some big-numbers library for languages that need it.

# The solution

We will just follow the indications: square the numbers, sort them in
increasing order, print them.

The [Raku][] solutions allows us to show off:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { @args».².sort.join(', ').put }
```

Yup, the `²` really does square stuff!

The [Perl][] alternative is good ol' code that you can depend on:

```perl
#!/usr/bin/env perl
use v5.24;
say join ', ', sort { $a <=> $b } map { $_ * $_ } @ARGV;
```

'nuff said, stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#219]: https://theweeklychallenge.org/blog/perl-weekly-challenge-219/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-219/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
