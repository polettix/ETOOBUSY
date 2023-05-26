---
title: PWC218 - Matrix Score
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-26 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#218][].
> Enjoy!

# The challenge

> You are given a `m x n` binary matrix i.e. having only `1` and `0`.
>
> You are allowed to make as many moves as you want to get the highest
> score.
>
>> A move can be either toggling each value in a row or column.
>
> To get the score, convert the each row binary to dec and return the sum.
>
> **Example 1:**
>
>     Input: @matrix = [ [0,0,1,1],
>                        [1,0,1,0],
>                        [1,1,0,0], ]
>     Output: 39
>
>     Move #1: convert row #1 => 1100
>              [ [1,1,0,0],
>                [1,0,1,0],
>                [1,1,0,0], ]
>
>     Move #2: convert col #3 => 101
>              [ [1,1,1,0],
>                [1,0,0,0],
>                [1,1,1,0], ]
>
>     Move #3: convert col #4 => 111
>              [ [1,1,1,1],
>                [1,0,0,1],
>                [1,1,1,1], ]
>
>     Score: 0b1111 + 0b1001 + 0b1111 => 15 + 9 + 15 => 39
>
> **Example 2:**
>
>     Input: @matrix = [ [0] ]
>     Output: 1

# The questions

No questions asked, but we will assume that it's possible to represent the
bit strings as native integers.

# The solution

For each line, the higher the better. Hence, we have to make sure that the
most significant bit is always on - this can be done by toggling all lines
where it's off.

Then we move on to check each column, skipping the one for the most
significant bit (we already addressed it with the rows). We make sure that
we always have the highest possible number of bits toggled on, which is at
least half of them (for an even number of rows) or one more than the half
(for an odd number of rows). Hopefully more!

As the final sum is *in some sense* the sum of all individual positions
(each with its weight), this should give us the maximum.

On with the [Perl][] solution:


```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use List::Util 'sum';
use Data::Dumper;

say matrix_score($_) for test_matrixes();

sub matrix_score ($matrix) {
   my $n_rows = $matrix->@*;
   for my $r (0 .. $n_rows - 1) {
      toggle_row($matrix, $r) unless $matrix->[$r][0];
   }
   my $threshold = int($n_rows / 2) + ($n_rows % 2);
   for my $c (1 .. $matrix->[0]->$#*) {
      toggle_col($matrix, $c) if count_col($matrix, $c) < $threshold;
   }
   return sum(map { binstr_to_dec($_) } $matrix->@*);
}

sub binstr_to_dec ($row) {
   my $v = 0;
   $v = ($v << 1) | ($row->[$_] ? 1 : 0) for 0 .. $row->$#*;
   return $v;
}

sub toggle_row ($matrix, $r) {
   my $row = $matrix->[$r];
   $row->[$_] =~ tr/01/10/ for 0 .. $row->$#*;
   return $matrix;
}

sub toggle_col ($matrix, $c) {
   $_->[$c] =~ tr/10/01/ for $matrix->@*;
   return $matrix;
}

sub count_col ($matrix, $c) {
   return sum(map { $_->[$c] ? 1 : 0 } $matrix->@*) // 0;
}

sub test_matrixes {
   return (
      [[0, 0, 1, 1], [1, 0, 1, 0], [1, 1, 0, 0]],
      [[0]],
   );
}
```

I'm in a hurry and I'll hopefully add a [Raku][] solution later, stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#218]: https://theweeklychallenge.org/blog/perl-weekly-challenge-218/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-218/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
