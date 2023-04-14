---
title: PWC212 - Rearrange Groups
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-04-14 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#212][].
> Enjoy!

# The challenge

> You are given a list of integers and group size greater than zero.
>
> Write a script to split the list into equal groups of the given size where
> integers are in sequential order. If it can’t be done then print `-1`.
>
> **Example 1:**
>
>     Input: @list = (1,2,3,5,1,2,7,6,3) and $size = 3
>     Output: (1,2,3), (1,2,3), (5,6,7)
>
> **Example 2:**
>
>     Input: @list = (1,2,3) and $size = 2
>     Output: -1
>
> **Example 3:**
>
>     Input: @list = (1,2,4,3,5,3) and $size = 3
>     Output: (1,2,3), (3,4,5)
>
> **Example 4:**
>
>     Input: @list = (1,5,2,6,4,7) and $size = 3
>     Output: -1

# The questions

I have no specific questions, possibly apart from... *do we have some
freedom for the output shape?*

Asking for a friend who would like to use `say` in [Raku][]... 🙄


# The solution

This was an interesting and non-trivial task, in my opinion. The different
groups might overlap completely or partially, hence it's a matter of forming
them and see if it's possible. Unless, of course, there's a better trick to
do this.

In the implementations below (the [Raku][] one is basically a translation of
the [Perl][] code), I'm first analyzing data by counting how many copies I
have of each input integer, saving pairs of value and occurrences in
increasing order. So this example input:

```
@list = (1,2,3,5,1,2,7,6,3)
```

becomes this:

```
@inputs = ([1, 2], [2, 2], [3, 2], [5, 1], [6, 1], [7, 1]);
```

i.e. the number `1` occurs `2` times, etc up to the number `7` occurs `1`
time.

At this point, we iterate as much as needed over this data structure,
picking values as we go and making sure that they are consecutive as we form
each individual group. To make these consecutive visits a bit more
efficient, we get rid of pairs as the become exhausted.

Enough talking, let's go to the code:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

@ARGV = (3, 1, 2, 3, 5, 1, 2, 7, 6, 3) unless @ARGV;
if (my @rearranged = rearrange_groups(@ARGV)) {
   say join ', ', map { '(' . join(',', $_->@*) . ')' } @rearranged;
}
else {
   say -1;
}

sub rearrange_groups ($size, @list) {
   return if @list % $size;

   my @inputs;
   for my $item (sort { $a <=> $b } @list) {
      push @inputs, [$item, 0] if (!@inputs) || ($item != $inputs[-1][0]);
      $inputs[-1][1]++;
   }

   my $n_groups = @list / $size;
   my @groups;
   for (1 .. $n_groups) {
      push @groups, \my @group;
      my $cursor = 0;
      for (1 .. $size) {
         return if $cursor > $#inputs; # failed!
         my $candidate = $inputs[$cursor][0];
         return if @group && $candidate != $group[-1] + 1;
         push @group, $candidate;
         $inputs[$cursor][1]--;
         if ($inputs[$cursor][1] <= 0) {
            splice @inputs, $cursor, 1;
         }
         else {
            ++$cursor;
         }
      }
   }

   return @groups;
}
```

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   @args = 3, 1, 2, 3, 5, 1, 2, 7, 6, 3 unless @args;
   my $size = @args.shift;
   if (my $rearranged = rearrange-groups($size, @args)) {
      say $rearranged;
   }
   else {
      put -1;
   }
}

sub rearrange-groups ($size, @list) {
   return if @list.elems % $size;

   my @inputs;
   for @list».Int.sort -> $item {
      @inputs.push: [$item, 0] if (!@inputs) || ($item != @inputs[*-1][0]);
      @inputs[*-1][1]++;
   }

   my $n-groups = @list.elems div $size;
   my @groups;
   for ^$n-groups {
      my @group;
      my $cursor = 0;
      for ^$size {
         return if $cursor > @inputs.end; # failed!
         my $candidate = @inputs[$cursor][0];
         return if @group && $candidate != @group[*-1] + 1;
         @group.push: $candidate;
         @inputs[$cursor][1]--;
         if (@inputs[$cursor][1] <= 0) {
            @inputs.splice($cursor, 1);
         }
         else {
            ++$cursor;
         }
      }
      @groups.push: @group;
   }

   return @groups;
}
```

Stay safe!!!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#212]: https://theweeklychallenge.org/blog/perl-weekly-challenge-212/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-212/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
