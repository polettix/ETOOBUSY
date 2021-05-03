---
title: PWC111 - Search Matrix
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-05 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#111][]. Enjoy!

# The challenge

> You are given 5x5 matrix filled with integers such that each row is
> sorted from left to right and the first integer of each row is greater
> than the last integer of the previous row.
>
> Write a script to find a given integer in the matrix using an
> efficient search algorithm.
>
> **Example**
>
>     Matrix: [  1,  2,  3,  5,  7 ]
>             [  9, 11, 15, 19, 20 ]
>             [ 23, 24, 25, 29, 31 ]
>             [ 32, 33, 39, 40, 42 ]
>             [ 45, 47, 48, 49, 50 ]
>
>     Input: 35
>     Output: 0 since it is missing in the matrix
>
>     Input: 39
>     Output: 1 as it exists in the matrix

# The questions

A few questions that might pop up in an interview:

- Representation?
    - Array of arrays
- Generalization to an $n \times m$ matrix?
    - Not necessary but nice to have
- How many searches are we planning to do over the same matrix?
    - Surprise us...

# The solution

The first *mind-reflex* to address this challenge is to implement a form
of [binary search][]. This is possible because the matrix is just a
long, sorted array in disguise, which can be obtained back by lining up
all rows in their order.

Hence, for a matrix holding $N = n \cdot m$ elements (where $n$ is the
number of rows and $m$ is the number of columns), we would end up with
an asyntotic complexity of $O(log(N))$.

Incidentally, this made me think if this is better instead:

- apply a binary search on the first item of each row and pinpoint one
  of them, then
- look for the item in the remaining row.

because this would end up having complexity $O(log(n) + log(m))$. Now,
if $n = m$, this becomes $O(2 log(n)) = O(log(n))$, that seems better
than $O(log(N)) = O(log(n^2))$, right?

Well... wrong. As $log(n^2) = 2 log(n)$, we end up in the same exact
situation. *Well tried, you'll be luckier the next time, let's move on*.

OK, let's see this solution then:

```perl
sub search_matrix ($M, $x) {
   my $n_rows = $M->@*      or return 0;
   my $n_cols = $M->[0]->@* or return 0;
   my ($lo, $hi) = (0, $n_rows * $n_cols - 1);
   while ('necessary') {
      my $mid = int(($lo + $hi) / 2);
      my $v   = $M->[$mid / $n_cols][$mid % $n_cols];
      return 1 if $v == $x;
      return 0 if $lo == $hi;
      if ($v < $x) { $lo = ($mid == $lo) ? $lo + 1 : $mid }
      else         { $hi = $mid }
   } ## end while ('necessary')
} ## end sub search_matrix
```

It's a basic approach to [binary search][], with a couple of caveats:

- we're actually handed over a matrix, so we have to think in terms of
  *row* and *column* instead of a single index over an array. For this
  reason, we *mostly* deal with linear indices `$lo`, `$hi` and `$mid`,
  just to transform them to a *row*/*column* pair when accessing the
  matrix `$M`;
- the rounding when calculating `$mid` always goes to the lowest number,
  so we might end up being stuck with `$lo` one less than `$hi`. For
  this reason, if the last checked values from `$M` is less than the
  target (i.e. we have to advance `$lo`) and `$mid` is equal to `$lo`,
  then we move `$lo` ahead of one place (i.e. make it the same as
  `$hi`), otherwise we assign `$mid` to `$lo` as in the normal case for
  binary search;
- the issue above does not apply to `$hi`, so if the value is greater
  than the target we just set `$hi` to be `$mid`.

Now, suppose that our problem statement is later refined like follows:

> Oh, by the way! You might be asked to assess the presence of multiple
> values in the matrix, generally around half of the elements in the
> matrix itself, or more.

Well well... this changes the thing a bit, because our overall approach
would not become $O(N \cdot log(N))$, which means that... *we might do
better* (*on average* and at the expense of some memory).

When we have to check for the presence of one item in the matrix
multiple times for multiple candidates, the problem quickly turns into
answering a *somewhat* different question: is this item inside this set?

Now, the best and quickest approximation that we have of a set in
[Perl][] is by using a hash, so we can code this:

```perl
sub matrix_searcher ($M) {
    my %is_item = map { map { $_ => 1 } $_->@* } $M->@*;
    return sub ($x) { exists $is_item{$x} ? 1 : 0 };
}

#...

my $ms = matrix_searcher(\@matrix);
say $ms->($_) ? "$_ is present" : "$_ is absent" for @targets;
```

Why is this *better on average*? It's because insertion and search into
a [hash table][] both have constant cost on average, so:

- the cost of creating the hash in `%is_item` in `matrix_searcher` is
  $O(N)$, done at the beginning only, and
- the cost of looking for all items in `@target` is $O(N)$

which gives us an overall complexity of... $O(N)$. Yay!

Should we stick to the simpler one-shot version, this is the full
program:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub search_matrix ($M, $x) {
   my $n_rows = $M->@*      or return 0;
   my $n_cols = $M->[0]->@* or return 0;
   my ($lo, $hi) = (0, $n_rows * $n_cols - 1);
   while ('necessary') {
      my $mid = int(($lo + $hi) / 2);
      my $v   = $M->[$mid / $n_cols][$mid % $n_cols];
      return 1 if $v == $x;
      return 0 if $lo == $hi;
      if ($v < $x) { $lo = ($mid == $lo) ? $lo + 1 : $mid }
      else         { $hi = $mid }
   } ## end while ('necessary')
} ## end sub search_matrix

my @matrix = (
   [1,  2,  3,  5,  7],
   [9,  11, 15, 19, 20],
   [23, 24, 25, 29, 31],
   [32, 33, 39, 40, 42],
   [45, 47, 48, 49, 50],
);

my $target = shift || 35;
say search_matrix(\@matrix, $target)
  ? "$target is present"
  : "$target is absent";
```

Last, all these considerations apply to the generalized $n \times m$
case. Is it reasonable?

Well, arguably... no. The challenge is clearly talking about a $5 \times
5$ matrix, so why bother with bigger ones? At this point, I guess, the
*hash-based* solution is still going to win if we have to check against
*a lot* of possible candidates, but I'm not 100% sure that the binary
search is still better than a simple search. I mean, there are a lot of
operations involved and they might take a noticeable toll.

Hence, the *right thing* at this point would be to make a
[Benchmark][]... but I've inflicted enough wan**AHEM**speculations on
you poor readers and I'll stop here. Stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#111]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-111/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-111/#TASK1
[Perl]: https://www.perl.org/
[binary search]: https://en.wikipedia.org/wiki/Binary_search_algorithm
[hash table]: https://en.wikipedia.org/wiki/Hash_table
[Benchmark]: https://metacpan.org/pod/Benchmark
