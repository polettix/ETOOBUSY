---
title: PWC141 - Like Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-01 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#141][].
> Enjoy!

# The challenge

> You are given positive integers, `$m` and `$n`.
>
> Write a script to find total count of integers created using the
> digits of `$m` which is also divisible by `$n`.
>
> Repeating of digits are not allowed. Order/Sequence of digits can’t be
> altered. You are only allowed to use (n-1) digits at the most. For
> example, 432 is not acceptable integer created using the digits of
> 1234. Also for 1234, you can only have integers having no more than
> three digits.
>
> **Example 1:**
>
>     Input: $m = 1234, $n = 2
>     Output: 9
>     
>     Possible integers created using the digits of 1234 are:
>     1, 2, 3, 4, 12, 13, 14, 23, 24, 34, 123, 124, 134 and 234.
>     
>     There are 9 integers divisible by 2 such as:
>     2, 4, 12, 14, 24, 34, 124, 134 and 234.
>
> **Example 2:**
>
>     Input: $m = 768, $n = 4
>     Output: 3
>     
>     Possible integers created using the digits of 768 are:
>     7, 6, 8, 76, 78 and 68.
>     
>     There are 3 integers divisible by 4 such as:
>     8, 76 and 68.

# The questions

It's not entirely clear to me what would happen with a number having
repeated digits *inside*. Let's take `1223` as an example: the
sub-sequence `123` can be generated in two ways, i.e. `12 3` and `1 23`.
Do they count as two different ones? I'll assume yes, definitely yes!

# The solution

To generate all possible sequences, we'll associate a bit to each
position in the input `$m`. If the bit is `0`, the digit will be
ignored; otherwise, it will be taken. At this point, it will be
sufficient to count from 1 up to $2^k - 2$, where $k$ is the number of
bits (we subtract 2 because we can take up to $k - 1$ bits by
requirement).

So, let's start with [Perl][] this time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub like_numbers ($m = 1234, $n = 2) {
   my @m = split m{}mxs, $m;
   my $bits = @m;
   my $N = 2 ** $bits - 2;
   my $c = 0;
   for my $i (1 .. $N) {
      my @b = split m{}mxs, sprintf "%0${bits}b", $i;
      my $v = join '', map { $b[$_] ? $m[$_] : () } 0 .. $#m;
      ++$c unless $v % $n;
   }
   return $c;
}

say like_numbers(@ARGV);
```

We count, we generate the bit sequences in `@b` and then select the
corresponding digits in `@m`... like we said before.

Let's move on to [Raku][] now:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Int:D $m = 1234, Int:D $n = 2) {
   like-numbers($m, $n).put;
}

sub like-numbers (Str() $m, Int:D $n) {
   my @m = $m.comb(/\d/);
   my $bits = @m.elems;
   my $template = '%0' ~ $bits ~ 'b';
   my $N= 2 ** $bits - 1;
   my $c = 0;
   for 0 ^..^ $N -> $i {
      my @b = $template.sprintf($i).comb(/<[0 1]>/);
      my $v = (0 .. @m.end).map({ @b[$_] > 0 ?? @m[$_] !! '' }).join('');
      ++$c if $v %% $n;
   }
   return $c;
}
```

It's a *perlish* translation - I suspect that some hyperoperator might
come to the rescue here, but I don't really know *which* 🙄

OK, enough for this week... stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#141]: https://theweeklychallenge.org/blog/perl-weekly-challenge-141/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-141/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
