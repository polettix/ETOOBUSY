---
title: PWC204 - Monotonic Array
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-16 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#204][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find out if the given array is Monotonic. Print 1 if
> it is otherwise 0.
>
>> An array is Monotonic if it is either monotone increasing or
>> decreasing.
>
>     Monotone increasing: for i <= j , nums[i] <= nums[j]
>     Monotone decreasing: for i <= j , nums[i] >= nums[j]
>
> **Example 1**
>
>     Input: @nums = (1,2,2,3)
>     Output: 1
>
> **Example 2**
>
>     Input: @nums (1,3,2)
>     Output: 0
>
> **Example 3**
>
>     Input: @nums = (6,5,5,4)
>     Output: 1

# The questions

No questions asked! (Maybe we could know if there's any limit to the
*integers*, so that we can understand if big integer support is needed
in [Perl][]. But this is looking for trouble).

# The solution

I'm *almost* happy with the following solution, I only suspect that the
`map` might be expressed differently and more idiomatically. Overall,
anyway, I think it's good:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put monotonic-array(@args) ?? 1 !! 0 }

sub monotonic-array (@array) {
   ([*] @array.rotor(2 => -1).map({[-] $_}).minmax[0, *-1]) >= 0
}
```

In a nutshell:

- the array elements are taken two by two, with overalaps. This means
  taking each possible pair of consecutive elements;
- the difference of each pair is calculated
- the minimum and maximum differences are extracted (`minmax` returns a
  range, so we take the two extremes)

If these two values have different signs... it's not monotonic.
Otherwise it is!

More or less the same goes in [Perl][], except that to do the check
element by element - arguably this is more efficient, because it does
not require calculating all the differences if the first elements
already allow taking a decision.


```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say monotonic_array(@ARGV) ? 1 : 0;

sub monotonic_array (@array) {
   my $direction = 0;
   for my $i (1 .. $#array) {
      my $delta = $array[$i] - $array[$i - 1];
      return 0 if $direction * $delta < 0;
      $direction ||= $delta;
   }
   return 1;
}
```

I like this short-circuiting too, so overall I'm happy with the more
low-level solution.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#204]: https://theweeklychallenge.org/blog/perl-weekly-challenge-204/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-204/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
