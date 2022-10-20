---
title: PWC187 - Magical Triplets
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-10-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#187][].
> Enjoy!

# The challenge

> You are given a list of positive numbers, `@n`, having at least 3
> numbers.
>
> Write a script to find the triplets `(a, b, c)` from the given list
> that satisfies the following rules.
>
>     1. a + b > c
>     2. b + c > a
>     3. a + c > b
>     4. a + b + c is maximum.
>
> In case, you end up with more than one triplets having the maximum
> then pick the triplet where a >= b >= c.
>
> **Example 1**
>
>     Input: @n = (1, 2, 3, 2);
>     Output: (3, 2, 2)
>
> **Example 2**
>
>     Input: @n = (1, 3, 2);
>     Output: ()
>
> **Example 3**
>
>     Input: @n = (1, 1, 2, 3);
>     Output: ()
>
> **Example 4**
>
>     Input: @n = (2, 4, 3);
>     Output: (4, 3, 2)

# The questions

From a very *generic* point of view, I'd argue that the disambiguation
about the triple to select *might* leave out corner cases where there
might be two triangles with the same perimeter but different side
lenghts. On the other hand, I had a hard time coming up with an example
where this perimeter is *maximal*, so I guess this condition might not
appear practically. Anyway... at least a hat tip would have helped!

# The solution

I guess there's a ton to optimize but we'll assume a small bunch of
numbers here and no up-front optimization..

The basic approach will be the following:

- find out all possible triplets, drawing three elements at any time;
- verify each triple is indeed a triangle and calculate its perimeter;
- select the triple with the highest sum

Let's start with [Perl][] first, leveraging the [Combinations
iterator][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @result = magical_triplets(@ARGV);
say '(', join(', ', @result), ')';

sub magical_triplets (@n) {
   my $it = combinations_iterator(3, @n);
   my ($best, $best_score);
   while (my ($combination, $complement) = $it->()) {
      my $score = is_triangle($combination->@*) or next;
      ($best, $best_score) = ($combination, $score)
         if (! defined $best) || ($best_score < $score);
   }
   return reverse sort {$a <=> $b} ($best // [])->@*;
}

sub is_triangle ($A, $B, $C) {
   return 0 if
      $A >= $B + $C
      || $B >= $C + $A
      || $C >= $A + $B;
   return $A + $B + $C;
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
      return (\@combination, \@remaining);
   }
}
```

The translation into [Raku][] is pretty much literal, with a couple
exceptions:

- finding out combinations is part of the language, yay!
- I couldn't figure out how to pass an array's content as three
  individual variables to a sub, so I had to unpack the input array in a
  very old-Perl5-style.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put magical-triplets(@args) }

sub magical-triplets (@n) {
   my ($best, $best-score);
   for @n.combinations(3) -> $comb {
      my $score = is-triangle($comb) or next;
      ($best, $best-score) = ($comb, $score)
         if (! defined $best) || ($best-score < $score);
   }
   $best //= [];
   return $best.sort({$^a <=> $^b}).reverse;
}

sub is-triangle ($x) {
   my ($A, $B, $C) = @$x;
   return 0 if
      $A >= $B + $C
      || $B >= $C + $A
      || $C >= $A + $B;
   return $A + $B + $C;
}
```

I like that the solution comes out so compact anyway.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#187]: https://theweeklychallenge.org/blog/perl-weekly-challenge-187/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-187/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Combinations iterator]: {{ '/2021/04/24/combinations-iterator/' | prepend: site.baseurl }}
