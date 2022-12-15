---
title: PWC195 - Special Integers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-15 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#195][]. Enjoy!

# The challenge

> You are given a positive integer, `$n > 0`.
>
> Write a script to print the count of all special integers between `1`
> and `$n`.
>
>> An integer is special when all of its digits are unique.
>
> **Example 1:**
>
>     Input: $n = 15
>     Output: 14 as except 11 all other integers between 1 and 15 are spcial.
>
> **Example 2:**
>
>     Input: $n = 35
>     Output: 32 as except 11, 22, 33 all others are special.

# The questions

I'd probably ask a couple of questions:

- are we talking about the digits in a decimal representation?
- is there a limit on `$n` to consider?

# The solution

The number of *special integers* is clearly limited by the available
digits. Hence, the maximum such integer is 9876543210; beyond this,
there will always be two digits that are the same (by [Pigeonhole
principle][]).

Now, for low values of `$n` we might opt for a brute force approach.
E.g. in [Raku][] we might have:

```raku
sub special-integers-bf ($n) {
   my $count = 0;
   for 1 .. $n -> $candidate {
      ++$count if $candidate.comb.Set.elems == $candidate.chars;
   }
   return $count;
}
```

The corresponding in [Perl][]:

```perl
sub special_integers ($n) {
   my $count = 0;
   for my $candidate (1 .. $n) {
      ++$count if length($candidate) == uniq sort split m{}, $candidate;
   }
   return $count;
}
```

Alas, this does not scale well. To be able to count them all (possibly),
we have to think differently.

One possible approach is to be *generative* and only consider
permutations over collections of different digits. This is easy to
implement in [Raku][], which comes with permutations and combinations
out of the box:

```raku
sub special-integers ($n) {
   my $count = 0;
   for 1 .. $n.chars -> $len {
      for combinations([0..9], $len) -> $comb {
         for permutations($comb) -> $perm {
            next if $perm[0] == 0;
            last if $perm.join('').Int > $n;
            ++$count;
         }
      }
   }
   return $count;
}
```

This, combined with a preliminar check on the input size (capping it at
the maximum) gives us something that does computations for any input in
a *reasonable* time:

```
$ time raku raku/ch-1.raku 9876543210
8877690

real	1m42.454s
user	1m42.037s
sys	0m0.181s

$ time raku raku/ch-1.raku 100000000000000
8877690

real	1m49.882s
user	1m49.890s
sys	0m0.128s
```

Well, for some definition of *reasonable*, at least.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#195]: https://theweeklychallenge.org/blog/perl-weekly-challenge-195/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-195/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Pigeonhole principle]: https://en.wikipedia.org/wiki/Pigeonhole_principle
