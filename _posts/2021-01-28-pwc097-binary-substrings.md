---
title: PWC097 - Binary Substrings
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-28 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#097][].
> Enjoy!

# The challenge

> You are given a binary string `$B` and an integer `$S`. Write a script
> to split the binary string `$B` of size `$S` and then find the minimum
> number of flips required to make it all the same.


# The questions

I guess the challenge and the examples are quite clear, although there's
a lot of input validation that can go wrong! I'm assuming that raising
an exception (read: `die`) is fine if inputs are not good.


# The solution

I don't usually include validation of inputs but this challenge was
giving me too many itches:

```perl
sub binary_substrings ($B, $S) {
   die "invalid input string <$B>" unless $B =~ m{\A [01]* \z}mxs;
   my $len = length $B or return 0;
   die "$S is not a factor of the length of <$B>\n" if $len % $S;

   my @parts = map { substr $B, $_ * $S, $S } 0 .. ($len / $S) - 1;
```

We check that `$B` is *indeed* composed of only `0` and `1` characters,
and also that `$S` evenly divides `$B` so that all substrings are of the
same length. After the checks, we can divide the input string into parts
and move on.

To address the actual challenge, we can reason like this. Each substring
might be at the *center*, i.e. be the right candidate to be the target
to which every other substring should be changed to.

Hence, our task is to find which of these substrings is actually the
best one, i.e. the one that minimizes the amount of bit flipping for all
other substrings.

This means that:

- we have to evaluate the *distance* (i.e. bit flipping) between any two
  substrings. This works in both ways, of course, because the bit
  flipping between two strings only is just the number of positions
  where they have a different character;
- we have to count the total amount of bit flipping considering each
  substring as the candidate to be the *center*;
- last, we have to get the minimum amount of bit flipping from each
  candidate.

Piece of cake!

```perl
   my @total_distances;
   for my $i (0 .. $#parts) {
      for my $j ($i + 1 .. $#parts) {
         my $d = 0;
         for my $k (0 .. $S - 1) {
            $d++ if substr($parts[$i], $k, 1) ne substr($parts[$j], $k, 1);
         }
         ($total_distances[$_] //= 0) += $d for ($i, $j);
      }
   }
   return min @total_distances;
```

Array `@total_distances` records the amount of bit-flipping when
considering each item in `@parts` as the right candidate to be at the
*center*. As such, it will eventually hold an integer for each
sub-sequence, indexed by the same index of the sub-sequence inside
`@parts`.

Distances are symmetric, i.e. the distance between sub-sequence `1` and
sub-sequence `2` is the same if we invert the two. Hence, we don't have
to do the whole `$S x $S` calculation, but we can just calculate the
distances for different pairs once. This accounts for the two nested
loops with index `$i` ranging from `0` to `$#parts - 1`, and `$j`
ranging from `$i + 1` to `$#parts`. Note that the distance of a
sub-sequence from itself is... `0`, so we don't need to consider it in
our calculation.

Computing the distance is another loop inside the two above: we iterate
over all characters in the two strings, comparing them and increasing
the counter variable `$d` as we find differences.

The output of this loop gives us the distance between sub-sequence at
index `$i` and sub-sequence at index `$j`, so we proceed to increase
both entries inside `@total_distances`.

As anticipated, the answer to our problem is the minimum value across
all those that are accumulated in `@total_distances`, so we leverage the
`min` function from [List::Util][].

As usual... the whole code, should you be interested into it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'min';

sub binary_substrings ($B, $S) {
   die "invalid input string <$B>" unless $B =~ m{\A [01]* \z}mxs;
   my $len = length $B or return 0;
   die "$S is not a factor of the length of <$B>\n" if $len % $S;

   my @parts = map { substr $B, $_ * $S, $S } 0 .. ($len / $S) - 1;
   my @total_distances;
   for my $i (0 .. $#parts - 1) {
      for my $j ($i + 1 .. $#parts) {
         my $d = 0;
         for my $k (0 .. $S - 1) {
            $d++ if substr($parts[$i], $k, 1) ne substr($parts[$j], $k, 1);
         }
         ($total_distances[$_] //= 0) += $d for ($i, $j);
      }
   }
   return min @total_distances;
}

my $binary_string = shift // '101100101';
my $substring_length = shift // 3;
say binary_substrings($binary_string, $substring_length);
```

Stay safe!!!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#097]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-097/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-097/#TASK2
[Perl]: https://www.perl.org/
[List::Util]: https://metacpan.org/pod/List::Util
