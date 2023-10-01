---
title: PWC236 - Array Loops
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-01 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#236][].
> Enjoy!

# The challenge

> You are given an array of unique integers.
>
> Write a script to determine how many loops are in the given array.
>
>> To determine a loop: Start at an index and take the number at
>> array[index] and then proceed to that index and continue this until
>> you end up at the starting index.
>
> **Example 1**
>
>     Input: @ints = (4,6,3,8,15,0,13,18,7,16,14,19,17,5,11,1,12,2,9,10)
>     Output: 3
>
>     To determine the 1st loop, start at index 0,
>     the number at that index is 4, proceed to index 4,
>     the number at that index is 15, proceed to index 15
>     and so on until you're back at index 0.
>
>     Loops are as below:
>     [4 15 1 6 13 5 0]
>     [3 8 7 18 9 16 12 17 2]
>     [14 11 19 10]
>
> **Example 2**
>
>     Input: @ints = (0,1,13,7,6,8,10,11,2,14,16,4,12,9,17,5,3,18,15,19)
>     Output: 6
>
>     Loops are as below:
>     [0]
>     [1]
>     [13 9 14 17 18 15 5 8 2]
>     [7 11 4 6 10 16 3]
>     [12]
>     [19]
>
> **Example 3**
>
>     Input: @ints = (9,8,3,11,5,7,13,19,12,4,14,10,18,2,16,1,0,15,6,17)
>     Output: 1
>
>     Loop is as below:
>     [9 4 5 7 19 17 15 1 8 12 18 6 13 2 3 11 10 14 16 0]

# The questions

Well well well... we're going to take a **huge** assumption here, that
is the *integer values* will always be *valid* indexes in the input
array. *OK with that?!?*

Additionally, we will consider a loop also a situation in which an
element points to itself, *OK?* This is within the rules and within the
examples, so this question is probably not needed but better be clear.

# The solution

The assumption allows us to rule out arrays like `(100)` where there is
no loop at all, or `(100,2,1)` where there is one with two elements
only.

This said, every input array is then a permutation of all (and only) the
indexes of the array itself, i.e. integers from $0$ up to $n - 1$, where
$n$ is the number of elements in the array. Every element in the array
is part of a chain; I have a wonderful demonstration of this fact, but
the margins of this blog post are too tight to write it down so trust me
because you trusted Fermat for about 350 years and he was eventually
right.

At this point, we just have to calculate how many of them are there,
ranging from 1 (just a big chain) up to $n$ (every element just points
to itself). This is a partition of the initial set and the perfect
candidate for the [Union-Find][] algorithm, where we only need to know
how many unified sets we are left after considering all inputs.

As a matter of fact, [cglib-perl][] indeed has a [UnionFind.pm][]
implementation, that we are happy to leverage here:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say array_loops(map { split m{\D+}mxs } @ARGV);

sub array_loops (@ints) {
   my $uf = UnionFind->new(components => [0 .. $#ints]);
   $uf->union($_, $ints[$_]) for 0 .. $#ints;
   return $uf->count;
}


package UnionFind; # Sedgewick & Wayne, Algorithms 4th ed, §1.5
use strict;

sub add;    # see below
sub connected { return $_[0]->find($_[1]) eq $_[0]->find($_[2]) }
sub count     { return $_[0]{count} }
sub find      { return $_[0]{cs}{$_[0]->find_id($_[1])}[1] }
sub find_id;    # see below
sub new;        # see below
sub union;      # see below

sub add {
   my $id = $_[0]{id_of}->($_[1]);
   return $_[0] if $_[0]{cs}{$id};
   $_[0]{cs}{$id} = [$id, $_[1], 1];
   $_[0]{count}++;
   return $_[0];
}

sub find_id {
   my $r = my $i = $_[0]{id_of}->($_[1]);
   return unless exists $_[0]{cs}{$r};
   $r = $_[0]{cs}{$r}[0] while $r ne $_[0]{cs}{$r}[0];
   ($i, $_[0]{cs}{$i}) = ($_[0]{cs}{$i}[0], $_[0]{cs}{$r}) while $i ne $r;
   return $r;
} ## end sub find_id

sub new {
   my ($pk, %args) = (@_ > 0 && ref($_[1])) ? ($_[0], %{$_[1]}) : @_;
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my $self = bless {id_of => $id_of, count => 0}, $pk;
   $self->add($_) for @{$args{components} || []};
   return $self;
} ## end sub new

sub union {
   my ($i, $j) = ($_[0]->find_id($_[1]), $_[0]->find_id($_[2]));
   return $_[0] if $i eq $j;
   ($i, $j) = ($j, $i) if $_[0]{cs}{$i}[2] < $_[0]{cs}{$j}[2];   # i -> max
   $_[0]{cs}{$i}[2] += $_[0]{cs}{$j}[2];
   $_[0]{cs}{$j} = $_[0]{cs}{$i};
   $_[0]{count}--;
   return $_[0];
} ## end sub union
```

Alas, [cglib-raku][] did not have the corresponding implementation... up
to this challenge, which was the perfect occasion to add it as
[UnionFind.rakumod][]. So here we are with the [Raku][] solution too:

```raku
#!/usr/bin/env raku
use v6;

class UnionFind {
   has $.count = 0;
   has %!cs;
   has &!id-of is built;
   has @!items;

   method add ($item) {
      my $id = &!id-of($item);
      return self if %!cs{$id};
      %!cs{$id} = [ $id, $item, 1 ];
      $!count++;
      return self;
   }

   method find ($item) { %!cs{self.find-id($item)}[1] }

   method find-id ($item) {
      my $r = my $i = &!id-of($item);
      return unless %!cs{$r}:exists;
      $r = %!cs{$r}[0] while $r ne %!cs{$r}[0];
      ($i, %!cs{$i}) = (%!cs{$i}[0], %!cs{$r}) while $i ne $r;
      return $r;
   }

   method new (:&id-of = -> $n { $n.Str }, :@components) {
      my $obj = self.bless(:&id-of);
      $obj.add($_) for @components;
      return $obj;
   }

   method union ($p, $q) {
      my ($i, $j) = self.find-id($p), self.find-id($q);
      return self if $i eq $j;
      ($i, $j) = $j, $i if %!cs{$i}[2] < %!cs{$j}[2]; # i -> max
      %!cs{$i}[2] += %!cs{$j}[2];
      %!cs{$j} = %!cs{$i};
      $!count--;
      return self;
   }
}

sub MAIN (*@indexes) {
   @indexes = @indexes.map({.split(/\D+/)}).flat;
   my $uf = UnionFind.new(components => [ ^@indexes ]);
   for @indexes.kv -> $i, $j { $uf.union($i, $j) }
   put $uf.count;
}
```

Some might argue that re-implementing stuff in [Raku][] could be a waste
of time, but I beg to differ. I still have to learn to play with the
object model (there's a **huge** regression in how I'm providing a
constructor), but I got to better understand what `bless` does *and* I
uncovered a bug in the [Perl][] implementation too. Win-win, yay!

That's all for this post, see you soon and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#236]: https://theweeklychallenge.org/blog/perl-weekly-challenge-236/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-236/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[cglib-perl]: https://github.com/polettix/cglib-perl
[UnionFind.pm]: https://github.com/polettix/cglib-perl/blob/master/UnionFind.pm
[cglib-raku]: https://github.com/polettix/cglib-raku
[UnionFind.rakumod]: https://github.com/polettix/cglib-raku/blob/main/UnionFind.rakumod
[Union-Find]: https://algs4.cs.princeton.edu/15uf/
