---
title: PWC218 - Maximum Product
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-25 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#218][]. Enjoy!

# The challenge

> You are given a list of 3 or more integers.
>
> Write a script to find the 3 integers whose product is the maximum and
> return it.
>
> **Example 1**
>
>     Input: @list = (3, 1, 2)
>     Output: 6
>
>     1 x 2 x 3 => 6
>
> **Example 2**
>
>     Input: @list = (4, 1, 3, 2)
>     Output: 24
>
>     2 x 3 x 4 => 24
>
> **Example 3**
>
>     Input: @list = (-1, 0, 1, 3, 1)
>     Output: 3
>
>     1 x 1 x 3 => 3
>
> **Example 4**
>
>     Input: @list = (-8, 2, -9, 0, -4, 3)
>     Output: 216
>
>     -9 × -8 × 3 => 216

# The questions

From a high-level, generic standpoint I'd probably ask whether there's any
limit on the inputs, e.g. to know whether we have to use a big integer
library or not.

But well, yeah... nothing *serious*.

# The solution

If there's three numbers only, the solution is trivial as there is only one
possible value.

Otherwise, for negative numbers to *make sense*, they should come into pairs
to get to a positive value. In this case, the two *lowest* values and the
*highest* value would produce the biggest result.

The other candidate is that taking the three highest values.

As a matter of fact, these two alternatives are the same when there are only
three values, so we don't really have to check for that condition, right?

[Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { say maximum-product(@args) }

sub maximum-product (@args) {
   my @sorted = @args».Int.sort;
   my $below = @sorted[0] * @sorted[1] * @sorted[* - 1];
   my $above = [*] @sorted.reverse[0..2];
   return ($below, $above).max;
}
```

[Perl][] now:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say maximum_product(@ARGV);

sub maximum_product (@list) {
   @list = sort { $a <=> $b } @list;
   my $below = $list[0] * $list[1] * $list[-1];
   my $above = $list[-3] * $list[-2] * $list[-1];
   return $below > $above ? $below : $above;
}
```

Cheers!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#218]: https://theweeklychallenge.org/blog/perl-weekly-challenge-218/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-218/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
