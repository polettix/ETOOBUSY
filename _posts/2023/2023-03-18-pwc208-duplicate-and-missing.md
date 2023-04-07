---
title: PWC208 - Duplicate and Missing
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-18 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#208][].
> Enjoy!

# The challenge

> You are given an array of integers in sequence with one missing and one
> duplicate.
>
> Write a script to find the duplicate and missing integer in the given
> array. Return -1 if none found.
>
> For the sake of this task, let us assume the array contains no more than
> one duplicate and missing.
>
> **Example 1:**
>
>     Input: @nums = (1,2,2,4)
>     Output: (2,3)
>
>     Duplicate is 2 and Missing is 3.
>
> **Example 2:**
>
>     Input: @nums = (1,2,3,4)
>     Output: -1
>
>     No duplicate and missing found.
>
> **Example 3:**
>
>     Input: @nums = (1,2,3,3)
>     Output: (3,4)
>
>     Duplicate is 3 and Missing is 4.

# The questions

This issue sparked so many questions that there must be something wrong
*somewhere*. I mean, either I've become increasingly *soft* lately, sparing
our fine host [manwar][] of my usual useless nitpicking, or he decided to
throw me a bone just to have a good laugh.

Anyway.

All examples seem to start at 1. Is this a general rule? It's not in the
rules, so I guess it's a coincidence and will not assume this.

Is the "sequence" in the input array supposed to be an arithmetic
progression with common difference equal to 1? I mean, any sequence is a
sequence 🙄

The last example seems to imply that not finding the missing element
*within* the array is still OK, because it must be the one immediately
following. Why not the one immediately before (like 0 in the example)?

How are we supposed to return/print the two elements, if present? Should it
always be *duplicate first, then missing*? Or in the order of their
detection (which also happens to be their order of discovery, assuming that
the *missing missing* is the one immediately after)?

Is there any assumption that can be done about the position of the
duplicates and missing elements? I mean, are their positions totally random
and not correlated to one another, or anything else?

Is the sequence mostly short, or should we cope with very long sequences?

# The solution

The last two questions come from my strong tendency to over-engineer. I
mean...

- if the inputs are very long...
- ... and the distribution of the duplicates and missing are random and not
  correlated...

it might make sense to think about optimizing the solution with some
adaptation of a binary search and linear search below a certain point.

> Why "not correlated"? If the missing always occurs very close to the
> duplicate, it's very hard to spot the division points by binary search, so
> it would just make sense to do a linear search.

Anyway, let's assume it remains at the toy level, so we will only focus on
the linear search, right?

Let's start with [Perl][] first. We can assume that the input is OK, but
given all other questions... *can we trust these assumptions?!?* Let the
user (partially) decide!

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

our $SHORT_CIRCUIT = $ENV{SHORT_CIRCUIT} // 1;
if (my @dam = duplicate_and_missing(@ARGV)) {
   local $" = ',';
   say "(@dam)";
}
else {
   say -1;
}

sub duplicate_and_missing (@list) {
   my ($duplicate, $missing, @retval);
   for my $i (1 .. $#list) {
      if ($list[$i] == $list[$i - 1]) {
         die "too many duplicates ($duplicate, $list[$i])\n"
            if defined $duplicate;
         push @retval, $duplicate = $list[$i];
      }
      elsif ($list[$i] == $list[$i - 1] + 2) {
         my $miss = $list[$i] - 1;
         die "too many missing ($missing, $miss)\n" if defined $missing;
         push @retval, $missing = $miss;
      }
      elsif ($list[$i] != $list[$i - 1] + 1) {
         die "unexpected gap\n";
      }
      else {} # just a simple increment
      return @retval if @retval == 2 && our $SHORT_CIRCUIT;
   }
   return unless defined($duplicate);
   push @retval, $list[-1] + 1 unless @retval == 2;
   return @retval;
}
```

The [Raku][] version can appear to be... *disappointing*. I nknow there must
be more idiomatic ways of putting it, but using them at every cost might be
bad for *my* readability, so let's not pull the rope too much!

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @dam = duplicate-and-missing(@args, %*ENV<SHORT_CIRCUIT>);
   put @dam ?? "({@dam.join(',')})" !! -1;
}

sub duplicate-and-missing (@list, $short-circuit is copy = Nil) {
   $short-circuit //= True;
   my ($duplicate, $missing, @retval);
   for 1 ..^ @list -> $i {
      if @list[$i] == @list[$i - 1] {
         die "too many duplicates ($duplicate, {@list[$i]})\n"
            if defined $duplicate;
         @retval.push: $duplicate = @list[$i];
      }
      elsif (@list[$i] == @list[$i - 1] + 2) {
         my $miss = @list[$i] - 1;
         die "too many missing ($missing, $miss)\n" if defined $missing;
         @retval.push: $missing = $miss;
      }
      elsif (@list[$i] != @list[$i - 1] + 1) {
         die "unexpected gap\n";
      }
      else {} # just a simple increment
      return @retval if @retval == 2 && $short-circuit;
   }
   return [] unless defined($duplicate);
   @retval.push(@list[*-1] + 1) unless @retval == 2;
   return @retval;
}
```

I guess it's everything for this post, stay safe folks!



[The Weekly Challenge]: https://theweeklychallenge.org/
[#208]: https://theweeklychallenge.org/blog/perl-weekly-challenge-208/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-208/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
