---
title: PWC194 - Digital Clock
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-08 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#194][]. Enjoy!

# The challenge

> You are given time in the format hh:mm with one missing digit.
>
> Write a script to find the highest digit between 0-9 that makes it
> valid time.
>
> **Example 1**
>
>     Input: $time = '?5:00'
>     Output: 1
>
>     Since 05:00 and 15:00 are valid time and no other digits can fit in the missing place.
>
> **Example 2**
>
>     Input: $time = '?3:00'
>     Output: 2
>
> **Example 3**
>
>     Input: $time = '1?:00'
>     Output: 9
>
> **Example 4**
>
>     Input: $time = '2?:00'
>     Output: 3
>
> **Example 5**
>
>     Input: $time = '12:?5'
>     Output: 5
>
> **Example 6**
>
>     Input: $time =  '12:5?'
>     Output: 9

# The questions

Is the expected range from '00:00' up to '23:59'?

# The solution

This challenge was a nice diversion from [Advent of Code][], which is
definitely preparing for growing its tax on my time.

Although it was not really *a challenge*, I guess it will result in
emerging a lot of different ways to approach it. In my case, it was
using a function that I almost never use, i.e. `index`.

The two parts have a different way of being approached. The minutes part
is quite "regular" in base 10, so either digit has its own range no
matter what the other digit shows.

Things are different for the hours, because having a `0` or a `1` in
first place means that we can go up to `9` in the second, while having a
`2` means that we can only go up to `3`. There's also a corresponding
constraint going the other way, of course.

Starting with [Raku][], here's how I boringly addressed it:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@ARGV) {
   @ARGV = < ?5:00 ?3:00 1?:00 2?:00 12:?5 12:5? > unless @ARGV;
   put "$_ -> {digital-clock($_)}" for @ARGV;
}

sub digital-clock ($input) {
   my $where = $input.index('?');
   return 9 if $where == 4;
   return 5 if $where == 3;
   return $input.substr(0, 1) == 2 ?? 3 !! 9 if $where == 1;
   return $input.substr(1, 1) < 4  ?? 2 !! 1;
}
```

The [Perl][] version was just *copy and tweak*:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

@ARGV = qw< ?5:00 ?3:00 1?:00 2?:00 12:?5 12:5? > unless @ARGV;
say "$_ -> ", digital_clock($_) for @ARGV;

sub digital_clock ($input) {
   my $where = index($input, '?');
   return 9 if $where == 4;
   return 5 if $where == 3;
   return substr($input, 0, 1) == 2 ? 3 : 9 if $where == 1;
   return substr($input, 1, 1) < 4  ? 2 : 1;
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#194]: https://theweeklychallenge.org/blog/perl-weekly-challenge-194/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-194/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Advent of Code]: https://adventofcode.com/
