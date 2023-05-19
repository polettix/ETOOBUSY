---
title: PWC217 - Max Number
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-19 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#217][].
> Enjoy!

# The challenge

> You are given a list of positive integers.
>
> Write a script to concatenate the integers to form the highest possible
> value.
>
> **Example 1:**
>     
>     Input: @list = (1, 23)
>     Output: 231
>
> **Example 2:**
>
>     Input: @list = (10, 3, 2)
>     Output: 3210
>
> **Example 3:**
>
>     Input: @list = (31, 2, 4, 10)
>     Output: 431210
>
> **Example 4:**
>
>     Input: @list = (5, 11, 4, 1, 2)
>     Output: 542111
>
> **Example 5:**
>
>     Input: @list = (1, 10)
>     Output: 110

# The questions

I read "concatenate" as "first consider the integers as strings, concatenate
them, then turn them back to integers and consider their value". Pretty
nitpicking.

# The solution

We have to put elements in the right order, so it's a sorting problem.
Luckily for us, there are *local* conditions that allow us establish what's
globally better or worse; I mean, considering any pair of elements in the
sequence of concatenation, taking their order that maximizes value is going
to improve. Put it into another way, the elements of this game have an
ordering, and we can leverage it.

When we have elements X and Y, we can tell whether it's better to put X or Y
before the other by concatenating them and comparing the results. If XY
wins, then X goes first; otherwise, Y goes first.

Having this way of comparing elements means that we can offload the actual
sorting to whatever the language makes available. Which is what we do here
in [Perl][]:

```perl
#!/usr/bin/env perl
print join('', sort { ($b . $a) <=> ($a . $b) } @ARGV), "\n";
```

This is easily translated into [Raku][]:

```raku
#!/usr/bin/env raku
@*ARGS.sort({"$^b$^a".Int <=> "$^a$^b".Int}).join('').put;
```

I guess this is it, stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#217]: https://theweeklychallenge.org/blog/perl-weekly-challenge-217/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-217/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
