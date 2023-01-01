---
title: PWC162 - Summations
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-04 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#163][].
> Enjoy!

# The challenge

> You are given a list of positive numbers, `@n`.
>
> Write a script to find out the summations as described below.
>
> **Example 1**
>
>     Input: @n = (1, 2, 3, 4, 5)
>     Output: 42
>
>         1 2 3  4  5
>           2 5  9 14
>             5 14 28
>               14 42
>                  42
>
>     The nth Row starts with the second element of the (n-1)th row.
>     The following element is sum of all elements except first element of previous row.
>     You stop once you have just one element in the row.
>
> **Example 2**
>
>     Input: @n = (1, 3, 5, 7, 9)
>     Output: 70
>
>         1 3  5  7  9
>           3  8 15 24
>              8 23 47
>                23 70
>                   70

# The questions

What should we do if the list is empty?

Anybody has the formula for this? No? Well, I had to ask.

# The solution

I played a bit with the idea of finding the formula for calculating how
many times each individual element in the original array contributed to
the end result. Alas, I did not land on anything too elegant and my
brute force beast was screaming inside, so here we go in [Perl][]:


```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say summations(@ARGV);

sub summations (@n) {
   for (2 .. $#n) { $n[$_] += $n[$_ - 1] for $_ .. $#n }
   return $n[-1];
}
```

The input array (which is actually a copy of the input data) is used to
do all calculations. The outer loop takes care of "going forward" in it,
while the inner loop takes care to do the summations. There's a nice
simmetry in how the calculation can be arranged; I like the symmetry,
but the readability is terrible.

Whatever.

I discovered that this could be translated into [Raku][] in a pretty
straightforward way, so why not?


```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@n) { put summations(@n) }

sub summations (@n is copy) {
   for 2 .. @n.end { @n[$_] += @n[$_ - 1] for $_ .. @n.end }
   return @n[*-1];
}
```

Cheers and stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#163]: https://theweeklychallenge.org/blog/perl-weekly-challenge-163/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-163/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
