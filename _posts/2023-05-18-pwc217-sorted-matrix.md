---
title: PWC217 - Sorted Matrix
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-18 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#217][]. Enjoy!

# The challenge

> You are given a `n x n` matrix where n >= 2.
>
> Write a script to find `3rd smallest` element in the sorted matrix.
>
> **Example 1**
>
>     Input: @matrix = ([3, 1, 2], [5, 2, 4], [0, 1, 3])
>     Output: 1
>
>     The sorted list of the given matrix: 0, 1, 1, 2, 2, 3, 3, 4, 5.
>     The 3rd smallest of the sorted list is 1.
>
> **Example 2**
>
>     Input: @matrix = ([2, 1], [4, 5])
>     Output: 4
>
>     The sorted list of the given matrix: 1, 2, 4, 5.
>     The 3rd smallest of the sorted list is 4.
>
> **Example 3**
>
>     Input: @matrix = ([1, 0, 3], [0, 0, 0], [1, 2, 1])
>     Output: 0
>
>     The sorted list of the given matrix: 0, 0, 0, 0, 1, 1, 1, 2, 3.
>     The 3rd smallest of the sorted list is 0.

# The questions

Usual stuff: we're assuming that it's a matrix of numbers, sorting is the
*regular* sorting for reals, ...

# The solution

We will completely disregard that it's a square matrix, and just go through
to find out the third smallest. We will keep a list of the three smallest
values found along the way, so we will only need to go through the list in
one sweep; each sweep will require us from one up to three comparisons, but
it's still bounded by three. Overall, complexity is linear, yay!

To track the three smallest items we keep them in a sorted array of up to
three elements. When a fourth sneakes in, we make sure to remove the biggest
element so that we go back to three items maximum. This is the sense of
array `@three-smallest` in the following [Raku][] code:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@rows) {
   my @matrix = @rows.map({ [ .split(/ \s* \, \s* /)».Int ] });
   put third-smallest(@matrix);
}

sub third-smallest (@matrix) {
   my @three-smallest;
   for @matrix -> $row {
      for @$row -> $item {
         my $idx = @three-smallest.elems;
         --$idx while $idx > 0 && @three-smallest[$idx - 1] > $item;
         next if $idx > 2;
         @three-smallest.splice($idx, 0, $item);
         @three-smallest.pop while @three-smallest > 3;
      }
   }
   return @three-smallest[*-1];
}
```

The [Perl][] version is pretty much a straight translation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;

my @matrix = map { [ split m{\s*,\s*}mxs ] } @ARGV;
say third_smallest(@matrix);

sub third_smallest {
   my @three_smallest;
   for my $row (@_) {
      for my $item ($row->@*) {
         my $idx = scalar(@three_smallest);
         --$idx while $idx > 0 && $three_smallest[$idx - 1] > $item;
         next if $idx > 2;
         splice(@three_smallest, $idx, 0, $item);
         pop(@three_smallest) while @three_smallest > 3;

      }
   }
   return $three_smallest[-1];
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#217]: https://theweeklychallenge.org/blog/perl-weekly-challenge-217/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-217/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
