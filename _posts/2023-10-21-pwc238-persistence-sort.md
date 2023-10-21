---
title: PWC238 - Persistence Sort
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-21 16:43:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#238][].
> Enjoy!

# The challenge

> You are given an array of positive integers.
>
> Write a script to sort the given array in increasing order with
> respect to the count of steps required to obtain a single-digit number
> by multiplying its digits recursively for each array element. If any
> two numbers have the same count of steps, then print the smaller
> number first.
>
> **Example 1**
>
>     Input: @int = (15, 99, 1, 34)
>     Output: (1, 15, 34, 99)
>
>     15 => 1 x 5 => 5 (1 step)
>     99 => 9 x 9 => 81 => 8 x 1 => 8 (2 steps)
>     1  => 0 step
>     34 => 3 x 4 => 12 => 1 x 2 => 2 (2 steps)
>
> **Example 2**
>
>     Input: @int = (50, 25, 33, 22)
>     Output: (22, 33, 50, 25)
>
>     50 => 5 x 0 => 0 (1 step)
>     25 => 2 x 5 => 10 => 1 x 0 => 0 (2 steps)
>     33 => 3 x 3 => 9 (1 step)
>     22 => 2 x 2 => 4 (1 step)

# The questions

Doing multiplications can get big numbers quite fast, although each
iteration will *always* produce a smaller value. Anyhow, it's probably
fine to ask for the input domain and rule out (or in!) the need for big
integers.

# The solution

We will go [Perl][] first this time, enhancing the input array with info
for doing the sorting, then getting the basic data back at the end. This
is a common technique that I know under the name of *Schwartzian transform* (from Randal L. Schwartz, a.k.a. *merlyn*, who invented it):

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say '(', join(', ', persistence_sort(@ARGV)), ')';

sub persistence_sort (@int) {
   map { $_->[0] }
      sort { ($a->[1] <=> $b->[1]) || ($a->[0] <=> $b->[0]) }
      map { [ $_, persistence_for($_) ] }
      @int;
}

sub persistence_for ($v) {
   my $rounds = 0;
   my @digits = split m{}mxs, $v;
   while (@digits > 1) {
      ++$rounds;
      @digits = split m{}mxs, prod(@digits);
   }
   return $rounds;
}

sub prod (@ints) {
   my $retval = 1;
   for my $int (@ints) {
      $retval *= $int or return 0;
   }
   return $retval;
}
```

We can replicate the same in [Raku][], taking advantage of some of the
included batteries (e.g. to compute the product of all digits):

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { say persistence-sort(@args) }

sub persistence-sort (@int) {
   return @int
      .map({ [$_, persistence-for($_)] })
      .sort({ ($^a[1] <=> $^b[1]) || ($^a[0] <=> $^b[0]) })
      .map({ $_[0] })
      .Array;
}

sub persistence-for ($v) {
   my $rounds = 0;
   my @digits = $v.comb;
   while @digits > 1 {
      ++$rounds;
      @digits = ([*] @digits).comb;
   }
   return $rounds;
}
```

The Schwartziant transform has a different *taste* this time, because it
goes on a natural "reading" way instead of going backwards. Still, it's
basically the same as before.

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#238]: https://theweeklychallenge.org/blog/perl-weekly-challenge-238/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-238/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
