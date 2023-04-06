---
title: PWC211 - Toepliz Matrix
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-04-06 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#211][]. Enjoy!

# The challenge

> You are given a matrix `m x n`.
>
> Write a script to find out if the given matrix is `Toeplitz Matrix~.
>
>> A matrix is Toeplitz if every diagonal from top-left to bottom-right has
>> the same elements.
>
> **Example 1**
>
>     Input: @matrix = [ [4, 3, 2, 1],
>                        [5, 4, 3, 2],
>                        [6, 5, 4, 3],
>                      ]
>     Output: true
>
> **Example 2**
>
>     Input: @matrix = [ [1, 2, 3],
>                        [3, 2, 1],
>                      ]
>     Output: false

# The questions

I was a bit dubious after reading the text part alone, and not looking at
the examples, because I thought that the diagonals had to be the same, only
shifted. Now, an `m x n` matrix can only have *some* full diagonals, and I
was already thinking whether I would have to wrap or not.

Well, nothing like this it seems. So here are my assumptions, with a big
final question *is this right?* at the end:

- every diagonal is any subset of the matrix starting from the top or the
  left edge and going on diagonally down-right, one step at a time in each
  direction
- each diagonal is only composed of one single integer, repeated as many
  times as necessary.

There is still space to be more *precise*, but let's not overdo.

# The solution

My take on this challenge is to forget about matrixes and focus on comparing
adjacent rows only. It might work with columns, too, but it's easier to take
slices of a matrix when it's stored by rows.

Considering two adjacent rows, in a Toepliz matrix the one below must be
almost the same as the one above; in particular, we have to make sure that
the first `n - 1` elements of the upper row are the same as the *last* `n -
1` elements of the lower one:

```
(i - 1)-th:    A B C ... X *
                \ \ \     \
      i-th:    * A B C ... X
```

Check this for all pairs of adjacent rows and we're done.

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my $m1 = [ [4, 3, 2, 1],
              [5, 4, 3, 2],
              [6, 5, 4, 3],
            ];
   put 'm1: ', is-toepliz-matrix($m1);

   my $m2 = [ [1, 2, 3],
              [3, 2, 1],
            ];
   put 'm2: ', is-toepliz-matrix($m2);
}

sub is-toepliz-matrix ($m) {
   for 1 .. $m.end -> $i {
      my ($r0, $r1) = $m[$i - 1, $i];
      return False unless all($r0[0 .. *-2] «==» $r1[1 .. *-1]);
   }
   return True;
}
```

The two parts are taken as slices; they are compared by applying the
comparison operator to each pair of corresponding items with the `«==»`
hyperoperator, then making sure that `all` comparisons are true.

The [Perl][] alternative is a bit *lower level*, with an explicit loop to
compare individual items. It's less compact, but arguably more efficient as
it allows bailing out as soon as a difference is spotted (in the [Raku][]
alternative above all comparisons are done in a pair or rows):

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my $m1 = [ [4, 3, 2, 1],
           [5, 4, 3, 2],
           [6, 5, 4, 3],
         ];
say 'm1: ', is_toepliz_matrix($m1) ? 'true' : 'false';

my $m2 = [ [1, 2, 3],
           [3, 2, 1],
         ];
say 'm2: ', is_toepliz_matrix($m2) ? 'true' : 'false';


sub is_toepliz_matrix ($m) {
   for my $i (1 .. $m->$#*) {
      my ($r0, $r1) = $m->@[$i - 1, $i];
      my $end = $r1->$#*;
      return 0 if $end != $r0->$#*;
      for my $j (1 .. $end) {
         return 0 if $r0->[$j - 1] != $r1->[$j];
      }
   }
   return 1;
}
```

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#211]: https://theweeklychallenge.org/blog/perl-weekly-challenge-211/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-211/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
