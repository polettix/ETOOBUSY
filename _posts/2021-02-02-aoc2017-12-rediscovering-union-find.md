---
title: AoC 2017/12 - Rediscovering Union-Find
type: post
tags: [ advent of code, algorithm, perl, cglib ]
comment: true
date: 2021-02-02 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I remembered about [Union-Find][]. The incredible thing is that I
> *remembered* something.

While wast**AHEM**investing 🙄 time with the puzzles in the [2017
edition][aoc2017] of [Advent of Code][], I eventually arrived at [day
12][aoc2017-12].

You might be wondering *so what?!?* at this point. If you're Italian, you might
be even thinking of [Grande Capo Estiqaatsi][].

The puzzle eventually boils down to having an [Undirected Graph][] and
asking a few things about it:

- part 1: how many nodes are connected to the node whose identifier is
  `0`?
- part 2: how many disjoint sets of nodes are there?

Luckily for me, I took [Coursera][]'s [Algorithms, Part I][] and
*incredibly* remembered about the very first lesson about
[Union-Find][], which is *perfectly tailored* for this puzzle.

With some more effort of memory (read: *reimplemented the thing before
remembering about it*), I also re-discovered my implementation in
[Perl][], of course in [cglib][], available at [UnionFind.pm][]:

```perl
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
   $_[0]{cs}{$i}[2] += $_[0]{cs}{$i}[2];
   $_[0]{cs}{$j} = $_[0]{cs}{$i};
   $_[0]{count}--;
   return $_[0];
} ## end sub union

1;
```

I am totally ashamed by the lack of documentation... although I didn't
have a hard time figuring out how to use it:

```perl
# Input array @neighbors is an AoA; each sub-array holds a list of
# neighbors for the identifier of the sub-array itself.
sub solution (@neighbors) {
   my $uf = UnionFind->new(components => [0 .. $#neighbors]);
   $uf->union($_->@*) for map {
      my $id = $_;
      map { [$id, $_] } $neighbors[$id]->@*;
   } 0 .. $#neighbors;
   my $conn0 = grep { $uf->connected(0, $_) } 0 .. $#neighbors;
   return (part_1 => $conn0, part_2 => $uf->count);
}
```

Well... enough for today, stay safe!

[Advent of Code]: https://adventofcode.com/
[aoc2017]: https://adventofcode.com/2017/
[aoc2017-12]: https://adventofcode.com/2017/day/12
[Union-Find]: https://algs4.cs.princeton.edu/15uf/
[Grande Capo Estiqaatsi]: https://www.raiplayradio.it/audio/2019/01/Grande-Capo-Estiqaatsi-ff469802-99e3-4194-aa71-6c65602e73f0.html
[Undirected Graph]: https://algs4.cs.princeton.edu/41graph/
[Coursera]: https://www.coursera.org/
[Algorithms, Part I]: https://www.coursera.org/learn/algorithms-part1/home/welcome
[cglib]: https://github.com/polettix/cglib-perl
[Perl]: https://www.perl.org/
[UnionFind.pm]: https://github.com/polettix/cglib-perl/blob/master/UnionFind.pm
