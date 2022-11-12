---
title: All positive integer sums, as iterator
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-19 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Turning the recursive implementation in [All positive integer sums][]
> to an iterator-based one.

For the purposes laid out in [All positive integer sums][] to figure out
all [partitions of a set][], it can be handy to have an iterator-based
implementation, i.e. one where we don't get all possible arrangements at
once, but one *next* arrangement only when we ask for it.

This allows us to *chain* operations that take a specific input and
expand it to zero, one, or multiple outputs, again with an
iterator-based approach. At the end of the whole process, this will
allow us to do something like this:

```perl
my $it = gimme_iterator(@args);
while (my $arrangement = $it->()) {
    printout($arrangement);
}
```

You get the idea.

The easiest way to turn the implementation we have into an
iterator-based one is probably the following:

```perl
sub int_sums_recursive ($N, $max = undef) {
   return ([]) unless $N;
   $max = $N if ! defined($max) || $max > $N;
   my @retval;
   for my $first (reverse 1 .. $max) {
      push @retval, [$first, $_->@*]
         for int_sums_recursive($N - $first, $first);
   }
   return @retval;
}

sub int_sums_iterator ($N) {
   my @arrangements = int_sums_recursive($N);
   return sub { return shift @arrangements };
}
```

Although it might not seem too clever, this still has its merits because
it allows us to start adhering to the iterator interface immediately. We
might decide to start working on the other half of the problem
immediately, or to concentrate on the iterator optimization immediately.
Which, contrarily to any common sense, we will do immediately 😅

The implementation is not too different:

```perl
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
```

One important thing that has to be settle down early on is what *return
value* we want to give. An iterator should have a non-ambiguous way of
saying that the sequence is exhausted, which in our case might be to
return `undef`/empty list with a simple lone `return`.

This leaves us with dealing with the basic case where `$N` is less than
$1$, i.e. we have to generate a decomposition of $0$ with only positive
integer values - that is, an empty list.

For this reason, we will return the lists (even an empty one) within an
array reference, so that even an empty list will be a defined scalar.
This accounts for the base case at the beginning of the function:

```perl
if ($N < 1) {
   my @retvals = ([]);
   return sub { shift @retvals };
}
```

Now on with the more interesting, general case. Taking inspiration from
our recursive implementation, we keep a `$first` variable holding the
beginning of the list, and some way to track the *rest*. We will still
leverage a *recursive* implementation, only this time the recursion will
get us a *sub*-iterator that we place in variable `$rit`.

As we already saw in other posts (e.g. [Loop from iterator][ifl],
[Iterator-based implementation of Permutations][ibi]) that a generic
strategy is to have a loop and then a `return` from within the loop,
while keeping the state in closed-upon variables. Our variables are
exactly `$first` and `$rit`, so we "just" have to set the loop:

```perl
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
```

We iterate for decreasing values of `$first`, until we hit the rock
bottom. If we exit from the loop because `$first` went down to 0, we
just `return`, flagging the end of our iterator; otherwise:

- we make sure that `$rit` contains an iterator to the *sub* sequences
  of whatever comes after `$first`;
- we extract the next *sub*-sequence and, if valid, use it to build the
  return value.

As we can see, we leverage `int_sums_iterator` recursively to get the
sub-iterator we are looking after. We might do differently (e.g.
building up an explicit stack) - maybe we will take a look at it in the
future.

So... here we are, with a mixed recursive/iterator based approach that
allows us to avoid pre-computing all elements up-front:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

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

my $it = int_sums_iterator(shift || 3);
my $n = 4;
while ((my $list = $it->()) && ($n > 0)) {
   say "($list->@*)";
   --$n;
}
```

As we see, we decided to cut the output at the fourth sequence:

```shell
$ perl int-sums.pl 6
(6)
(5 1)
(4 2)
(4 1 1)
```

I guess it's everything for this post!

[All positive integer sums]: {{ '/2021/04/18/all-positive-integer-sums/' | prepend: site.baseurl }}
[PWC108 - Bell Numbers]: {{ '/2021/04/15/pwc108-bell-numbers/' | prepend: site.baseurl }}
[Bell numbers]: https://en.wikipedia.org/wiki/Bell_number
[Bell triangle]: https://en.wikipedia.org/wiki/Bell_triangle
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
[ifl]: {{ '/2020/07/31/iterator-from-loop/' | prepend: site.baseurl }}
[ibi]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
