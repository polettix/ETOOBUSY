---
title: PWC144 - Ulam Sequence
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#144][].
> Enjoy!

# The challenge

> You are given two positive numbers, `$u` and `$v`.
>
> Write a script to generate `Ulam Sequence` having at least 10 `Ulam
> numbers` where `$u` and `$v` are the first 2 `Ulam numbers`.
>
> For more information about `Ulam` Sequence, please checkout the
> [website][].
>
>> The standard Ulam sequence (the (1, 2)-Ulam sequence) starts with U1
>> = 1 and U2 = 2. Then for n > 2, Un is defined to be the smallest
>> integer that is the sum of two distinct earlier terms in exactly one
>> way and larger than all earlier terms.
>
> **Example 1**
>
>     Input: $u = 1, $v = 2
>     Output: 1, 2, 3, 4, 6, 8, 11, 13, 16, 18
>
> **Example 2**
>
>     Input: $u = 2, $v = 3
>     Output: 2, 3, 5, 7, 8, 9, 13, 14, 18, 19
>
> **Example 3**
>
>     Input: $u = 2, $v = 5
>     Output: 2, 5, 7, 9, 11, 12, 13, 15, 19, 23

# The questions

It seems that our fine host decided that enough is enough with these
questions and discovered the joys of delegation. Very well played, Mr.
Anwar, very well played indeed...

# The solution

OK, let's start with [Perl][]. In one word: **iterator**.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub ulam_iterator ($v, $w) {
   my @items = ($v, $w);
   my $n = 0;
   return sub {
      ITEM:
      while ($n > $#items) {
         my %count;
         for my $i (0 .. $#items - 1) {
            for my $j (reverse($i + 1 .. $#items)) {
               my $sum = $items[$i] + $items[$j];
               last if $sum <= $items[-1];
               $count{$sum}++;
            }
         }
         for my $new (sort { $a <=> $b } keys %count) {
            next unless $count{$new} == 1;
            push @items, $new;
            next ITEM;
         }
      }
      return $items[$n++];
   };
}

my @seeds = @ARGV == 2 ? @ARGV : (1, 2);
my $it = ulam_iterator(@seeds);
say join ', ', map { $it->() } 1 .. 10;
```

The `ulam_iterator` function returns... an iterator function. I guess
you saw it coming.

At each call, we generate (if needed) a new element until we have
enough, and return the first that was not returned in a previous round.
Adding one new item implies:

- finding the number of ways a sum can appear
- isolating the minimum of all sums that appear only once.

For the [Raku][] counterpart we reuse a big chunk of the implementation
BUT using a proper `Class` instead of an anonymous function.

```raku
#!/usr/bin/env raku
use v6;

class Ulam {
   has @!items is built;
   has $!n = 0;

   method new ($v, $w) { self.bless(items => [$v, $w]) }

   method next () {
      ITEM:
      while $!n > @!items.end {
         @!items.push: (@!items X @!items).grep({ $_[0] < $_[1] })
            .map({$_.sum}).grep({$_ > @!items[*-1]})
            .Bag.pairs.grep({.value == 1}).map({.key}).min;
      }
      return @!items[$!n++];
   }
}

sub MAIN (*@args) {
   my ($v, $w) = @args.elems == 2 ?? @args !! (1, 2);
   my $ulam = Ulam.new($v, $w);
   (1..10).map({$ulam.next}).join(', ').put;
}
```

There are a lot of tools this time:

- we use a cross product `X` to generate all pairs;
- filter out the ones we don't like (avoiding repetionts);
- turn them into sums and keeping only the sums beyond the last
  generated Ulam number;
- getting the minimum of those occurring only once, with a little help
  from [Bag][] and other support functions.

I guess I abused of your time enough... stay safe and have `-Ofun`!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#144]: https://theweeklychallenge.org/blog/perl-weekly-challenge-144/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-144/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[website]: https://en.wikipedia.org/wiki/Ulam_number
[Bag]: https://docs.raku.org/type/Bag
