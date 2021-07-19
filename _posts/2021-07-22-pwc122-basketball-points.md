---
title: PWC122 - Basketball Points
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#122][].
> Enjoy!

# The challenge

> You are given a score `$S`.
>
> You can win basketball points e.g. 1 point, 2 points and 3 points.
>
> Write a script to find out the different ways you can score `$S`.
>
> **Example**
>
>     Input: $S = 4
>     Output: 1 1 1 1
>             1 1 2
>             1 2 1
>             1 3
>             2 1 1
>             2 2
>             3 1
>     
>     Input: $S = 5
>     Output: 1 1 1 1 1
>             1 1 1 2
>             1 1 2 1
>             1 1 3
>             1 2 1 1
>             1 2 2
>             1 3 1
>             2 1 1 1
>             2 1 2
>             2 2 1
>             2 3
>             3 1 1
>             3 2

# The questions

One question is how much the order of scoring matters. Looking at the
examples, it seems that it does indeed.

We will also assume that we can emit the sequences in whatever order,
but without repeating any of them.

# The solution

This time I'll start with [Perl][], because I'm reusing *a lot* of stuff
from the past.

First of all, we will reuse `int_sums_operator` from [All positive
integer sums, as iterator][]. This will give us all ways of partitioning
the input `$S` into integers, with a limit of taking no more than 3
items per time (which corresponds to scoring 3 points).

This function, though, gives us only *completely distinct* sequences. In
other terms, sequence `2 1 1` is the same as `1 2 1` and `1 1 2`. To
cope with this, we look through all *permutations* of the generated
sequence, making sure to filter out duplicates. The permutations will be
generated using `permutations_iterator` from [Iterator-based
implementation of Permutations][].

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub int_sums_iterator ($N, $max = undef) {
   if ($N < 1) {
      my @retvals = ([]);
      return sub { shift @retvals };
   }
   $max //= $N;
   my $first = $N < $max ? $N : $max;
   my $rit   = undef;
   return sub {
      my @retval;
      while ($first > 0) {
         $rit //= int_sums_iterator($N - $first, $first);
         if (my $rest = $rit->()) {
            return [$first, $rest->@*];
         }
         ($first, $rit) = ($first - 1, undef);
      }
      return;
   }
}

sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $items = $args{items} || die "invalid or missing parameter 'items'";
   my $filter = $args{filter} || sub { wantarray ? @_ : [@_] };
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub {
      if (! defined $sp) { $sp = 0 }
      else {
         while ($sp < @indexes) {
            if ($stack[$sp] < $sp) {
               my $other = $sp % 2 ? $stack[$sp] : 0;
               @indexes[$sp, $other] = @indexes[$other, $sp];
               $stack[$sp]++;
               $sp = 0;
               last;
            }
            else {
               $stack[$sp++] = 0;
            }
         }
      }
      return $filter->(@{$items}[@indexes]) if $sp < @indexes;
      return;
   }
}

sub basketball_points ($S) {
   my $isi = int_sums_iterator($S, 3);
   my ($pi, %seen);
   return sub {
      while ('necessary') {
         if (!$pi) {
            my $arrangement = $isi->() or return;
            $pi = permutations_iterator(items => $arrangement);
            %seen = ();
         }
         if (my @candidate = $pi->()) {
            my $key = join ' ', @candidate;
            return @candidate unless $seen{$key}++;
         }
         else {
            $pi = undef;
         }
      }
   };
}

my $total = shift || 5;
my $bp = basketball_points($total);
while (my @s = $bp->()) {
   say join ' ', @s;
}
```

[Raku][] now, which is pretty much a *translation* from [Perl][], except
that we are using [permutations][] from [Raku][] itself:

```raku
#!/usr/bin/env raku
use v6;

sub int-sums-iterator (Int:D $N, Int :$max) {
   if ($N < 1) {
      my @retvals = $[];
      return sub { @retvals.shift };
   }
   $max //= $N;
   my $first = $N < $max ?? $N !! $max;
   my $rit;
   return sub {
      my @retval;
      while ($first > 0) {
         $rit //= int-sums-iterator($N - $first, max => $first);
         if (defined(my $rest = $rit())) {
            return [$first, |$rest];
         }
         ($first, $rit) = ($first - 1);
      }
      return;
   }
}

sub basketball-points ($S) {
   my $isi = int-sums-iterator($S, max => 3);
   my (@ps, %seen);
   return sub {
      loop {
         if ! @ps {
            defined(my $cmb = $isi()) or return;
            @ps = permutations($cmb);
            %seen = ();
         }
         if @ps {
            my @candidate = @ps.shift;
            my $key = @candidate.join: ' ';
            return |@candidate unless %seen{$key}++;
         }
      }
   }
}

my $n = @*ARGS ?? @*ARGS[0] !! 5;
my $bp = basketball-points($n);
while $bp() -> $cmb {
   $cmb.join(' ').put;
}
```

I guess it's everything for this post!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#122]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-122/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-122/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[All positive integer sums, as iterator]: {{ '/2021/04/19/all-positive-integer-sums-iterator/' | prepend: site.baseurl }}
[Iterator-based implementation of Permutations]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[permutations]: https://docs.raku.org/routine/permutations
