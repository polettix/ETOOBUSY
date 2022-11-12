---
title: PWC130 - Odd Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-15 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#130][]. Enjoy!

# The Challenge

> You are given an array of positive integers, such that all the numbers
> appear even number of times except one number.
>
> Write a script to find that integer.
>
> **Example 1**
>
>     Input: @N = (2, 5, 4, 4, 5, 5, 2)
>     Output: 5 as it appears 3 times in the array where as all other numbers 2 and 4 appears exactly twice.
>
> **Example 2**
>
>     Input: @N = (1, 2, 3, 4, 3, 2, 1, 4, 4)
>     Output: 4

# The Questions

From an interview's point of view, I think that one question might be
how many items we expect to receive as inputs. It is explicitly stated
that they come from an array, so it should be something manageable in
memory and should not need to resort to any fancy way of dealing with a
huge amount of input data. The solution, anyway, assumes that it's OK to
track the different input numbers with a hash of flags, which might grow
as much as about one half of the number of element of the input array.

# The Solution

We will try to solve a slightly wider problem, i.e. finding all elements
that appear an odd number of times inside the input array.

To do this, we use a hash to keep track all items that appear an odd
number of times. This is initially empty, because by default all numbers
appear 0 times, i.e. an even number of times. We then start iterating
over the provided array:

- if the element is in the hash, it means that so far we spotted it an
  odd number of times. With this particular instance, it makes an even
  number of times, so we remove the item from the hash;
- if the item is not present, it either never appeared, or it was
  removed in a previous iteration, so we put it in the hash because this
  occurrence is an odd one.

When we go past the last element, the hash contains keys for all items
that appear an odd number of times. If the input is compliant with the
requirements... it will also be the only one.

This is the implementation in [Raku][]:

```raku
#!/usr/bin/env raku

sub odd-number (*@inputs) {
   my %is-odd;
   for @inputs -> $element {
      if %is-odd{$element} { %is-odd{$element}:delete }
      else                 { %is-odd{$element} = 1    }
   }
   return %is-odd.keys;
}

sub MAIN (*@inputs) {
   @inputs = 2, 5, 4, 4, 5, 5, 2 unless @inputs;
   put odd-number(@inputs);
}
```

The translation in [Perl][] is straightforward:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub odd_number (@inputs) {
   my %is_odd;
   for my $element (@inputs) {
      if ($is_odd{$element}) { delete $is_odd{$element} }
      else                   { $is_odd{$element} = 1    }
   }
   return keys %is_odd;
}

my @inputs = @ARGV ? @ARGV : (2, 5, 4, 4, 5, 5, 2);
say odd_number(@inputs);
```

I guess it's everything at this point... stay safe everyone!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#130]: https://theweeklychallenge.org/blog/perl-weekly-challenge-130/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-130/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
