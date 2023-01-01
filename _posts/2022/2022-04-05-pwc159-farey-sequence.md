---
title: PWC159 - Farey Sequence
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-04-05 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#159][]. Enjoy!

# The challenge

> You are given a positive number, `$n`.
>
> Write a script to compute [Farey Sequence][] of the order `$n`.
>
> **Example 1:**
>
>     Input: $n = 5
>     Output: 0/1, 1/5, 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 1/1.
>
> **Example 2:**
>
>     Input: $n = 7
>     Output: 0/1, 1/7, 1/6, 1/5, 1/4, 2/7, 1/3, 2/5, 3/7, 1/2, 4/7, 3/5, 2/3, 5/7, 3/4, 4/5, 5/6, 6/7, 1/1.
>
> **Example 3:**
>
>     Input: $n = 4
>     Output: 0/1, 1/4, 1/3, 1/2, 2/3, 3/4, 1/1.

# The questions

Silly, silly question... *can I omit the `.` at the end*? I'll assume
yes because I'm a lazy bast'd.

Then, of course:

- by *number* we mean integer, right?
- is there a maximum value we should consider?

# The solution

The [Farey Sequence][] page is quite explanatory, and provides a Python
3 implementation too. I've basically translated it into [Raku][] here,
taking only the *ascending* code bits:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D \n = 4) { farey-sequence(n).join(', ').put }

sub farey-sequence (Int:D \n) {
   my ($a, $b, $c, $d) = (0, 1, 1, n);
   gather {
      take "$a/$b";
      while $c <= n {
         my $k = ((n + $b) / $d).Int;
         ($a, $b, $c, $d) = $c, $d, $k * $c - $a, $k * $d - $b;
         take "$a/$b";
      }
   }
}
```

Then, for the [Perl][] implementation, I decided to give it a small
twist, by using an array instead of the four variables and playing with
array all along:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say join ', ', farey_sequence(shift || 4);

sub farey_sequence ($n) {
   my @retval;
   my @cache = (0, 1, 1, $n);
   while ($cache[2] < $n) {
      my $k = int(($n + $cache[1]) / $cache[3]);
      push @cache, $k * $cache[2] - $cache[0], $k * $cache[3] - $cache[1];
      push @retval, join '/', splice @cache, 0, 2;
   }
   push @retval, '1/1';
   return @retval;
}
```

Not much to add to this challenge... stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#159]: https://theweeklychallenge.org/blog/perl-weekly-challenge-159/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-159/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Farey Sequence]: https://en.wikipedia.org/wiki/Farey_sequence
