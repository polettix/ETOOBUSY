---
title: PWC222 - Matching Members
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-22 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#222][]. Enjoy!

# The challenge

> You are given a list of positive integers, @ints.
>
> Write a script to find the total matching members after sorting the list
> increasing order.
>
> **Example 1**
>
>     Input: @ints = (1, 1, 4, 2, 1, 3)
>     Output: 3
>
>     Original list: (1, 1, 4, 2, 1, 2)
>     Sorted list  : (1, 1, 1, 2, 3, 4)
>
>     Compare the two lists, we found 3 matching members (1, 1, 2).
>
> **Example 2**
>
>     Input: @ints = (5, 1, 2, 3, 4)
>     Output: 0
>
>     Original list: (5, 1, 2, 3, 4)
>     Sorted list  : (1, 2, 3, 4, 5)
>
>     Compare the two lists, we found 0 matching members.
>
> **Example 3**
>
>     Input: @ints = (1, 2, 3, 4, 5)
>     Output: 5
>
>     Original list: (1, 2, 3, 4, 5)
>     Sorted list  : (1, 2, 3, 4, 5)
>
>     Compare the two lists, we found 5 matching members.

# The questions

Oh my, this must come from the past or [our fine host][manwar] wants to
tickle us with some controversy.

I mean, *what are matching members*?!?

The examples *seem* to indicate that you take the original list, then take a
*sorted* copy of the original list, then compare items in the same positions
and count how many of them *match*.

What is a *match*, though? It might be...

- ... that the two integer values are the same.
- ... that the two *elements* in the list are the same. If the list contains
  the same value twice, you might consider these two values as *different*
  members, like they are two twins that happen to share the same face but
  still are different people.
- ... something I can't think of.

Well, we're going to assume that a 3 is a 3, however many times it appears,
OK?!?

# The solution

Sort and compare by value, that's how we do things here!

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@list) { put matching-members(@list) }

sub matching-members (Positional(Int()) $list) {
   return ($list «==» $list.sort).sum;
   # OR: ($list «==» $list.sort).grep({$_}).elems;
}
```

There are two solutions above because I'm not sure that there is a
*guarantee* that a `True` boolean value will always turn into a 1 when
regarded as a number. Anyway, it works.

[Perl][] is similar, without the hyperstuff but with a similar shape
involved:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use List::Util 'sum';

say matching_members(@ARGV);

sub matching_members (@list) {
   my @sorted = sort { $a <=> $b } @list;
   return sum map { $list[$_] == $sorted[$_] ? 1 : 0 } 0 .. $#list;
}
```

This is it, stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#222]: https://theweeklychallenge.org/blog/perl-weekly-challenge-222/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-222/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
