---
title: PWC174 - Permutation Ranking
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#174][].
> Enjoy!

# The challenge

> You are given a list of integers with no duplicates, e.g. `[0, 1, 2]`.
>
> Write two functions, `permutation2rank()` which will take the list and
> determine its rank (starting at 0) in the set of possible permutations
> arranged in lexicographic order, and `rank2permutation()` which will
> take the list and a rank number and produce just that permutation.
>
> Please checkout this post for more informations and algorithm.
>
> Given the list `[0, 1, 2]` the ordered permutations are:
>
>     0: [0, 1, 2]
>     1: [0, 2, 1]
>     2: [1, 0, 2]
>     3: [1, 2, 0]
>     4: [2, 0, 1]
>     5: [2, 1, 0]
>
> and therefore:
>
>     permutation2rank([1, 0, 2]) = 2
>
>     rank2permutation([0, 1, 2], 1) = [0, 2, 1]

# The questions

Oh, I have a few but this section is too tight now (at least the time I
have). I'll fill in questions in the next post, with the [Raku][]
solution!


# The solution

The solution is more or less a translation of the Python code in the
referenced page, with a few twists that leverage [Perl][]' toolset.
Nothing too fancy though.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util qw< reduce sum >;

say permutation2rank([qw< a b c d >]);
say permutation2rank([qw< 1 0 2 >]);
say join ' ', rank2permutation([qw< 0 1 2 >], 1)->@*;

sub permutation2rank ($permutation) {
   my $n = $permutation->@*;
   my @baseline = sort { $a cmp $b } $permutation->@*;
   my $factor = reduce { $a * $b } 1 .. $n;

   return sum map {
      my $target = $permutation->[$_];
      my $index = 0;
      ++$index while $baseline[$index] ne $target;
      splice @baseline, $index, 1;
      my $term = ($factor /= $n - $_) * $index;
   } 0 .. $n - 2;
}

sub rank2permutation ($baseline, $r) {
   my $n = $baseline->@*;
   my $factor = reduce { $a * $b } 1 .. $n - 1;
   return [
      map {
         my $index = int($r / $factor);
         $r %= $factor;
         $factor /= ($n - 1 - $_) if $factor > 1;
         splice $baseline->@*, $index, 1;
      } 0 .. $n - 1
   ];
}
```

[Raku][] will have to wait... there were two functions to code, sorry!

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#174]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
