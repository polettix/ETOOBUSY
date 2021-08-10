---
title: PWC125 - Pythagorean Triples
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-11 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#125][]. Enjoy!

# The challenge

> You are given a positive integer `$N`.
> 
> Write a script to print all `Pythagorean Triples` containing `$N` as a
> member. Print -1 if it can’t be a member of any.
> 
> Triples with the same set of elements are considered the same, i.e. if
> your script has already printed (3, 4, 5), (4, 3, 5) should not be
> printed.
> 
>> The famous Pythagorean theorem states that in a right angle
>> triangle, the length of the two shorter sides and the length of the
>> longest side are related by a²+b² = c².
> 
> A Pythagorean triple refers to the triple of three integers whose
> lengths can compose a right-angled triangle.
> 
> **Example**
>
>     Input: $N = 5
>     Output:
>         (3, 4, 5)
>         (5, 12, 13)
> 
>     Input: $N = 13
>     Output:
>         (5, 12, 13)
>         (13, 84, 85)
> 
>     Input: $N = 1
>     Output:
>         -1

# The questions

Well, I really don't have questions for this one. I would argue that
printing `-1` troubles me a bit, but I'll stick to the requirement.

Oh, by the way... I'll assume that any ordering will do!

# The solution

This took me a good deal of time.

There's a few ways to generate [Pythagorean triples][]. One of the most
famous is *Euclid's formula*, which unfortunately generates a lot, but
not all of them. And we're going to need all of them here, potentially.

Had I immediately read through [Formulas for generating Pythagorean
triples][formula], I would not have *wasted* my time with an article
that eventually proved... *unuseful*. I would be tempted to post it here
just to have a different pair of eyes confirming its lack of usefulness,
but I'm inclined to believe that I would waste someone else's time
*too*. Ring me a bell in case.

I eventually landed on two possible options:

- use an algorithm to find all **primitive** triples, i.e. triples where
  the three sides are *mutually prime*, and use that to find them all,
  OR
- use [Dickson's method][dickson], which (as I read) is guaranteed to
  generate them all.

I eventually landed on the latter, so here we go with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub pythagorean-triples (Int:D $N where * > 0) {

   # this finds all possible (distinct) ways of expressing $n as a
   # product of two positive integers. The first item is by definition
   # lower than, or equal to, the second so that we know that only
   # distinct pairs are considered; this also means that the first
   # element cannot be greater than sqrt($n)
   sub factor-in-pairs ($n) {
      (1 .. sqrt($n))            # first element 1 .. sqrt($n)
         .grep({$n %% $_})       # make sure first element divides $n
         .map({($_, $n / $_)});  # take it and its counterpart
   }

   # I know that gather/take is slow... but it's too cool
   gather {
      # https://en.wikipedia.org/wiki/Formulas_for_generating_Pythagorean_triples#Dickson's_method
      # parameter $r spans positive even integers
      R: # this marks the outer loop, for exiting lazy iteration
      for 2, 4, 6 ... Inf -> $r {
         for factor-in-pairs($r²/2) -> ($s, $t) {
            my @triple = ($r + $s, $r + $t, $r + $s + $t);

            # if the very first triple's first element is over $N,
            # our iteration is over because any element will be
            # greater than $N from now on
            last R if $s == 1 && $N < @triple[0];

            # only take the triple if it contains our target $N
            take @triple if $N == @triple.any;
         }
      }
   }
}

sub MAIN (Int:D $N = 5) {
   my @triples = pythagorean-triples($N);
   if @triples { put '(' ~ $_.join(', ') ~ ')' for @triples }
   else        { put -1 }
}
```

I hope the comments are enough to understand what's going on.

I've been told multiple times that `gather`/`take` is quite
*inefficient* but I still love the idea and I think it's anyway perfect
here, where I don't expect *too many* results to come out (as I
understand it, the performance penalty is linear with the number of
`take`s).

One note about the `take` line's condition, that was initially written
as:

```raku
take @triple if $N ~~ @triple;
```

I thought the smart matching would do *the right thing* here, but it
didn't, so I reverted to a more explicit [Junction][] `$N ==
@triple.any`. Go figure.

The corresponding code in [Perl][] is pretty much a straight
translation, taking into account that the two languages *have a few
differences*:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'first';

sub factor_in_pairs ($n) {
   map { [$_, $n / $_] } grep { !($n % $_) } 1 .. sqrt($n)
}

sub pythagorean_triples ($N) {
   my @retval;
   my $r = 0;
   R:
   while ('necessary') {
      $r += 2;
      for my $pair (factor_in_pairs($r * $r / 2)) {
         my ($s, $t) = $pair->@*;
         my @triple = ($r + $s, $r + $t, $r + $s + $t);
         last R if $s == 1 && $N < $triple[0];
         push @retval, \@triple if first { $N == $_ } @triple;
      }
   }
   return @retval;
}

my $N = shift // 5;
my @triples = pythagorean_triples($N);
if (@triples) { say '(' . join(', ', $_->@*) . ')' for @triples }
else          { say -1 }
```

Well... I guess it's enough for this post, have fun and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#125]: https://theweeklychallenge.org/blog/perl-weekly-challenge-125/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-125/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Pythagorean triples]: https://en.wikipedia.org/wiki/Pythagorean_triple
[formulas]: https://en.wikipedia.org/wiki/Formulas_for_generating_Pythagorean_triples
[dickson]: https://en.wikipedia.org/wiki/Formulas_for_generating_Pythagorean_triples#Dickson's_method
[Junction]: https://docs.raku.org/type/Junction
