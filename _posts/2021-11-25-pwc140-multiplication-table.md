---
title: PWC140 - Multiplication Table
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-11-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#140][].
> Enjoy!

# The challenge

> You are given 3 positive integers, `$i`, `$j` and `$k`.
>
> Write a script to print the `$k`th element in the sorted
> multiplication table of `$i` and `$j`.
>
> **Example 1**
>
>     Input: $i = 2; $j = 3; $k = 4
>     Output: 3
>
>     Since the multiplication of 2 x 3 is as below:
>
>         1 2 3
>         2 4 6
>
>     The sorted multiplication table:
>
>         1 2 2 3 4 6
>
>     Now the 4th element in the table is "3".
>
> **Example 2**
>
>     Input: $i = 3; $j = 3; $k = 6
>     Output: 4
>
>     Since the multiplication of 3 x 3 is as below:
>
>         1 2 3
>         2 4 6
>         3 6 9
>
>     The sorted multiplication table:
>
>         1 2 2 3 3 4 6 6 9
>
>     Now the 6th element in the table is "4".

# The questions

There's no formal definition of what a multiplication *table* of `$i`
and `$j` is, though the examples seem to imply a table with columns
ranging from 1 to `$j` and rows ranging from 1 to `$i`, filled with
multiplication of row and column numbers, so I'll stick with this.

The problem is also vague about the upper limits for the input values...
we'll assume they can be *moderately* big (nothing too big though!).

# The solution

[Perl][] goes first this time, where we explore two alternatives: *brute
force* (for numbers up to 2000) and *priority queue*.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my ($i, $j, $k) = @ARGV;
$i //= 2;
$j //= 3;
$k //= 4;

say multiplication_table_pq($i, $j, $k);
say multiplication_table_bf($i, $j, $k) if $k < 2000;

sub multiplication_table_bf ($i, $j, $k) {
   my @prods;
   for my $I (1 .. min($i, $k)) {
      for my $J (1 .. min($j, $k)) {
         push @prods, $I * $J;
      }
   }
   @prods = sort {$a <=> $b} @prods;
   return $prods[$k - 1];
}

sub max ($x, $y) { $x > $y ? $x : $y }
sub min ($x, $y) { $x < $y ? $x : $y }

sub multiplication_table_pq ($i, $j, $k) {
   die "out of range (too low!)\n" if $k == 0;
   die "out of range (too high!)\n" if $k > $i * $j;

   return $k if $k <= 2 || $k == $i * $j;
   return max($i * ($j - 1), ($i - 1) * $j) if $k == $i * $j - 1;

   my $pq = BPQ->new(
      before => sub ($x, $y) { $x->[0] < $y->[0] },
      items  => [[1, 1, 1]],
   );
   my %seen = ('1.1' => 1); # just to give the gist of it...
   while ($k > 1) {
      my ($p, $I, $J) = $pq->dequeue->@*;
      for my $deltas ([0, 1], [1, 0]) {
         my $I_ = $I + $deltas->[0];
         next if $I_ > $i;
         my $J_ = $J + $deltas->[1];
         next if $J_ > $j;
         next if $seen{"$I_.$J_"}++;
         $pq->enqueue([$I_ * $J_, $I_, $J_]);
      }
      --$k;
   }
   my ($result) = $pq->dequeue->@*;
   return $result;
}

package BPQ;
sub dequeue;    # see below
sub enqueue;    # see below
sub is_empty    { return !$#{$_[0]{items}} }
sub top         { return $#{$_[0]{items}} ? $_[0]{items}[1] : () }
sub new;        # see below
sub size        { return $#{$_[0]{items}} }

sub dequeue {    # includes "sink"
   my ($is, $before, $k) = (@{$_[0]}{qw< items before >}, 1);
   return unless $#$is;
   my $r = ($#$is > 1) ? (splice @$is, 1, 1, pop @$is) : pop @$is;
   while ((my $j = $k * 2) <= $#$is) {
      ++$j if ($j < $#$is) && $before->($is->[$j + 1], $is->[$j]);
      last if $before->($is->[$k], $is->[$j]);
      (@{$is}[$j, $k], $k) = (@{$is}[$k, $j], $j);
   }
   return $r;
} ## end sub dequeue

sub enqueue {    # includes "swim"
   my ($is, $before) = (@{$_[0]}{qw< items before >});
   push @$is, $_[1];
   my $k = $#$is;
   (@{$is}[$k / 2, $k], $k) = (@{$is}[$k, $k / 2], int($k / 2))
     while ($k > 1) && $before->($is->[$k], $is->[$k / 2]);
} ## end sub enqueue

sub new {
   my $package = shift;
   my $self = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
   $self->{before} ||= sub { $_[0] < $_[1] };
   (my $is, $self->{items}) = ($self->{items} || [], ['-']);
   $self->enqueue($_) for @$is;
   return $self;
} ## end sub new
1;
```

The brute force approach does what it says: computes the full table,
sorts all the elements and takes the $k$th.

This approach does not scale well and can easily suck up all the memory.
There MUST be lots of solutions, personally I thought to use a *priority
queue* to make sure that I count elements in order. Each element that is
extracted potentially gives raise to two additional "neighbors",
depending on their existence!.

[Raku][] is a translation, leveraging [cglib-raku][] with its newest
patch, applied after discovering a bug with this specific case:

```raku
#!/usr/bin/env raku
use v6;

class BasicPriorityQueue {
   has @!items;
   has &!before;

   submethod BUILD (:&!before = {$^a < $^b}, :@items) {
      @!items = '-';
      self.enqueue($_) for @items;
   }

   #method dequeue ($obj) <-- see below
   method elems { @!items.end }
   # method enqueue ($obj) <-- see below
   method is-empty { @!items.elems == 1 }
   method size  { @!items.end }
   method top { @!items.end ?? @!items[1] !! Any }

   method dequeue () { # includes "sink"
      return unless @!items.end;
      my $r = @!items.pop;
      ($r, @!items[1]) = (@!items[1], $r) if @!items.end >= 1;
      my $k = 1;
      while (my $j = $k * 2) <= @!items.end {
         ++$j if $j < @!items.end && &!before(@!items[$j + 1], @!items[$j]);
         last if &!before(@!items[$k], @!items[$j]);
         (@!items[$j, $k], $k) = (|@!items[$k, $j], $j);
      }
      return $r;
   }

   method enqueue ($obj) { # includes "swim"
      @!items.push: $obj;
      my $k = @!items.end;
      (@!items[$k/2, $k], $k) = (|@!items[$k, $k/2], ($k/2).Int)
         while $k > 1 && &!before(@!items[$k], @!items[$k/2]);
      return self;
   }
}

sub MAIN (Int $i  = 2, Int $j = 3, Int $k = 4) {
   put multiplication-table($i, $j, $k);
}

sub multiplication-table (Int $i, Int $j, Int $k is copy) {
   die "out of range (too low!)\n" if $k == 0;
   die "out of range (too high!)\n" if $k > $i * $j;

   return $k if $k <= 2 || $k == $i * $j;
   return max($i * ($j - 1), ($i - 1) * $j) if $k == $i * $j - 1;

   my $pq = BasicPriorityQueue.new(
      items  => [[1, 1, 1],],
      before => { $^a[0] < $^b[0] },
   );
   my %seen = '1.1' => 1;
   while ($k > 1) {
      my $item = $pq.dequeue;
      my ($p, $I, $J) = $item.Slip;
      for [0, 1], [1, 0] -> $deltas {
         my $I_ = $I + $deltas[0];
         next if $I_ > $i;
         my $J_ = $J + $deltas[1];
         next if $J_ > $j;
         next if %seen{"$I_.$J_"}++;
         $pq.enqueue([$I_ * $J_, $I_, $J_]);
      }
      --$k;
   }
   my ($result) = $pq.dequeue;
   return $result;
}
```

Stay safe!!!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#140]: https://theweeklychallenge.org/blog/perl-weekly-challenge-140/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-140/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[cglib-perl]: https://github.com/polettix/cglib-perl
[cglib-raku]: https://github.com/polettix/cglib-raku
