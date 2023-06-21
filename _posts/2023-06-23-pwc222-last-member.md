---
title: PWC222 - Last Member
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-23 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#222][].
> Enjoy!

# The challenge

> You are given an array of positive integers, @ints.
>
> Write a script to find the last member if found otherwise return 0. Each
> turn pick 2 biggest members (x, y) then decide based on the following
> conditions, continue this until you are left with 1 member or none.
>
>> a) if x == y then remove both members
>
>> b) if x != y then remove both members and add new member (y-x)
>
> **Example 1:**
>
>     Input: @ints = (2, 7, 4, 1, 8, 1)
>     Output: 1
>     
>     Step 1: pick 7 and 8, we remove both and add new member 1 => (2, 4, 1, 1, 1).
>     Step 2: pick 2 and 4, we remove both and add new member 2 => (2, 1, 1, 1).
>     Step 3: pick 2 and 1, we remove both and add new member 1 => (1, 1, 1).
>     Step 4: pick 1 and 1, we remove both => (1).
>
> **Example 2:**
>
>     Input: @ints = (1)
>     Output: 1
>
> **Example 3:**
>
>     Input: @ints = (1, 1)
>     Output: 0
>     
>     Step 1: pick 1 and 1, we remove both and we left with none.

# The questions

Uh this was so underspecified.

After the correction we are still left with extracting the two top numbers,
*but* it's not clear from the text whether `x` should be the bigger or the
other one. Turns out from the examples that it's the lower of the two,
still...

# The solution

As we are required to extract the top two values from the bunch and
*possibly* add a new element to it, this seems a good candidate for using an
optimized data structure like a [Priority Queue][] based on a *Binary Heap*, which has the following complexity:

- insert a new value: $O(log(n))$, which is better than a linear complexity
  that we would have by managing a sorted array, so *yay*!
- Build from a list: $O(n \cdot log(n))$, as an extension of inserting a new
  value above. This is the same as sorting the list so no gain but no loss
  too.
- Extract the top value: $O(log(n))$, which is *worse* than the $O(1)$ that
  we would have with a sorted array.

All in all we might gain or lose depending on the inputs.

In the worst case, all values will always be different from one another,
which means that every pair yields a new value and we will have $n - 1$
insertions, that means $O(n \cdot log(n))$ for a priority queue and $O(n^2)$
for a sorted array. Assuming a single pair of different values, we are left
with $O(log(n))$ for the priority queue and $O(n)$ for the sorted array. If
we define the average case as having $\frac{n}{2}$ insertions, we still end
up with the same complexities as the worst case because the insertions are
linear with the inputs.

Extractions go the other way around; there will be at least $n$ of them,
with a worst case that is *about* $2n$; anyway, linear with the input. So
the complexity is $O(n \cdot log(n))$ for a priority queue and $O(n)$ for a
sorted array. The average case, as defined above, has the same complexity.

So if we anticipate inputs with very few insertions... a sorted array wins
because the number of insertions will be low. This is what happens if the
values are low and/or mostly similar. On the other hand, the average case
with *generic* values seems to favor the use of a priority queue, so we will
go for it.

Good for us that we have an implementation in [cglib-perl][] and
[cglib-raku][], so let's go!

[Perl][] first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say last_member(@ARGV);

sub last_member (@list) {
   my $pq = BasicPriorityQueue->new(
      items  => \@list,
      before => sub { $_[0] > $_[1] }
   );
   while ($pq->size > 1) {
      my $x = $pq->dequeue;
      my $delta = $x - $pq->dequeue;
      $pq->enqueue($delta) if $delta;
   }
   return $pq->is_empty ? 0 : $pq->dequeue;
} ## end sub last_member

package BasicPriorityQueue;
use strict;    # Adapted from https://algs4.cs.princeton.edu/24pq/

sub dequeue;   # see below
sub enqueue;   # see below
sub is_empty { return !$#{$_[0]{items}} }
sub top      { return $#{$_[0]{items}} ? $_[0]{items}[1] : () }
sub new;       # see below
sub size { return $#{$_[0]{items}} }

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
   my $self    = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
   $self->{before} ||= sub { $_[0] < $_[1] };
   (my $is, $self->{items}) = ($self->{items} || [], ['-']);
   $self->enqueue($_) for @$is;
   return $self;
} ## end sub new

1;
```

The [Raku][] version is an almost direct translation:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@list) { put last-member(@list) }

sub last-member (Array(Int()) $list) {
   class BasicPriorityQueue { ... }
   my $pq = BasicPriorityQueue.new(
      items => $list,
      before => {$^a > $^b},
   );
   while ($pq.size() > 1) {
      my $x = $pq.dequeue;
      my $delta = $x - $pq.dequeue;
      $pq.enqueue($delta) if $delta;
   }
   return $pq.is-empty ?? 0 !! $pq.dequeue();
}

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
```

With all that... stay safe and *partially ordered*!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#222]: https://theweeklychallenge.org/blog/perl-weekly-challenge-222/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-222/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Priority Queue]: https://algs4.cs.princeton.edu/24pq/
[cglib-perl]: https://github.com/polettix/cglib-perl/
[cglib-raku]: https://github.com/polettix/cglib-raku/
