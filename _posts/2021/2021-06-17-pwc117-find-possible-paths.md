---
title: PWC117 - Find Possible Paths
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-17 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#117][].
> Enjoy!

# The challenge

> You are given size of a triangle.
> 
> Write a script to find all possible paths from top to the bottom right
> corner.
> 
> In each step, we can either move horizontally to the right (H), or move
> downwards to the left (L) or right (R).
> 
> > BONUS: Try if it can handle triangle of size 10 or 20.
>
> **Example 1:**
> 
>     Input: $N = 2
>     
>                S
>               / \
>              / _ \
>             /\   /\
>            /__\ /__\ E
>     
>     Output: RR, LHR, LHLH, LLHH, RLH, LRH
> 
> **Example 2:**
> 
>     Input: $N = 1
> 
>             S
>            / \
>           / _ \ E
> 
>     Output: R, LH

# The questions

Just to be very nitpicky, the *size of a triangle* is a positive integer size.
This becomes very evident very quickly, so yes it's nitpicking.

Kudos for the bonus challenge of handling triangles of size 10 or 20.

I'm assuing that any order will do.

I'm also assuming that it's fine to print out each sequence on its own line,
instead of on a single line with comma separation. This is particularly
important as `$N` grows...

# The solution

Buckle up, there will be a lot to discuss!

## The initial solution

I started with a solution in [Raku][] that used [SetHash][]. Then I translated
that solution into [Perl][], which does not have [SetHash][], but of course it
has the good ol' *hash*.

Then I figured (in [Perl][]) that I could do without the *hash* by using arrays
only. So I backported that solution in [Raku][] too, which provided a
performance boost. This is the solution in [Raku][] at that point:

```raku
#!/usr/bin/env raku
use v6;

sub find-possible-paths ($N) {
   my @solution = [''],;
   for 1 .. $N -> $i {
      my @new_iteration = [],;
      for 0 ..^ @solution.elems -> $j {
         my $previous = @solution[$j];
         my $left     = @new_iteration[$j];
         my $right    = @new_iteration[$j + 1] = [];
         $left.push:  (@solution[$j].flat X~ 'L').Slip;
         $right.push: (@solution[$j].flat X~ 'R').Slip;
         $right.push: (@new_iteration[$j].flat X~ 'H').Slip;
      }
      @solution = @new_iteration;
      $i.note;
   }
   return @solution[*-1].flat;
}

sub MAIN ($N = 2) { find-possible-paths($N).join(', ').put; }
```

> I still have to get the hang of when to use `.flat` and when to use `.Slip`.
> I hope to fully understand it some day...

The idea is to use *dynamic programming* for computing all possible paths to
all nodes layer by layer, starting from the top down to the bottom. In the last
iteration, our solution is in the last element of the bottom right of the
pyramid.

As anticipated, it's done layer by layer. From a layer, it's possible to
compute all ways to get to any node in the layer below. For this reason, we
don't need to keep the whole pyramid in memory, only the previous layer and the
current one.

(Now that I'm writing, I think we could even optimize this by getting
incrementally rid of the previous layer as we consume it, but let's not
digress).

It works... up to about 11 or 12, where it starts to eat *a lot* of
memory. Actually, in my 4 GB VM, the process was killed for going out of
memory while computing the solution for 12 😅

The corresponding solution in [Perl][]:

```perl
sub find_possible_paths ($N) {
   my @solution = (['']);
   for my $i (1 .. $N) {
      my @new_iteration = [];
      for my $j (0 .. $#solution) {
         my $previous = $solution[$j];
         my $left     = $new_iteration[$j];
         my $right    = $new_iteration[$j + 1] = [];
         for my $p ($previous->@*) {
            push $left->@*, $p . 'L';
            push $right->@*, $p . 'R';
         }
         for my $p ($left->@*) {
            push $right->@*, $p . 'H';
         }
      }
      @solution = @new_iteration;
   }
   return $solution[-1]->@*;
}
```

It is quite faster, but shares the same memory problem.

So... we're at about 11 in my Linux VM, with exponential/factorial expansions
as I can guess.

**[E. Choroba][] extended the challenge to 20.**

OK, we need to change approach.

## Back to the drawing board

At this point, we can observe that we can address this as a *string manipulation* problem.

Let's start from the solution for `$N = 2` (rearranged):

```
LLHH
LRH
LHLH
LHR
RLH
RR
```

We can observe that, for every path, we can generally find a *simpler* path by
substituting a `LH` sequence with a shortcut `R`.

Well, unless there's no `LH` sequence, of course.

Let's consider the first one `LLHH`. It contains one `LH` group (in the
middle), so another solution is `LRH` (second line). At this point, this
other solution cannot be *simplified* any more.

Then let's consider `LHLH` (third line). It has two `LH` groups, which we
can substitute individually or both at the same time, to find `LHR`
(fourth line), `RLH` (fifth line), and `RR` (sixth line). Again, no more
simplifications are possible past this point.

Now we can observe that this technique allows us to:

- concentrate only on finding out valid sequences *without* an `R`, because we
  can find the ones with `R` by the *simplification* process, and more
  importantly
- avoid keeping track of possible duplicates, because different (valid)
  sequences with `L`s and `H`s will always yield different simplified strings.

Hence, our problem is now broken down into two parts:

- code an algorithm to find all *valid* sequences of `L`s and `H`s, in the same
  number, that can represent a path from the top of the triangle down to the
  bottom-right;
- code an algorithm to find all *simplifications* of a sequence of `L`s
  and `H`s only.

Additionally, we will code this with the constraint of consuming as little
memory as possible, in an iterative way; this will let us start getting
results immediately, and avoid filling up the memory. Although it will
probably take *a lot of time*!

### Finding valid sequences with `L`s and `H`s only

Any path from start to end MUST be compound of an equal number of `L` and
`H` characters. For a triangle whose side has length `$N`, there will be
`$N` of both characters in sequences that do not comprise `R`s.

How to find them all? I opted for a *brutish force* approach.

We can image that the `$N` characters `L` and `$N` characters `H` are
arranged in an array that is `2 * $N` long. For this reason, all
*candidate* sequences can be found by finding all possible ways of getting
`$N` positions in the array, assuming that those positions are filled with
`L`s and the rest with `H`s.

To find all combinations, I've adapted a function from a previous post:

```perl
sub combinations_iterator ($k, @items) {
   my @indexes = (0 .. ($k - 1));
   my $n = @items;
   return sub {
      return unless @indexes;
      my (@combination, @remaining);
      my $j = 0;
      for my $i (0 .. ($n - 1)) {
         if ($j < $k && $i == $indexes[$j]) {
            push @combination, $items[$i];
            ++$j;
         }
         else {
            push @remaining, $items[$i];
         }
      }
      for my $incc (reverse(-1, 0 .. ($k - 1))) {
         if ($incc < 0) {
            @indexes = (); # finished!
         }
         elsif ((my $v = $indexes[$incc]) < $incc - $k + $n) {
            $indexes[$_] = ++$v for $incc .. ($k - 1);
            last;
         }
      }
      return \@combination;
   }
}
```

This function returns an iterator that allows us to generate all possible
distinct sequences with `$N` `L`s and `$N` `H`s.

Which, of course, is *not* what we need, right?

Not all the sequences generated in this way will comply with the rules. We
are bound to move *inside* the triangle, so for example a sequence like
`HLLH` cannot be admitted. This means that we have to check each candidate
and reject those that make us fall outside of the triangle.

This is how we use the `combinations_iterator` to generate the candidate
sequences and reject the ones that are not good for us:

```perl
sub basic_case_iterator ($N) {
   my $N2 = 2 * $N;
   my $cs;
   return sub {
      $cs //= combinations_iterator($N, 0 .. $N2 - 1);
      CANDIDATE:
      while (my $Ls = $cs->()) {
         my @sequence = ('H') x $N2;
         @sequence[$Ls->@*] = ('L') x $N;
         my $count = 0;
         for my $item (@sequence) {
            $count += $item eq 'L' ? 1 : -1;
            next CANDIDATE if $count < 0;
         }
         return join '', @sequence;
      }
      return;
   };
}
```

After generating a `@sequence`, we check that we don't fall out of the
triangle. To do this, we check that the number of `H` characters does not
overcome the number of `L` characters at any time.

Actually, we can trim some time from this function by observing that *all*
valid sequences will always start with an `L` and end with an `H`, so
there's no point in considering anything different:

```perl
sub basic_case_iterator ($N) {
   --$N;
   my $N2 = 2 * $N;
   my $cs;
   return sub {
      $cs //= combinations_iterator($N, 0 .. $N2 - 1);
      CANDIDATE:
      while (my $Ls = $cs->()) {
         my @sequence = ('H') x $N2;
         @sequence[$Ls->@*] = ('L') x $N;
         my $count = 1;  # we will force starting with an L
         for my $item (@sequence) {
            $count += $item eq 'L' ? 1 : -1;
            next CANDIDATE if $count < 0;
         }
         return join '', 'L', @sequence, 'H';
      }
      return;
   };
}
```

This means that we have to choose 1 less position for `L` from a pool of
2 less possible positions (hence the `--$N` at the beginning), our
`$count` starts from 1 (because our real candidate always starts with `L`)
and our return value has to account for an initial `L` and a final `H`.

Boring optimization, after all!

### Finding all *alternatives* for a sequence

Now that we have all *seed* sequences that only have `L` and `H`
characters, it's time to generate all possible variants with the
simplification we discussed earlier.

Here's the code for the impatients:

```perl
sub expand_with_Rs_iterator ($sequence) {
   my $indexes;
   my @parts;
   my ($i, $n, $max);
   return sub {
      if (! $indexes) { # initialize
         @parts = grep {length} split m{(LH)}mxs, $sequence;
         $indexes = [grep {$parts[$_] eq 'LH'} 0 .. $#parts];
         $n = $indexes->@*;
         $max = 0;
         $max = ($max << 1) | 1 for 1 .. $n;
         $i = 0;
         return $sequence;
      }
      return if $i >= $max;
      ++$i;
      my @Rs = split m{}mxs, sprintf "%0${n}b", $i;
      my @copy = @parts;
      for my $j (0 .. $#Rs) {
         next unless $Rs[$j];
         $copy[$indexes->[$j]] = 'R';
      }
      return join '', @copy;
   };
}
```

The function takes a string `$sequence` and provides an iterator to go
through all its alternative simplified forms, starting from the whole
`$sequence` itself (i.e. without simplification).

The key insight here is to consider that a generic `$sequence` will be
comprised of some `LH` groups and other stuff. The simplification can only
happen on `LH` groups, so we divide the `$sequence` into `@parts`
isolating all `LH` groups, like this:


```
  LL (LH) H (LH) HL (LH) H
```

If we find out that there are $k$ such groups, it means that each of them
can be either in its longer form `LH` (let's call this *state 0*) or in
its simplified form `R` (let's call this state 1).

Each `LH` group is independent of the others. So we have a sequence of $k$
*things*, each of which can independently take one or another value... *If
only we had some way to generate all possible states...*

Wait a minute! This is just counting in binary with $k$ bits!

For this reason, we keep a counter `$i` and we turn it into a binary form
as we increment it along the way. Each binary representation will tell us
which groups we have to leave alone and which we have to turn into `R`s...
and we're done!

### Putting all together

Now we have to put things together:

```perl
sub find_possible_paths_iterator ($N) {
   my ($basic_it, $fit);
   return sub {
      $basic_it //= basic_case_iterator($N);
      while ('necessary') {
         $fit //= expand_with_Rs_iterator($basic_it->() // return);
         if (my $item = $fit->()) { return $item }
         $fit = undef;
      }
   };
}
```

We return an iterator, keeping track of two iterators inside:

- `$basic_it` is our iterator through all possible valid sequences with
  `L`s and `H`s only;
- `$fit` is our iterator through all possible variants/simplifications of
  a starting sequence from the previous iterator.

The function just makes sure to draw one more `L`/`H` sequence when needed
(think of it as a sort of *outer loop*) and get all possible variants from
it (this would be a sort of *inner loop*).

We now *just* have to consume it:

```perl
my $n = shift // 2;
my $it = find_possible_paths_iterator($n);
while (my $c = $it->()) { say $c }
```

We're done at last!

## The final Perl solution

The whole program in [Perl][] is the following. It uses the faster (but memory
taxing) approach for values of `$N` up to 10 included, then switches to the
iterator-based approach for bigger input values.

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use constant THRESHOLD => 10;

sub find_possible_paths ($N) {
   my @solution = (['']);
   for my $i (1 .. $N) {
      my @new_iteration = [];
      for my $j (0 .. $#solution) {
         my $previous = $solution[$j];
         my $left     = $new_iteration[$j];
         my $right    = $new_iteration[$j + 1] = [];
         for my $p ($previous->@*) {
            push $left->@*, $p . 'L';
            push $right->@*, $p . 'R';
         }
         for my $p ($left->@*) {
            push $right->@*, $p . 'H';
         }
      }
      @solution = @new_iteration;
   }
   return $solution[-1]->@*;
}

sub combinations_iterator ($k, @items) {
   my @indexes = (0 .. ($k - 1));
   my $n = @items;
   return sub {
      return unless @indexes;
      my (@combination, @remaining);
      my $j = 0;
      for my $i (0 .. ($n - 1)) {
         if ($j < $k && $i == $indexes[$j]) {
            push @combination, $items[$i];
            ++$j;
         }
         else {
            push @remaining, $items[$i];
         }
      }
      for my $incc (reverse(-1, 0 .. ($k - 1))) {
         if ($incc < 0) {
            @indexes = (); # finished!
         }
         elsif ((my $v = $indexes[$incc]) < $incc - $k + $n) {
            $indexes[$_] = ++$v for $incc .. ($k - 1);
            last;
         }
      }
      return \@combination;
   }
}

sub basic_case_iterator_longer ($N) {
   my $N2 = 2 * $N;
   my $cs;
   return sub {
      $cs //= combinations_iterator($N, 0 .. $N2 - 1);
      CANDIDATE:
      while (my $Ls = $cs->()) {
         my @sequence = ('H') x $N2;
         @sequence[$Ls->@*] = ('L') x $N;
         my $count = 0;
         for my $item (@sequence) {
            $count += $item eq 'L' ? 1 : -1;
            next CANDIDATE if $count < 0;
         }
         return join '', @sequence;
      }
      return;
   };
}

sub basic_case_iterator ($N) {
   --$N;
   my $N2 = 2 * $N;
   my $cs;
   return sub {
      $cs //= combinations_iterator($N, 0 .. $N2 - 1);
      CANDIDATE:
      while (my $Ls = $cs->()) {
         my @sequence = ('H') x $N2;
         @sequence[$Ls->@*] = ('L') x $N;
         my $count = 1;  # we will force starting with an L
         for my $item (@sequence) {
            $count += $item eq 'L' ? 1 : -1;
            next CANDIDATE if $count < 0;
         }
         return join '', 'L', @sequence, 'H';
      }
      return;
   };
}

sub expand_with_Rs_iterator ($sequence) {
   my $indexes;
   my @parts;
   my ($i, $n, $max);
   return sub {
      if (! $indexes) { # initialize
         @parts = grep {length} split m{(LH)}mxs, $sequence;
         $indexes = [grep {$parts[$_] eq 'LH'} 0 .. $#parts];
         $n = $indexes->@*;
         $max = 0;
         $max = ($max << 1) | 1 for 1 .. $n;
         $i = 0;
         return $sequence;
      }
      return if $i >= $max;
      ++$i;
      my @Rs = split m{}mxs, sprintf "%0${n}b", $i;
      my @copy = @parts;
      for my $j (0 .. $#Rs) {
         next unless $Rs[$j];
         $copy[$indexes->[$j]] = 'R';
      }
      return join '', @copy;
   };
}

sub find_possible_paths_iterator ($N) {
   my ($basic_it, $fit);
   return sub {
      $basic_it //= basic_case_iterator($N);
      while ('necessary') {
         $fit //= expand_with_Rs_iterator($basic_it->() // return);
         if (my $item = $fit->()) { return $item }
         $fit = undef;
      }
   };
}

my $n = shift // 2;
my $use_iterator = $ENV{USE_ITERATOR} ? 1
   : defined($ENV{USE_ITERATOR})      ? 0
   : $n > THRESHOLD;
if ($use_iterator) {
   my $it = find_possible_paths_iterator($n);
   while (my $c = $it->()) { say $c }
}
else {
   say for find_possible_paths($n);
}
```

The two solutions are equivalent, although they provide sequences in
a different order... we were assuming that any ordering is fine, right?!?

# Conclusion

This has been a hell of a ride! And... somehow tiring.

It would be great to code an iterator-based solution in [Raku][] too,
especially because I suspect that the `gather`/`take` mechanism is perfect for
coding it with lazyness. Probably.

Well... maybe some other time!



[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#117]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-117/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-117/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[SetHash]: https://docs.raku.org/type/SetHash
[E. Choroba]: https://github.com/choroba
