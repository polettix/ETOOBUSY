---
title: PWC088 - Spiral Matrix
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-27 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #2][] from the [Perl Weekly Challenge][]
> [#088][]. Enjoy!

# The challenge

> You are given `m x n` matrix of positive integers. Write a script to print
> spiral matrix as list.

# The questions

Well... defining *what* "spiral matrix" means would be helpful here (maybe
the definition is unambiguous but still!).

But yes, we can guess that we start from a corner, go around the perimeter,
then one step inside, rinse, repeat... which anyway leads to more questions:

- what corrner should we start from?
- which direction should we take?

The examples seem to hint that we have to start from the top-left corner
(i.e. the $(0, 0)$ position in the matrix, I guess) and go to the right,
then downwards, then...

# The solution

This is an interesting challenge because it *cries* to be addressed in the
cleanest possible way. By *clean* here I mean that we have some strategy
that can be applied generically and with the least number of exceptions
possible.

The spiral asks us to go from the outside towards the center. We will
consider decreasing *rectangular frames*. At each down-step, frames lose two
items in both the vertical and the horizontal dimensions.

When should we stop? Even sides will be shrinked to even sides, until the
side becomes $2$. Odd sides, on the other hand, end up with $1$, so it's a
degenerate rectangle at this point because we only have to consider one
single side (as opposed to four in a regular rectangle frame), i.e. either a
row or a column (or a single cell!) depending on the size of the input
matrix.

So, in the spirit of keeping things as boring as possible, here's the high
level solution:

```
 1 sub spiral_matrix ($M) {
 2    my ($rows, $cols) = (scalar($M->@*), scalar($M->[0]->@*));
 3    my ($sr, $sc) = (0, 0);
 4    my @v;
 5    while ($rows > 0 && $cols > 0) {
 6       if ($rows == 1)    { push @v, get_row($M, $sr, $sc, $cols) }
 7       elsif ($cols == 1) { push @v, get_col($M, $sr, $sc, $rows) }
 8       else {               push @v, get_frame($M, $sr, $sc, $rows, $cols) }
 9       ($sr, $sc, $rows, $cols) = ($sr + 1, $sc + 1, $rows - 2, $cols - 2);
10    }
11    return @v;
12 }
```

Line 2 initializes the number of rows and columns in their respective
variables. They will represent the size of our "frame" and we initialize
them with the size of the whole matrix.

Line 3 intoduces the variables that will keep track of the upper-left cell
of the frame we want to print. Again, we start from the whole matrix, so
they're both set at `0`.

Line 3 declares the variable (`@v`) that will collect the answer for our
problem, which also explains line 11.

The loop has simple conditions: as long as we are dealing with a frame whose
sizes are greater than `0`, we can do something (line 5).

Lines 6 and 7 deal with the special cases where we don't have to print out a
full frame but just one edge; they are only triggered when the input matrix
have one odd dimension and its value has dropped to `1`. Line 8 is the
general case for a frame. These three lines hand over to a helper function
to keep things readable and let us see what's going on.

Line 9 happens after we have collected a frame (or a single edge/cell for
the special cases); it's not time to try and move to an inner frame, which
means that our top-left cell indexes are moved one step down-right and both
sizes of the frame to consider drop by two units.

The three helper functions are the following:

```perl
sub get_row ($M, $r, $c, $n) { $M->[$r]->@[$c .. $c + $n - 1] }
sub get_col ($M, $r, $c, $n) { map { $M->[$r + $_][$c] } 0 .. $n - 1 }
sub get_frame ($M, $r, $c, $nr, $nc) {
   ($nr, $nc) = ($nr - 1, $nc - 1); # more useful like this
   return (
      get_row(        $M, $r      , $c      , $nc),
      get_col(        $M, $r      , $c + $nc, $nr),
      reverse(get_row($M, $r + $nr, $c +   1, $nc)),
      reverse(get_col($M, $r +   1, $c      , $nr)),
   );
}
```

The first two just implement getting `$n` elements starting at `$r` and
`$c`, either in a row or in a column. The third one leverages them to take a
full frame; each side of the frame is taken only from start up to the
element before the end, so that the next edge can start from the beginning.
This is why both `$nr` and `$nc` are decremented by one unit at the very
beginning.

And... this is it!

# The full thing

As always, here's the full code for this challenge:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

$|++;

sub get_row ($M, $r, $c, $n) { $M->[$r]->@[$c .. $c + $n - 1] }
sub get_col ($M, $r, $c, $n) { map { $M->[$r + $_][$c] } 0 .. $n - 1 }
sub get_frame ($M, $r, $c, $nr, $nc) {
   ($nr, $nc) = ($nr - 1, $nc - 1); # more useful like this
   return (
      get_row(        $M, $r      , $c      , $nc),
      get_col(        $M, $r      , $c + $nc, $nr),
      reverse(get_row($M, $r + $nr, $c +   1, $nc)),
      reverse(get_col($M, $r +   1, $c      , $nr)),
   );
}

sub spiral_matrix ($M) {
   my ($rows, $cols) = (scalar($M->@*), scalar($M->[0]->@*));
   my ($sr, $sc) = (0, 0);
   my @v;
   while ($rows > 0 && $cols > 0) {
      if ($rows == 1)    { push @v, get_row($M, $sr, $sc, $cols) }
      elsif ($cols == 1) { push @v, get_col($M, $sr, $sc, $rows) }
      else {               push @v, get_frame($M, $sr, $sc, $rows, $cols) }
      ($sr, $sc, $rows, $cols) = ($sr + 1, $sc + 1, $rows - 2, $cols - 2);
   }
   return @v;
}

sub read_matrix ($fh) {
   local $/ = ''; # read by "paragraph"
   my $text = <$fh> or return;
   return [ map { [grep /\d/, split m{\D+}mxs] } split m{\n+}mxs, $text ];
}

sub print_matrix ($fh, $M) {
   say {$fh} '[ ', join(', ', map {sprintf '%3d', $_} $_->@*), ' ]'
      for $M->@*;
   return;
}

while (my $M = read_matrix(\*DATA)) {
   print_matrix(\*STDERR, $M);
   say '[ ', join(', ', spiral_matrix($M)), ' ]';
}

__END__
[  1,  2,  3,  4 ]
[  5,  6,  7,  8 ]
[  9, 10, 11, 12 ]
[ 13, 14, 15, 16 ]

[ 1, 2, 3 ]
[ 4, 5, 6 ]
[ 7, 8, 9 ]

[ 1, 2, 3 ]
[ 4, 5, 6 ]

[  1,  2,  3,  4 ]
[  5,  6,  7,  8 ]
[  9, 10, 11, 12 ]
```

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#088]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-088/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-088/#TASK2
[Perl]: https://www.perl.org/
