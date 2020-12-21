---
title: PWC091 - Isomorphic Strings
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-12-22 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#092][]. Enjoy!

# The challenge

> You are given two strings `$A` and `$B`. Write a script to check if the
> given strings are [Isomorphic][]. Print 1 if they are otherwise 0.

# The questions

I guess that there are few *interview questions* here, apart from basic ones
dealing with weird inputs like undefined values.

# The solution

The fun thing is that the definition is explained in an article that also
provides a solution. Looking at it *after* coding the solution below, I
realized that the solutions are pretty similar, with the difference that I'm
using a hash where that solution uses a set because... it's so easy to use a
hash in [Perl][] ❤️

```perl
sub isomorphic_strings ($A, $B) {
   return 0 if length($A) != length($B);
   my (%A_for, %B_for);
   for my $i (0 .. length($A) - 1) {
      my ($cA, $cB) = map { substr $_, $i, 1 } ($A, $B);
      return 0
        if (exists($B_for{$cA}) && ($B_for{$cA} ne $cB))
        || (exists($A_for{$cB}) && ($A_for{$cB} ne $cA));
      $B_for{$A_for{$cB} = $cA} = $cB;
   } ## end for my $i (0 .. length(...))
   return 1;
} ## end sub isomorphic_strings
```

The trivial case where the two strings might have different lenghts is
addressed at the beginning and forgot afterwards.

In the main loop, we check character pair by character pair, making sure
that there is always a single, unique bidirectional mapping between pairs.
Whenever we hit a deviation we return immediately with a failure (0). If we
make it to the end... then it's a 1!

From an implementation perspective, I can acknowledge that the solution in
[Isomorphic][] uses the "bare minimum" of data structures to keep complexity
low; on the other hand, I think that the *double-map* solution with two
hashes like the one above might be a bit clearer to read some time after,
because of the symmetry in the problem itself.

As it often happens, though, maybe it's just a matter of taste 😋

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#092]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-092/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-092/#TASK1
[Perl]: https://www.perl.org/
[Isomorphic]: https://www.educative.io/edpresso/how-to-check-if-two-strings-are-isomorphic
