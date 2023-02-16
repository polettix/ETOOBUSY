---
title: PWC204 - Reshape Matrix
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#204][].
> Enjoy!

# The challenge

> You are given a matrix (m x n) and two integers (r) and (c).
>
> Write a script to reshape the given matrix in form (r x c) with the
> original value in the given matrix. If you can’t reshape print 0.
>
> **Example 1**
>
>     Input: [ 1 2 ]
>            [ 3 4 ]
>
>            $matrix = [ [ 1, 2 ], [ 3, 4 ] ]
>            $r = 1
>            $c = 4
>
>     Output: [ 1 2 3 4 ]
>
> **Example 2**
>
>     Input: [ 1 2 3 ]
>            [ 4 5 6 ]
>
>            $matrix = [ [ 1, 2, 3 ] , [ 4, 5, 6 ] ]
>            $r = 3
>            $c = 2
>
>     Output: [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ]
>
>             [ 1 2 ]
>             [ 3 4 ]
>             [ 5 6 ]
>
> **Example 3**
>
>     Input: [ 1 2 ]
>
>            $matrix = [ [ 1, 2 ] ]
>            $r = 3
>            $c = 2
>
>     Output: 0

# The questions

Is an empty matrix allowed? How is it shaped (e.g. does it even have a
row, but empty)?

Should we check that the input matrix does indeeded contain all elements
by just looking at its rows and the number of columns in the first row?

# The solution

The basic idea I wanted to implement is to do a few pre-checks, but then
turn the input matrix into a stream of elements that I can then take row
by row. For me, *stream of elements* basically means iterator, so here's
my [Perl][] take:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Data::Dumper;

my $reshaped = reshape_matrix([ [ 1 .. 3], [ 4 .. 6] ], 3, 2);
say $reshaped ? Dumper($reshaped) : 0;

sub reshape_matrix ($matrix, $r, $c) {
   my $needed = $r * $c;
   my $available = $matrix->@*;
   $available *= $matrix->[0]->@* if $available;
   return 0 if $needed != $available;

   my $it = elements_it($matrix);
   return [ map { [ map { $it->() } 1 .. $c ] } 1 .. $r ];
}

sub elements_it ($aoa) {
   my ($r, $c) = (0, 0);
   return sub {
      while ('necessary') {
         return if $r > $aoa->$#*;
         my $row = $aoa->[$r];
         if ($c > $row->$#*) {
            ++$r;
            $c = 0;
            next;
         }
         return $row->[$c++];
      }
   };
}
```

Turning this idea into [Raku][] leads to something quite interesting and
idiomatic:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my $reshaped = reshape-matrix([ [ 1 .. 3], [ 4 .. 6] ], 3, 2);
   put $reshaped ?? $reshaped.gist !! 0;
}

sub reshape-matrix ($matrix, $r, $c) {
   my $needed = $r * $c;
   my $available = $matrix.elems;
   $available *= $matrix[0].elems if $available;
   return Nil if $needed != $available;

   # https://stackoverflow.com/questions/41648119/how-can-i-completely-flatten-a-list-of-lists-of-lists/41649110#41649110
   return [$matrix[*;*].rotor($c)];
}
```

Instead of building an iterator, here we're leveraging [one of the hints
here][hints] to *flatten* the input matrix into a single sequence, then
use `rotor` (for the second time in a single weekly challenge, wow!) to
take rows out of it.

I wonder if I'll remember about the two-dimensional matrix flattening
trick `$matrix[*;*]` next time!

Cheers and stay safe!




[The Weekly Challenge]: https://theweeklychallenge.org/
[#204]: https://theweeklychallenge.org/blog/perl-weekly-challenge-204/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-204/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[hints]: https://stackoverflow.com/questions/41648119/how-can-i-completely-flatten-a-list-of-lists-of-lists/41649110#41649110
