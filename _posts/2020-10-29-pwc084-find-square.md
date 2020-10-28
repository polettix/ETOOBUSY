---
title: PWC084 - Find Square
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-29 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#084][].
> Enjoy!

# The challenge

> You are given matrix of size `m x n` with only `1` and `0`. Write a
> script to find the count of squares having all four corners set as
> `1`.

# The questions

I guess that most questions I would ask about this script is what the
input format is: is it an array-of-arrays? A string to be parsed? What
about invalid inputs (like other stuff than `1` and `0`)?

Another question is whether a lone `1` counts as a square or not. It
seems to *not* count as a square, considering the examples.

# The solution

I guess these challenges don't really get me create particularly
interesting solutions, anyway... here's my take.

```
 1 sub find_square (@matrix) {
 2    my $m     = @matrix;
 3    my $n     = $matrix[0]->@*;
 4    my $count = 0;
 5    for my $i (0 .. $m - 2) {    # no point in scanning last line
 6       for my $j (0 .. $n - 2) {    # same for last column
 7          next unless $matrix[$i][$j];    # only consider "1"s in upper left
 8          my $k = 1;
 9          while (($i + $k < $m) && ($j + $k < $n)) {
10             ++$count
11               if $matrix[$i][$j + $k]
12               && $matrix[$i + $k][$j]
13               && $matrix[$i + $k][$j + $k];
14             ++$k;
15          } ## end while (($i + $k < $m) && ...)
16       } ## end for my $j (0 .. $n - 2)
17    } ## end for my $i (0 .. $m - 2)
18    return $count;
19 } ## end sub find_square (@matrix)
```

We iterate through the matrix looking for suitable upper-left corners.
This means that:

- we will be searching for squares whose other vertices are either right
  or down (or both) from our starting corner;
- we will skip the last column and the last row, because there would not
  be candidates for other corners.

This accounts for the nested iterations in lines 5 and 6, where our
iteration variables scan all but the list row and column.

In this loop, we look for candidate upper-left corners, so we need that
to be `1` and skip `0` (line 7, the string `0` is *false* in [Perl][]).

At this point, we're looking for squares and we iterate different
possible sizes, starting from `1` (line 8). We do another sub-iteration
here, up to the point where the candidate square does not fit in the
matrix any more (line 9).

In this third loop, we already know that the upper-left corner is a `1`,
so we have to check the other three corners (lines 11 through 13) and
increment our count accordingly (line 10).

Line 14 increments the candidate square size, and line 18 eventually
returns the count.

Easy, uh!?!

As always, here's the full script should you want to play with it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub find_square (@matrix) {
   my $m     = @matrix;
   my $n     = $matrix[0]->@*;
   my $count = 0;
   for my $i (0 .. $m - 2) {    # no point in scanning last line
      for my $j (0 .. $n - 2) {    # same for last column
         next unless $matrix[$i][$j];    # only consider "1"s in upper left
         my $k = 1;
         while (($i + $k < $m) && ($j + $k < $n)) {
            ++$count
              if $matrix[$i][$j + $k]
              && $matrix[$i + $k][$j]
              && $matrix[$i + $k][$j + $k];
            ++$k;
         } ## end while (($i + $k < $m) && ...)
      } ## end for my $j (0 .. $n - 2)
   } ## end for my $i (0 .. $m - 2)
   return $count;
} ## end sub find_square (@matrix)

sub string2matrix ($string) {
   map { [split m{}mxs] } split m{\D+}mxs, $string;
}

sub print_matrix (@matrix) {
   map { say join ' ', $_->@*; $_ } @matrix;
}

my $matrix = shift || "1101 1100 0111 1011";
say find_square(print_matrix(string2matrix($matrix)));
```

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#084]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-084/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-084/#TASK2
[Perl]: http://www.perl.org/
