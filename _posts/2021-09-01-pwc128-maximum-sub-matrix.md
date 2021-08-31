---
title: PWC128 - Maximum Sub-Matrix
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-01 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#128][]. Enjoy!

# The challenge

> You are given m x n binary matrix having 0 or 1.
>
> Write a script to find out maximum sub-matrix having only 0.
>
> **Example 1:**
>
>     Input : [ 1 0 0 0 1 0 ]
>             [ 1 1 0 0 0 1 ]
>             [ 1 0 0 0 0 0 ]
>     
>     Output: [ 0 0 0 ]
>             [ 0 0 0 ]
>
> **Example 2:**
>
>     Input : [ 0 0 1 1 ]
>             [ 0 0 0 1 ]
>             [ 0 0 1 0 ]
>     
>     Output: [ 0 0 ]
>             [ 0 0 ]
>             [ 0 0 ]

# The questions

You wish I hadn't!

Well... not that many actually.

First things first: *how do we define maximum*? There can be many
definitions, e.g. the one with most elements inside, or sorting first by
number of rows then by number of columns, or vice-versa... We'll settle
with the number of elements though.

Another one is: should the maximum sub-matrix be *exactly* the same as
pointed out in the examples? I mean, my algorithm for the first input
finds this:

```
[ 0 0 ]
[ 0 0 ]
[ 0 0 ]
```

which is perfectly valid, as it goes from row 1 column 3 up to row 3
column 4, and has the same number of `0` elements as the example output.

So I'll assume that yes, any submatrix will do, provided that it has the
right size and it is actually *contained* inside the original matrix,
even if it has a different shape than the provided solution. (Maybe the
*size* would have been a better output target, but whatever).

# The solution

This is one of those challenges in which I suspect that there's some
clever solution but I optimize for programmer's time. Well, *my* time.

I adopted a basic algorithm, based on the observation that any winning
sub-matrix MUST have a `0` in the top-left position. So it makes sense
to find out *all* positions where there is a `0' and, for each of them,
compute all possible sub-matrices having that position at the top-left
corner.

This means that I have, roughly speaking, two nested *general* loops:
one to find all positions with a `0` to use as top-left corner, one to
find all sub-matrices starting from that position and formed by `0`
only.

The reality is then a bit more complicated, because we're dealing with a
matrix here, so each *general* loop is actually formed by two nested
loops, one to iterate over rows and the other to iterate over columns.
But you get the idea.

Finding all `0` is easy - at least, I think that the code below should
be pretty much self-documenting (it's sub `maximum_sub_matrix` below).
The other one is a bit trickier though, and deserves a few words.

Let's consider a generic example, isolating only the sub-matrix from the
target position up to the end of the matrix (i.e. the lower-right
corner):

```
0 0 0 0 1 .....
0 0 0 0 0 0 1 ...
0 0 0 1 ...
0 0 1 ...
0 1 ....
1 ...
```

In our algorithm, we proceed row by row. The first row will give us one
$(1, x_1)$ candidate sub-matrix, where $x_1$ might potentially arrive up
to the end of the row.

In the example, though, $x$ can only arrive up to 4, because after the
fourth position we hit a `1`. So there we have it, the first candidate
is a $(1, 4)$ sub-matrix, whose size is $4$.

Now we add another row. The second row, in particular, has more `0`s
than the first one, but we cannot consider *all* of them because we have
to extract a $(2, x_2)$ rectangular sub-matrix. We know from the
previous line that we cannot go past $4$, so in this case our iteration
for $x_2$ cannot go beyond that limit. This makes us settle on a $(2,
4)$ candidate, because we have enough `0` to complete a second row like
the first one, for a total size of $8$.

Now we move on adding the third row, i.e. we're after the best $(3,
x_3)$ candidate starting at the given position. Our $x_3$ has the same
constraint as $x_2$, i.e. it cannot go beyond $4$, but this time we must
stop before because $x_3$ is actually $3$ as we hit a `1` on the fourth
position. This gives us $(3, 3)$ with  a size of $9$ and our best
candidate so far.

The following rows go along the same lines: $x_4$ cannot go past $3$
from the previous line, but it stops at $2$ and gives us $(4, 2)$ and a
size of $8$, which is lower than our best of $9$. Last, we add the fifth
line where $x_5$ is equal to `1` and the total size is $5$, which is too
low. We cannot go beyond that row because there's a `1`. so we stop
there.

All in all, then, in our quest we found out that the best candidate has
size $9$ and dimensions $(3, 3)$.

In this last days I studied a lot of [Raku][], so it just seemed right
to start with a [Perl][] implementation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub maximum_submatrix_at ($M, $y, $x) {
   my $target = $M->[$y][$x];
   my ($max_size, @best) = (0) x 3;
   my $max_x = $M->[$y]->$#*;
   for my $Y ($y .. $M->$#*) {
      last if $M->[$Y][$x] ne $target;
      my $y_size = $Y - $y + 1;
      my $size = 0;
      for my $X ($x .. $max_x) {
         if ($M->[$Y][$X] ne $target) {
            $max_x = $X - 1;
            last;
         }
         $size += $y_size;
         if ($size > $max_size) {
            $max_size = $size;
            @best = ($y_size, $X - $x + 1);
         }
      }
   }
   return ($max_size, @best);
}

sub maximum_submatrix ($M, $target = '0') {
   my ($max, @best) = (0);
   for my $y (0 .. $M->$#*) {
      for my $x (0 .. $M->[$y]->$#*) {
         next unless $M->[$y][$x] eq $target;
         my ($size, @round) = maximum_submatrix_at($M, $y, $x);
         ($max, @best) = ($size, @round) if $size > $max;
      }
   }
   return [map {[(0) x $best[1]]} 1 .. $best[0]];
}

sub print_matrix ($M) {
   for my $row ($M->@*) {
      say '[ ', join(' ', $row->@*), ' ]';
   }
}

my @Ms = (
   [
      [ 1, 0, 0, 0, 1, 0, ],
      [ 1, 1, 0, 0, 0, 1, ],
      [ 1, 0, 0, 0, 0, 0, ],
   ],
   [
      [ 0, 0, 1, 1, ],
      [ 0, 0, 0, 1, ],
      [ 0, 0, 1, 0, ],
   ],
   [
      [ 0, 1, 0, 1, ],
      [ 1, 0, 1, 0, ],
      [ 0, 1, 0, 1, ],
      [ 1, 0, 1, 0, ],
   ],
   [
      [ 1, 0, 0, 0, 1, 0, ],
      [ 1, 0, 1, 0, 0, 1, ],
      [ 1, 0, 0, 0, 0, 0, ],
   ],
);

for my $M (@Ms) {
   say '';
   print_matrix($M);
   say '---';
   print_matrix(maximum_submatrix($M));
   say "\n--------\n";
}
```

Sub `maximum_sub_matrix` deals with the *outer loop(s)*, while
`maximum_sub_matrix_at` deals with the *inner loop(s)*. No big deal.

It does not take too much to translate this in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub maximum-submatrix-at (@M, $y, $x) {
   my $target = @M[$y][$x];
   my ($max-size, @best) = 0 xx 3;
   my $max-x = @M[$y].end;
   for $y .. @M.end -> $Y {
      last if @M[$Y][$x] ne $target;
      my $y-size = $Y - $y + 1;
      my $size = 0;
      for $x .. $max-x -> $X {
         if @M[$Y][$X] ne $target {
            $max-x = $X - 1;
            last;
         }
         $size += $y-size;
         if ($size > $max-size) {
            $max-size = $size;
            @best = ($y-size, $X - $x + 1);
         }
      }
   }
   return ($max-size, |@best);
}

sub maximum-submatrix (@M, $target = '0') {
   my ($max, @best) = (0);
   for 0 .. @M.end -> $y {
      for 0 .. @M[$y].end -> $x {
         next unless @M[$y][$x] eq $target;
         my ($size, @round) = maximum-submatrix-at(@M, $y, $x);
         ($max, @best) = ($size, |@round) if $size > $max;
      }
   }
   return [(1 .. @best[0]).map: { [ 0 xx @best[1] ] }];
}

sub print-matrix (@M) {
   for @M -> @row {
      put '[ ', @row.join(' '), ' ]';
   }
}

my @Ms = (
   [
      [ 1, 0, 0, 0, 1, 0, ],
      [ 1, 1, 0, 0, 0, 1, ],
      [ 1, 0, 0, 0, 0, 0, ],
   ],
   [
      [ 0, 0, 1, 1, ],
      [ 0, 0, 0, 1, ],
      [ 0, 0, 1, 0, ],
   ],
   [
      [ 0, 1, 0, 1, ],
      [ 1, 0, 1, 0, ],
      [ 0, 1, 0, 1, ],
      [ 1, 0, 1, 0, ],
   ],
   [
      [ 1, 0, 0, 0, 1, 0, ],
      [ 1, 0, 1, 0, 0, 1, ],
      [ 1, 0, 0, 0, 0, 0, ],
   ],
);

for @Ms -> @M {
   put '';
   print-matrix(@M);
   put '---';
   print-matrix(maximum-submatrix(@M));
   put "\n--------\n";
}
```

And with this... *that's all, folks!*

[The Weekly Challenge]: https://theweeklychallenge.org/
[#128]: https://theweeklychallenge.org/blog/perl-weekly-challenge-128/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-128/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
