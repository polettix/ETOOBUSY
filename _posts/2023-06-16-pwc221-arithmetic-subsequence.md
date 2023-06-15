---
title: PWC221 - Arithmetic Subsequence
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-16 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#221][].
> Enjoy!

# The challenge

> You are given an array of integers, @ints.
>
> Write a script to find the length of the longest `Arithmetic Subsequence`
> in the given array.
>
>> A subsequence is an array that can be derived from another array by
>> deleting some or none elements without changing the order of the
>> remaining elements.
>>
>> A subsquence is arithmetic if ints[i + 1] - ints[i] are all the same
>> value (for 0 <= i < ints.length - 1).
>
> **Example 1:**
>
>     Input: @ints = (9, 4, 7, 2, 10)
>     Output: 3
>
>     The longest Arithmetic Subsequence (4, 7, 10) can be derived by deleting 9 and 2.
>
> **Example 2:**
>
>     Input: @ints = (3, 6, 9, 12)
>     Output: 4
>
>     No need to remove any elements, it is already an Arithmetic Subsequence.
>
> **Example 3:**
>
>     Input: @ints = (20, 1, 15, 3, 10, 5, 8)
>     Output: 4
>
>     The longest Arithmetic Subsequence (20, 15, 10, 5) can be derived by deleting 1, 3 and 8.

# The questions

My solution below is $O(n^3)$ and I'm not *enthusiast* about it. Sure
there's some search tree pruning here and there but still.

So my question is: how long are inputs expected to be? If *very* long, maybe
I should go back to the blackboard and think something more efficient.

For some languages, as usual, I'd probably ask about limits/assumptions
regarding the integers included in the array, so that big number libraries
might be included.

Last, in the main text I'd argue that `ints` is the whole array, but in the
explanation of what an arithmetic **sub**sequence is, it seems that it
applies to all elements (not only to the ones inside the sub-sequence).
Anyway, I think that the gist is clear.

# The solution

We iterate over all pairs, ordered by their appearance in the array; each of
these pairs is a candidate starting point for the subsequence we're after,
hence we calculate the difference and find all items in the same sequence
based on this difference. The code below is also peppered with a few checks
to shortcut the search if the specific sub-tree is not likely to produce an
enhancement to what we already found so far:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say arithmetic_subsequence(@ARGV);

sub arithmetic_subsequence (@ints) {
   my $n_inputs = @ints;
   return $n_inputs if $n_inputs < 3;
   my $max_len = 2;
   for my $i (0 .. $n_inputs - 3) {
      last if ($n_inputs - $i) <= $max_len; # can't find better
      for my $j ($i + 1 .. $n_inputs - 2) {
         last if (1 + $n_inputs - $j) <= $max_len; # can't find better
         my $step = $ints[$j] - $ints[$i];
         my $next = $ints[$j] + $step;
         my $this_len = 2;
         for my $k ($j + 1 .. $n_inputs - 1) {
            last if ($this_len + $n_inputs - $k) <= $max_len; # ...
            next if $ints[$k] != $next;
            ++$this_len;
            $next += $step;
         }
         $max_len = $this_len if $this_len > $max_len;
      }
   }
   return $max_len;
}
```

The [Raku][] alternative is as lazy as it can be, not in terms of all the
*lazy* goods that this fantastic language gives us, but in the sense that I
just translated the [Perl][] code above as necessary to adapt to the new
syntax:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@ints) { put arithmetic-subsequence(@ints) }

sub arithmetic-subsequence (@ints) {
   my $n-inputs = @ints.elems;
   return $n-inputs if $n-inputs < 3;
   my $max-len = 2;
   for ^($n-inputs - 2) -> $i {
      last if ($n-inputs - $i) <= $max-len; # can't find better
      for $i ^..^ ($n-inputs - 1) -> $j {
         last if (1 + $n-inputs - $j) <= $max-len; # can't find better
         my $step = @ints[$j] - @ints[$i];
         my $next = @ints[$j] + $step;
         my $this-len = 2;
         for  $j ^..^ $n-inputs -> $k {
            last if ($this-len + $n-inputs - $k) <= $max-len; # ...
            next if @ints[$k] != $next;
            ++$this-len;
            $next += $step;
         }
         $max-len = $this-len if $this-len > $max-len;
      }
   }
   return $max-len;
}
```

I guess this is it for this week... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#221]: https://theweeklychallenge.org/blog/perl-weekly-challenge-221/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-221/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
