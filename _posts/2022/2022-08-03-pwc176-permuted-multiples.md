---
title: PWC176 - Permuted Multiples
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-03 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#176][]. Enjoy!

# The challenge

> Write a script to find the smallest integer `x` such that `x`, `2x`,
> `3x`, `4x`, `5x` and `6x` are permuted multiples of each other.
>
> For example, the integers `125874` and `251748` are permutated
> multiples of each other as
>
>     251784 = 2 x 125874
>
> and also both have the same digits but in different order.
>
>
> **Output**
>
>     142857

# The questions

Just for sake of nitpicking, the solution to the challenge would be no
greater than `-142857`, which is a valid solution. Oh, maybe we're after
*positive integer* solutions 🤭

# The solution

We'll go brute force, of course, but with a little insight.

The first digit MUST be `1`. Anything greater than that would yield one
more digit when multiplied by `6`, so it would be out of luck.

Moreover, we need a number that is *at least* six digits long *and* they
must be different from one another. This what happens when you have a
leading `1` and you multiply it by `2`, `3`, and so on up to `6`.

Hence, our brute force journey starts at `123456`.

We might also note that the *maximum* number of six digits MUST be below
`166667`. From that number, a multiplication by `6` yields one more
digit, so it's out of luck.

A *loopy* [Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my $candidate = 123456;
   loop {
      if check-permuted-multiples-upto6($candidate) {
         put $candidate;
         last;
      }
      ++$candidate;
   }
}

sub check-permuted-multiples-upto6 ($n) {
   my $baseline = $n.comb.Set;
   for 2 .. 6 -> $factor {
      my $candidate = ($n * $factor).comb.Set;
      return False if $candidate (^) $baseline;
   }
   return True;
}
```

[Set][]s come to help here: we first build a reference one from the
number we're given as input (`$baseline`), then one for each multiple
(`$candidate`). To check whether they're the same or not, we compute the
*symmetric difference* and make sure it's empty - otherwise digits don't
match and we can move on.

Its translation into [Perl][] cannot leverage [Set][]s, but *hashes* are
pretty cool and we apply *mostly* the same approach, i.e. build a
reference `%baseline` and check multiples against it.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $candidate = 123456;
while ('necessary') {
   if (check_permuted_multiples_upto6($candidate)) {
      say $candidate;
      last;
   }
   ++$candidate;
}

sub check_permuted_multiples_upto6 ($n) {
   my %baseline = map { $_ => 1 } split m{}mxs, $n;
   for my $factor (2 .. 6) {
      for my $digit (split m{}mxs, $n * $factor) {
         return 0 unless exists $baseline{$digit};
      }
   }
   return 1;
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#176]: https://theweeklychallenge.org/blog/perl-weekly-challenge-176/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-176/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Set]: https://docs.raku.org/language/setbagmix
