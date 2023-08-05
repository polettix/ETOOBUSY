---
title: PWC228 - Unique Sum
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-08-05 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#228][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find out the sum of unique elements in the given
> array.
>
> **Example 1**
>
>     Input: @int = (2, 1, 3, 2)
>     Output: 4
>
>     In the given array we have 2 unique elements (1, 3).
>
> **Example 2**
>
>     Input: @int = (1, 1, 1, 1)
>     Output: 0
>
>     In the given array no unique element found.
>
> **Example 3**
>
>     Input: @int = (2, 1, 3, 4)
>     Output: 10
>
>     In the given array every element is unique.

# The questions

What are the limits of the inputs, in terms of values and how many of
them could appear in the array?

# The solution

The questions can be important for the implementation. We will do like
this:

- track the result, starting from 0;
- when a number appears the first time, we add it to the result;
- when it appears the second time, it is subtracted;
- any other time it appears, it is ignored.

This means that the accumulated, intermediate result might grow *a lot*
big even though the final result might be much smaller.

Anyway, let's move on with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put unique-sum(@args) }

sub unique-sum (@ints) {
   my $retval = 0;
   my $seen = BagHash.new;
   for @ints -> $x {
      given $seen{$x}++ {
         $retval += $x when 0;
         $retval -= $x when 1;
      }
   }
   return $retval;
}
```

We're using a [BagHash][] here because it's kind of the right data
structure, but any hash would do as we can see in the [Perl][]
alternative:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say unique_sum(@ARGV);

sub unique_sum (@ints) {
   my $retval = 0;
   my %seen;
   for my $x (@ints) {
      my $previous = $seen{$x}++ // 0;
      $retval += $x unless $previous;
      $retval -= $x if $previous == 1;
   }
   return $retval;
}
```

The alternative solution might be to first filter out all elements with
a duplicate, then do the sum. This means allocating possibly a lot of
space... so there we go, it's *either*/*or*. Well, unless a different
algorithm can be found, of course!

Stay safe and cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#228]: https://theweeklychallenge.org/blog/perl-weekly-challenge-228/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-228/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[BagHash]: https://docs.raku.org/language/setbagmix
