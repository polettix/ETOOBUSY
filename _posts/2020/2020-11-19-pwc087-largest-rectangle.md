---
title: PWC087 - Largest Rectangle
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-19 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#087][].
> Enjoy!

# The challenge

> You are given matrix `m x n` with `0` and `1`. Write a script to find the
> largest rectangle containing only `1`. Print `0` if none found.

# The questions

One question for me would be: what about `1 x 1` rectangle? Why are they
forbidden? This bugs me a bit to be honest.

Another observation is that *largest* is not defined exactly here. Is it by
area? What about two rectangles with the same area?

# The solution

There must be a smart way to solve this challenge.

But it's late and I need to sleep... so I'll revert to *solution 0*, which
is to at least get the job done in lower programmer time, at the expense of
scalability. I'll settle with something that is most probably $O(n^4)$, more
or less.

## What's the idea

The idea is: starting from the biggest size of all, look for a matching
rectangle. If found... print it. Otherwise, go on.

Now, there's a couple of issues here:

- as said in the *questions*, we hereby declare that *largest* means
  *largest area*;
- we want to examine in decreasing area size in order to get all possible
  candidates, so we need to keep some kind of ordering of the candidates;
- we want to generate candidates as we exclude bigger ones, not pre-generate
  all of them beforehand.

One key insight here is that if, at a certain point, we examine a candidate
area size deriving from $m \cdot n$ rows times columns, then the two possible
further candidates that can spawn from it are $(m - 1) \cdot n$ and $m \cdot
(n - 1)$. This *does not* mean that either one will be the next in line,
just that they are the "best possible" further candidates that we can make
out of it.

This takes care of the last bullet, i.e. generating candidates as we need
more (if we find a match, we will not need further candidates). To check the
candidates in decreasing order, we will need to keep them somehow sorted.
This is a perfect job for a [Priority Queue][], in particular a *Max
Priority Queue*.

I knew that the time spent on the [Algorithms course][] was not wasted,
after all 😅

## Solution sketch

So let's go to the code!

```
 1 sub largest_rectangle ($M) {
 2    my $rows = $M->@* or return;
 3    my $cols = $M->[0]->@* or return;
 4    my $mpq = PriorityQueue->new(before => sub {$_[0]{size} > $_[1]{size}});
 5    $mpq->enqueue({rows => $rows, cols => $cols, size => $rows * $cols});
 6    my %have_done; # this avoids double searching the same rows x columns
 7    while (! $mpq->is_empty) {
 8       my ($rl, $cl) = $mpq->dequeue->@{qw< rows cols >};
 9       for my $rs (0 .. $rows - $rl) {
10          for my $cs (0 .. $cols - $cl) {
11             my @candidate = ($rs, $rl, $cs, $cl);
12             return \@candidate if is_full_rectangle($M, @candidate);
13          }
14       }
15 
16       # insert further candidates, if possible
17       for my $delta ([-1, 0], [0, -1]) {
18          my ($rn, $cn) = ($rl + $delta->[0], $cl + $delta->[1]);
19          next unless $rn * $cn > 1; # no 1x1 apparently!
20          if ($have_done{"$rn-$cn"}) {
21             delete $have_done{"$rn-$cn"}; # spare some memory...
22          }
23          else {
24             $have_done{"$rn-$cn"} = 1;
25             $mpq->enqueue({rows => $rn, cols => $cn, size => $rn * $cn});
26          }
27       }
28    }
29    return; # found nothing, apparently!
30 }
```

Lines 2 and 3 take care of some corner cases where the Matrix *does not
exist*. Nothing too fancy here.

Line 4 introduces our hero: the *Max Priority Queue*. The implementation is
taken verbatim from [PriorityQueue.pm][] in my [CodinGame library][cglib],
and we set the key `before` to a function that allows the code to figure out
what should come... *before*. In the case of a *Max Priority Queue*, higher
values of `size` have to come before lower ones.

The first candidate in the queue is an attempt to check whether the *whole*
input matrix complies with the requirement (line 5). This is, of course, the
maximum we can test out of `$M`.

The loop in lines 7 through 28 checks out all those sizes, in descending
order (thanks to the priority queue). Line 8 takes the next candidate in
line, and all its possible overlappings onto `$M` are tried out (lines 9
through 14). If any of these placements is a match... we return it straight
away (line 12), otherwise we move on.

Hence, line 17 is only reached if nothing has been found so far; it's time
to add more candidates. As discussed, we check one less row and same
columns, and one less column and same rows (line 17).

Candidates whose size is too small are discarded (line 19). It beats me why
a $1 \cdot 1$ rectangle cannot be considered, but apparently it's not
allowed by the examples.

Note one thing: if we start from a $3 \cdot 3$ matrix, there are two ways to
land on $2 \cdot 2$ candidate size: arriving from $3 \cdot 2$ and arriving
from $2 \cdot 3$. To avoid repeating tests twice, then, we keep a guard in
hash `%have_done` and skip inserting the candidate if it is already present
(line 20).

If we end up testing everything... and not finding a solution, we eventually
reach line 29 and return... nothing.

## The whole code

As usual, if you want to take a look at all of it... enjoy!

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use autodie;

main(shift);

sub main ($filename = undef) {
   my $fh =
       !defined $filename ? \*DATA
     : $filename eq '-'   ? \*STDIN
     :                      do { open my $fh, '<', $filename; $fh };
   my @matrix;
   while (<$fh>) {
      my @row = split m{\s+};
      push @matrix, \@row;
      shift @row;    # "["
      pop @row;      # "]"
   } ## end while (<$fh>)
   if (my $lr = largest_rectangle(\@matrix)) {
      my ($rs, $rl, $cs, $cl) = $lr->@*;
      local $, = ' ';
      say {*STDOUT} '[', $matrix[$_]->@[$cs .. $cs + $cl - 1], ']'
        for $rs .. $rs + $rl - 1;
   } ## end if (my $lr = largest_rectangle...)
   else {
      say {*STDOUT} 0;
   }
} ## end sub main ($filename = undef)

sub largest_rectangle ($M) {
   my $rows = $M->@* or return;
   my $cols = $M->[0]->@* or return;
   my $mpq = PriorityQueue->new(before => sub {$_[0]{size} > $_[1]{size}});
   $mpq->enqueue({rows => $rows, cols => $cols, size => $rows * $cols});
   my %have_done; # this avoids double searching the same rows x columns
   while (! $mpq->is_empty) {
      my ($rl, $cl) = $mpq->dequeue->@{qw< rows cols >};
      for my $rs (0 .. $rows - $rl) {
         for my $cs (0 .. $cols - $cl) {
            my @candidate = ($rs, $rl, $cs, $cl);
            return \@candidate if is_full_rectangle($M, @candidate);
         }
      }

      # insert further candidates, if possible
      for my $delta ([-1, 0], [0, -1]) {
         my ($rn, $cn) = ($rl + $delta->[0], $cl + $delta->[1]);
         next unless $rn * $cn > 1; # no 1x1 apparently!
         if ($have_done{"$rn-$cn"}) {
            delete $have_done{"$rn-$cn"}; # spare some memory...
         }
         else {
            $have_done{"$rn-$cn"} = 1;
            $mpq->enqueue({rows => $rn, cols => $cn, size => $rn * $cn});
         }
      }
   }
   return; # found nothing, apparently!
}

sub is_full_rectangle ($M, $rs, $rl, $cs, $cl) {
   for my $r ($rs .. $rs + $rl - 1) {
      my $Mr = $M->[$r];
      for my $c ($cs .. $cs + $cl - 1) {
         return unless $Mr->[$c];
      }
   }
   return 1;
}

package PriorityQueue;  # Adapted from https://algs4.cs.princeton.edu/24pq/
use strict;

sub contains    { return $_[0]->contains_id($_[0]{id_of}->($_[1])) }
sub contains_id { return exists $_[0]{item_of}{$_[1]} }
sub is_empty    { return !$#{$_[0]{items}} }
sub item_of { exists($_[0]{item_of}{$_[1]}) ? $_[0]{item_of}{$_[1]} : () }
sub new;                # see below
sub dequeue { return $_[0]->_remove_kth(1) }
sub enqueue;                # see below
sub remove    { return $_[0]->remove_id($_[0]{id_of}->($_[1])) }
sub remove_id { return $_[0]->_remove_kth($_[0]{pos_of}{$_[1]}) }
sub size      { return $#{$_[0]{items}} }
sub top       { return $_[0]->size ? $_[0]{items}[1] : () }
sub top_id    { return $_[0]->size ? $_[0]{id_of}->($_[0]{items}[1]) : () }

sub new {
   my $package = shift;
   my $self = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
   $self->{before} ||= sub { return $_[0] < $_[1] };
   $self->{id_of} ||= sub { return ref($_[0]) ? "$_[0]" : $_[0] };
   my $items = $self->{items} || [];
   @{$self}{qw< items pos_of item_of >} = (['-'], {}, {});
   $self->enqueue($_) for @$items;
   return $self;
} ## end sub new

sub enqueue {    # insert + update in one... DWIM
   my ($is, $id) = ($_[0]{items}, $_[0]{id_of}->($_[1]));
   $_[0]{item_of}{$id} = $_[1];    # keep track of this item
   my $k = $_[0]{pos_of}{$id} ||= do { push @$is, $_[1]; $#$is };
   $_[0]->_adjust($k);
   return $id;
} ## end sub enqueue

sub _adjust {                      # assumption: $k <= $#$is
   my ($is, $before, $self, $k) = (@{$_[0]}{qw< items before >}, @_);
   $k = $self->_swap(int($k / 2), $k)
     while ($k > 1) && $before->($is->[$k], $is->[$k / 2]);
   while ((my $j = $k * 2) <= $#$is) {
      ++$j if ($j < $#$is) && $before->($is->[$j + 1], $is->[$j]);
      last if $before->($is->[$k], $is->[$j]);    # parent is OK
      $k = $self->_swap($j, $k);
   }
   return $self;
} ## end sub _adjust

sub _remove_kth {
   my ($is, $self, $k) = ($_[0]{items}, @_);
   die 'no such item' if (!defined $k) || ($k <= 0) || ($k > $#$is);
   $self->_swap($k, $#$is);
   my $r = CORE::pop @$is;
   $self->_adjust($k) if $k <= $#$is;    # no adjust for last element
   my $id = $self->{id_of}->($r);
   delete $self->{$_}{$id} for qw< item_of pos_of >;
   return $r;
} ## end sub _remove_kth

sub _swap {
   my ($self,  $i,      $j)     = @_;
   my ($items, $pos_of, $id_of) = @{$self}{qw< items pos_of id_of >};
   my ($I, $J) = @{$items}[$i, $j] = @{$items}[$j, $i];
   @{$pos_of}{($id_of->($I), $id_of->($J))} = ($i, $j);
   return $i;
} ## end sub _swap

1;

package main;

__DATA__
[ 0 0 0 1 0 0 ]
[ 1 1 1 0 0 0 ]
[ 0 0 1 0 0 1 ]
[ 1 1 1 1 1 0 ]
[ 1 1 1 1 1 0 ]
```

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#087]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-087/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-087/#TASK2
[Perl]: https://www.perl.org/
[Priority Queue]: https://algs4.cs.princeton.edu/24pq/
[Algorithms course]: https://www.coursera.org/learn/algorithms-part1
[cglib]: https://github.com/polettix/cglib-perl
[PriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/PriorityQueue.pm
