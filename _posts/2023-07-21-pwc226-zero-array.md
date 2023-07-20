---
title: PWC226 - Zero Array
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-07-21 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#226][].
> Enjoy!

# The challenge

> You are given an array of non-negative integers, @ints.
>
> Write a script to return the minimum number of operations to make every
> element equal zero.
>
>> In each operation, you are required to pick a positive number less than
>> or equal to the smallest element in the array, then subtract that from
>> each positive element in the array.
>
> **Example 1:**
>
>     Input: @ints = (1, 5, 0, 3, 5)
>     Output: 3
>
>     operation 1: pick 1 => (0, 4, 0, 2, 4)
>     operation 2: pick 2 => (0, 2, 0, 0, 2)
>     operation 3: pick 2 => (0, 0, 0, 0, 0)
>
> **Example 2:**
>
>     Input: @ints = (0)
>     Output: 0
>
> **Example 3:**
>
>     Input: @ints = (2, 1, 4, 0, 3)
>     Output: 4
>
>     operation 1: pick 1 => (1, 0, 3, 0, 2)
>     operation 2: pick 1 => (0, 0, 2, 0, 1)
>     operation 3: pick 1 => (0, 0, 1, 0, 0)
>     operation 4: pick 1 => (0, 0, 0, 0, 0)

# The questions

No specific questions, I'd probably ask if it makes sense to check for very
big numbers or big arrays.

Well, OK, I'll take the bait.

*Technically speaking*, if the array contains a 0, it's impossible to take a
*positive* integer that is *less than, or equal to* the smallest element in
the array (which would be 0). So I'll assume that this reads like *the
smallest **positive** element in the array*. 

# The solution

As we're asked the minimum number of bites that we can take, it makes no
sense to take bites that are *less* than the smallest positive value still
left in the array. Hence, at each step we would be removing *exactly* the
smallest positive integer, which leaves us with all what remains from other
values that are higher than that. As a consequence, we're going to need
exactly as many removals as there are non-zero distinct elements in the
array.

For this reason, our algorithm will be: count how many unique, positive
values are in the array and that will be our answer.

[Perl][] goes first now:

```perl
#!/usr/bin/env perl
use v5.24;
use List::Util 'uniq';
say scalar grep { $_ } uniq @ARGV;
```

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@ints) { put @ints.unique.grep({$_}).elems }
```

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#226]: https://theweeklychallenge.org/blog/perl-weekly-challenge-226/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-226/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
