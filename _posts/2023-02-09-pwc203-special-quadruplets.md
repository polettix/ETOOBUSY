---
title: PWC203 - Special Quadruplets
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#203][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find out the total special quadruplets for the given
> array.
>
>     Special Quadruplets are such that satisfies the following 2 rules.
>     1) nums[a] + nums[b] + nums[c] == nums[d]
>     2) a < b < c < d
>
> **Example 1**
>
>     Input: @nums = (1,2,3,6)
>     Output: 1
>
>     Since the only special quadruplets found is $nums[0] + $nums[1] + $nums[2] == $nums[3].
>
> **Example 2**
>
>     Input: @nums = (1,1,1,3,5)
>     Output: 4
>
>     $nums[0] + $nums[1] + $nums[2] == $nums[3]
>     $nums[0] + $nums[1] + $nums[3] == $nums[4]
>     $nums[0] + $nums[2] + $nums[3] == $nums[4]
>     $nums[1] + $nums[2] + $nums[3] == $nums[4]
>
> **Example 3**
>
>     Input: @nums = (3,3,6,4,5)
>     Output: 0

# The questions

How can [manwar][] find such sweet spots? I was starting to think that
this would be sort of a chore... but it ended up to allow for a very
intuitive solution.

# The solution

Instead of doing a lot of nested iterations and the like, let's just
think that we can test all possible *combinations* of 4 elements out of
the input array, looking for those where the first three items sum to
the fourth. We're lucky that [Raku][] has `combinations` out of the box!

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put special-quadruplets(@args) }

sub special-quadruplets (@nums) {
   combinations(@nums, 4).grep({$_[0..2].sum == $_[3]}).elems
}
```

In [Perl][] it will take some more effort... with the help of
copy-and-paste from the [Combinations iterator][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

say special_quadruplets(@ARGV);

sub special_quadruplets (@nums) {
   my $it = combinations_iterator(4, @nums);
   my $count = 0;
   while (my ($c, undef) = $it->()) {
      ++$count if sum($c->@[0..2]) == $c->[3];
   }
   return $count;
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

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#203]: https://theweeklychallenge.org/blog/perl-weekly-challenge-203/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-203/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Combinations iterator]: {{ '/2021/04/24/combinations-iterator/' | prepend: site.baseurl }}
