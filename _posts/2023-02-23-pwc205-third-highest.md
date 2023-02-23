---
title: PWC205 - Third Highest
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#205][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find out the Third Highest if found otherwise return
> the maximum. **Example 1**
>
>     Input: @array = (5,3,4)
>     Output: 3
>
>     First highest is 5. Second highest is 4. Third highest is 3.
>
> **Example 2**
>
>     Input: @array = (5,6)
>     Output: 6
>
>     First highest is 6. Second highest is 5. Third highest is missing, so maximum is returned.
>
> **Example 3**
>
>     Input: @array = (5,4,4,3)
>     Output: 3
>
>     First highest is 5. Second highest is 4. Third highest is 3.

# The questions

Can an empty array still be considered an array of integers? If yes, the
we need to know what we should return/print in case we're given an empty
array as input.

# The solution

The approach will be straightforward: iterate through the array, keeping
track of the best three distinct values as we go, tossing away values
that we already have or that are less than what we kept so far, if we
already have three items.

The main *plot twist* is that the item we consider might change as we
go: if we find a better item for the first place, we put it in the first
place, then proceed to compare the item we removed with the next one
etc. It's not *exactly* optimal but it's reasonably close and simple to
implement.

[Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put third-highest(@args) }

sub third-highest (@array) {
   my @highest;
   ITEM:
   for @array -> $x is copy {
      for ^@highest -> $i {
         next ITEM if $x == @highest[$i];
         ($x, @highest[$i]) = @highest[$i], $x if $x > @highest[$i];
      }
      @highest.push: $x if @highest < 3;
   }
   return @highest == 3 ?? @highest[2]
        !! @highest > 0 ?? @highest[0]
        !!                 Nil;
}
```

Then [Perl][], translated from above:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say third_highest(@ARGV);

sub third_highest (@array) {
   my @highest;
   ITEM:
   for (@array) {
      my $x = $_; # work with a copy
      for my $i (0 .. $#highest) {
         next ITEM if $x == $highest[$i];
         ($x, $highest[$i]) = ($highest[$i], $x) if $x > $highest[$i];
      }
      push @highest, $x if @highest < 3;
   }
   return @highest == 3 ? $highest[2]
         : @highest > 0 ? $highest[0]
         :                 undef;
}
```

Thanks to [Mark Gardner][] for [pointing out][] that I can spare the `no
warnings 'experimental::signatures'` most of the times!

Stay safe and... cheers!




[The Weekly Challenge]: https://theweeklychallenge.org/
[#205]: https://theweeklychallenge.org/blog/perl-weekly-challenge-205/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-205/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Mark Gardner]: https://social.sdf.org/@mjgardner
[pointing out]: https://social.sdf.org/@mjgardner/109905760591840443
