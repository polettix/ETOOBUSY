---
title: PWC199 - Good Triplets
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-01-13 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#199][].
> Enjoy!

# The challenge

> You are given an array of integers, `@array` and three integers
> `$x`,`$y`,`$z`.
>
> Write a script to find out total `Good Triplets` in the given array.
>
> A triplet array[i], array[j], array[k] is good if it satisfies the
> following conditions:
>
>     a) 0 <= i < j < k <= n (size of given array)
>     b) abs(array[i] - array[j]) <= x
>     c) abs(array[j] - array[k]) <= y
>     d) abs(array[i] - array[k]) <= z
>
> **Example 1**
>
>     Input: @array = (3,0,1,1,9,7) and $x = 7, $y = 2, $z = 3
>     Output: 4
>     
>     Good Triplets are as below:
>     (3,0,1) where (i=0, j=1, k=2)
>     (3,0,1) where (i=0, j=1, k=3)
>     (3,1,1) where (i=0, j=2, k=3)
>     (0,1,1) where (i=1, j=2, k=3)
>
> **Example 2**
>
>     Input: @array = (1,1,2,2,3) and $x = 0, $y = 0, $z = 1
>     Output: 0

# The questions

Just to nit-pick a bit, I'd argue that condition *a)* is technically
correct although it might be misleading as it is a little too broad. It
allows one excess element from the array (both indexes `0` and `n` seem
to be included in the range).

I'll stop at `k = n - 1` anyway.

# The solution

I'm getting too old for this s...*tuff*.

I came out with the obvious $O(N^3)$ algorithm, but *I know* that there
must be something better.

Anyway.

[Perl][] goes first this time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my ($x, $y, $z, @list) = @ARGV ? @ARGV : (7, 2, 3, 3, 0, 1, 1, 9, 7);
say good_triplets($x, $y, $z, @list);

sub good_triplets ($x, $y, $z, @list) {
   my $count = 0;
   for my $i (0 .. $#list - 2) {
      for my $j ($i + 1 .. $#list - 1) {
         next if abs($list[$i] - $list[$j]) > $x;
         for my $k ($j + 1 .. $#list) {
            next if abs($list[$j] - $list[$k]) > $y
                 || abs($list[$i] - $list[$k]) > $z;
            ++$count;
         }
      }
   }
   return $count;
}
```

Then... [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($x, $y, $z, *@list) { put good-triplets($x, $y, $z, @list) }

sub good-triplets ($x, $y, $z, *@list) {
   return [+] gather for 0 .. (@list - 3) -> \i {
      for (i + 1) .. (@list - 2) -> \j {
         next if (@list[i] - @list[j]).abs > $x;
         for (j + 1) ..^ @list -> \k {
            next if (@list[j] - @list[k]).abs > $y
                 || (@list[i] - @list[k]).abs > $z;
            take 1;
         }
      }
   };
}
```

Yes, it leaves a bitter taste. Let's get some candy and move on.

Cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#199]: https://theweeklychallenge.org/blog/perl-weekly-challenge-199/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-199/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
