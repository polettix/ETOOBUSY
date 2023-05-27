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

> Update: cleaned up solution, text, and added [Raku][] solution.

Each position in the matrix holds a value that depends on its column,
according to powers of 2 starting from the right-most column (value 1),
doubling for each move to the left. There is no dependency on the row.

To start with, we can observe that it's better to have a single 1 on the
left than all 1 in the rest of a row going to the right, i.e.:

```
1 0...0 > 0 1...1
```

(the two "strings" of either 0 or 1 in the above inequality have the same
amount of digits, of course).

This means that we MUST turn on the left-most bit in every row, which can be
done by toggling every row where the left-most bit is not set yet.

At this point, for each residual column going to the right, our best
strategy is to turn on as many bits as possible. For each column we count
how many bits are on, and toggle the whole column if it's not *at least*
half of them.

Now, of course, one might argue what would happen if we did this initial
move to the left-most column as well. This blog is too narrow to write a
full demonstration, but trust me that nothing changes. (I trust it, anyway).

On with the [Perl][] solution:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use List::Util 'sum';

say matrix_score($_) for test_matrixes();

sub matrix_score ($matrix) {
   my $n_rows = $matrix->@*;
   my $threshold = int($n_rows / 2) + ($n_rows % 2);
   for my $r (0 .. $n_rows - 1) {
      toggle_row($matrix, $r) unless $matrix->[$r][0];
   }
   for my $c (1 .. $matrix->[0]->$#*) {
      toggle_col($matrix, $c) if count_col($matrix, $c) < $threshold;
   }
   return sum(map { binarr_to_dec($_) } $matrix->@*);
}

sub binarr_to_dec ($row) {
   my $v = 0;
   $v = ($v << 1) | ($row->[$_] ? 1 : 0) for 0 .. $row->$#*;
   return $v;
}

sub toggle_row ($m, $r) {
   $m->[$r][$_] = 1 - $m->[$r][$_] for 0 .. $m->[$r]->$#*;
}

sub toggle_col ($matrix, $c) { $_->[$c] = 1 - $_->[$c] for $matrix->@* }

sub count_col ($m, $c) { sum(map { $_->[$c] ? 1 : 0 } $m->@*) // 0 }

sub test_matrixes {
   return (
      [[0, 0, 1, 1], [1, 0, 1, 0], [1, 1, 0, 0]],
      [[0]],
   );
}
```

I initially tried to implement `binarr_to_dec` with some combination of
`pack` and `unpack`, but failed miserably. The joys of having Plan B.

The [Raku][] alternative is pleasant in my opinion:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @tests =
      [[0, 0, 1, 1], [1, 0, 1, 0], [1, 1, 0, 0]],
      [[0],],
   ;
   put(matrix-score($_)) for @tests;
}

sub matrix-score ($matrix) {
   my $n-rows = $matrix.elems;
   my $threshold = ($n-rows div 2) + ($n-rows % 2);
   for ^$n-rows -> $r {
      toggle-row($matrix, $r) unless $matrix[$r][0];
   }
   for 1 .. $matrix[0].end -> $c {
      toggle-col($matrix, $c) if count-col($matrix, $c) < $threshold;
   }
   return $matrix.map({ $_.join('').parse-base(2) }).sum;
}

sub toggle-row ($m, $r) { $m[$r][$_] = 1 - $m[$r][$_] for 0 .. $m[0].end }

sub toggle-col ($matrix, $c) { $_[$c] = 1 - $_[$c] for @$matrix }

sub count-col ($matrix, $c) { $matrix.map({ $_[$c] }).sum }
```

OK, now the residual debt with this post has been paid... stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#218]: https://theweeklychallenge.org/blog/perl-weekly-challenge-218/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-218/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
