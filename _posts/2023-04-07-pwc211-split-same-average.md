---
title: PWC211 - Split Same Average
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-04-07 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#211][].
> Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find out if the given can be split into two separate
> arrays whose average are the same.
>
> **Example 1:**
>
>     Input: @nums = (1, 2, 3, 4, 5, 6, 7, 8)
>     Output: true
>
>     We can split the given array into (1, 4, 5, 8) and (2, 3, 6, 7).
>     The average of the two arrays are the same i.e. 4.5.
>
> **Example 2:**
>
>     Input: @list = (1, 3)
>     Output: false

# The questions

One first question is probably *how big the input array will be*? Depending
on the answer, as we will see, we might just go with a *brute force*
exponential approach, or try to find out something more *sophisticated*.

Another interesting question would be a confirmation on the domain, and in
particular a confirmation that those integers might be *negative* as well. I
hope my fellow challengers will not be tripped by this fact (I was about to
be).

Last, I'd ask whether the inputs have a bound or not. This would not be a
problem *per-se* in [Raku][], but in [Perl][] I'm still relying on what the
language gives me out of the box, so it would be wise to figure out if big
integers would be needed (expecially for my case, because I'm going to
translate inputs to only deal with non-negative values).

# The solution

When I address these challenges, I usually start with coding the solutions
(strictly as [Raku][] then [Perl][] for the first task, [Perl][] then
[Raku][] for the second one, because they're both lovely), then move on to
the blog post, first copying the challenge, then writing out some questions
I gathered on the way, then describing the solution in this very section.

This time... I start here.

The most basic and obvious algorithm is a brute force attempt with a
disastrous $O(2^n)$ complexity. What's that, and why this complexity? Well,
we can consider any possible subset out of the $n$ input integers, then
calculate the average on those elements and on what's left over, compare and
declare success or move on to the next subset. As any element can, or can
not, be in this subset, it's like having a yes/no flag behind each element,
i.e. a string of $n$ bits that we can play with.

OK, we have a base line, at least.

## Let's meet in the middle

One observation that can be immediately done is that if we go through all
subsets with $k$ elements inside, at the very same time we're covering
all subsets with $n - k$ elements too. This means that it's sufficient to go
up to $\lfloor n / 2 \rfloor$, i.e. that the real complexity is
$O(2^{\lfloor n/2 \rfloor})$.

It's still exponential, but at least we have doubled our inputs!

## Calculating averages

We can *observe* that if the average over the two subsets are the same,
*surely* this can tell us something about the average over the whole lot,
right? It turns out that *it actually does*.

Let's assume that we have such a partition, where the first subset holds $u$
elements ${a_1, a_2, ..., a_u}$ and the second subset holds $v$ elements
${b_1, b_2, ..., b_v}$. Then we have:

$$
\frac{1}{u}\sum_{i=1}^u a_i = \frac{1}{v}\sum_{j=1}^v b_j
$$

For sake of simplicity, let's set names:

$$
A = \sum_{i=1}^u a_i \\
B = \sum_{j=1}^v b_j
$$

so that our initial relation is written simply as:

$$
\frac{A}{u} = \frac{B}{v}
$$

Solving for $B$ we get:

$$
B = \frac{v}{u} A
$$

The average over *all* elements is expressed like this:

$$
\frac{1}{u + v} (\sum_{i=1}^u a_i + \sum_{j=1}^v b_j) = \frac{A + B}{u + v}
$$

Substituting $B$ we get:

$$
\begin{align}
\frac{A + B}{u + v} & = \frac{1}{u + v} (A + \frac{v}{u} A) \\
  & = \frac{1}{u + v}(1 + \frac{v}{u}) A \\
  & = \frac{1}{u + v}\frac{u + v}{u} A \\
  & = \frac{A}{u} \\
  & = \frac{B}{v}
\end{align}
$$

that is, the three averages are the same as one another.

This means that instead of calculating the averages over the two subsets for
each candidate, we can calculate the reference average over all elements
once at the beginning, and then the average over one single subset only.
Assuming that the "big thing" is calculating the average (still a linear
operation at the basic level), we have halved our search effort.

## Integer constraint

There's still something to extract from the challenge constraints, i.e. the
fact that the inputs are all integers.

Let's take the first example:

```
Input: @nums = (1, 2, 3, 4, 5, 6, 7, 8)
```

The average over all elements is $4.5$.

If we consider any subset of $k$ elements, the subset is a *good* one if
their sum is $4.5 k$. This implies that $k$ can only be even, otherwise
the sum would not be integer.

This can be generalized: if the average has a reduced form:

$$
M = \frac{p}{q}
$$

with $p$ and $q$ co-primes, then a good candidate subset can only have a
number $k$ of elements that is also divisible by $q$, so that:

$$
S_k = k \frac{p}{q}
$$

is integer.

Alas, this does not help in the worst case where the average itself is an
integer number (i.e. $q = 1$), but still gives a big improvement in the
general case, as we can focus on subsets whose cardinality is a multiple of
$q$.

> It would be interesting to calculate the probability of having an integer
> average out of a random draw of integers.

The integer constraint and our observation also helps moving the focus from
finding the right average $M$ to finding the right sum $S_k$. This is
actually solving a variant of the knapsack problem (with a specific target
and a constraint on the number of elements), for which we can *hope* to find
something that can help.

I'll call this a day, though, and not look further into it.

## Solution (really!)

Let's go [Perl][] first. Checking for a feasible set leverages some caching
to keep track of past failures and not go through all the calculations over
and over (hopefully).

Another twist in the implementation is that the test is performed on a
transformed array, shifted so that all elements are non-negative. This is an
invariant, but then helps better pruning the search because it allows making
some assumptions in `$has_subset` (in particular, failing if `$sum` turned
negative).

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my @args = @ARGV ? @ARGV : 1 .. 8;
say split_same_average(@args) ? 'true' : 'false';

sub split_same_average (@list) {

   # pre-massage the list to only cope with non-negative integers
   (my $min, @list) = sort { $a <=> $b } @list;
   my @partial_sums = (0);
   push @partial_sums, $partial_sums[-1] + ($list[$_] -= $min)
      for 0 .. $#list;
   unshift @list, 0; # put "min" back

   my %cache;
   my $has_subset = sub ($sum, $k, $i = $#list) {
      return 1 if ($sum == 0) && ($k == 0);  # found!
      return 0
         if ($sum < 0)                 # removed more than needed
         || ($i < 0)                   # nothing more to look at
         || ($sum > $partial_sums[$i]) # cannot remove as much as needed
         ;

      # caching on subset size $k and end cursor position $i only, the $sum
      # is a consequence of $k
      return $cache{$k}{$i} //=
            __SUB__->($sum - $list[$i], $k - 1, $i - 1) # try greedy first
         || __SUB__->($sum, $k, $i - 1);                # fallback
   };

   # calculate p and q (average for modified list is p/q)
   my $n = @list;
   my $sum = $partial_sums[-1];
   my $gcd = gcd($sum, $n);
   my ($p, $q) = ($sum / $gcd, $n / $gcd);

   # iterate finding subsets of multiples of q, starting at q itself
   my $k = $q;
   while ($k <= $n / 2) {
      my $S = $p * $k / $q; # target sum
      return 1 if $has_subset->($S, $k);
      $k += $q;
   }

   # nothing found, fail
   return 0;
}

sub gcd ($A, $B) { ($A, $B) = ($B % $A, $A) while $A; return $B }
```

The [Raku][] alternative is a pretty straight translation. I hope lazyness
is still one of the three virtues of a programmer these days.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   @args = 1 .. 8 unless @args;
   put split-same-average(@args);
}

sub split-same-average (@list) {
   (my $min, @list) = @list.sort.Slip;
   my @partial-sums = 0;
   @partial-sums.push: @partial-sums[*-1] + (@list[$_] -= $min) for ^@list;
   @list.unshift: 0; # put "min" back

   my %cache;
   sub has_subset ($sum, $k, $i = @list.end) {
      return True if ($sum == 0) && ($k == 0);
      return False
         if ($sum < 0)                 # removed more than needed
         || ($i < 0)                   # nothing more to look at
         || ($sum > @partial-sums[$i]) # cannot remove as much as needed
         ;

      # caching on subset size $k and end cursor position $i only, the $sum
      # is a consequence of $k
      return %cache{$k}{$i} //=
            samewith($sum - @list[$i], $k - 1, $i - 1)
         || samewith($sum, $k, $i - 1);
   }

   # calculate p and q (average for modified list is p/q)
   my $n = @list.elems;
   my $sum = @partial-sums[*-1];
   my $gcd = gcd($sum, $n);
   my ($p, $q) = $sum div $gcd, $n div $gcd;

   # iterate finding subsets of multiples of q, starting at q itself
   my $k = $q;
   while $k <= $n div 2 {
      my $S = $p * $k / $q; # target sum
      return True if has_subset($S, $k);
      $k += $q;
   }

   # nothing found, fail
   return False;
}

sub gcd ($A is copy, $B is copy) { ($A, $B) = ($B % $A, $A) while $A; $B }
```

Have fun and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#211]: https://theweeklychallenge.org/blog/perl-weekly-challenge-211/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-211/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
