---
title: PWC098 - Search Insert Position
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-02-04 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#098][].
> Enjoy!

# The challenge

> You are given a sorted array of distinct integers `@N` and a target
> `$N`. Write a script to return the index of the given target if found
> otherwise place the target in the sorted array and return the index.

# The questions

My issue with this question is in *interpretation*.

What do we mean with *place the target in the sorted array*? Should we
*ideally* place it to figure out where it would end up, or should we
*factually* modify array `@N`? I'd say the latter, but the fact that we
have to write a *script*, with an input interface that is somehow fuzzy
makes me wonder if I'm understanding this wrong.

# The solution

I'll surely win the prize for the *most boring solution*, but there
might be a twist or two.

First of all, as I'm obsessed with algorithm efficiency, looking for the
index in a sorted away for means doing a [binary search][]. Not much of
a gain in a situation with only a few item - possibly the contrary - but
still.

To this regard we keep two variables `$lo` and `$hi` to track the
*boundaries* of the array sub-section we are focusing on, starting from
the whole array and halving the size of the range at each step.

```perl
sub search_insert_position ($aref, $new_item) {
   my ($lo, $hi, $i) = (0, $aref->$#*, undef);
   while ('necessary') {
      $i = int(($lo + $hi) / 2);
      my $item = $aref->[$i];
      if ($new_item == $item)   { return $i }
      elsif ($new_item < $item) { $hi = $i }
      else                      { $lo = $i }
      last if ($hi - $lo) <= 1;
   }
   splice $aref->@*, $i, 0, $new_item;
   return $i;
}
```

There's a bit of stylistic dissonance in this code, in that the `while`
loop is actually a `do ... while` loop, to ensure that we have at least
one pass. I don't like writing `do ... while` loops in [Perl][] though
(and I usually avoid [do][] if I can, even the block version), so this
is how write it.

There are two ways to exit from the loop:

- we hit the number we're looking for, in which case we `return $i` on
  the spot, OR
- we do not find the number, so `$i` is our indicator of where it should
  belong.

To put the new item inside the array, we are relying on [Perl][] function
[splice][], which is in my opinion an unsung hero (or simply a tool that
one rarely has to really use). It allows us to say *add this item in
this position, shifting all following items ahead*. The only caveat here
is that we are not *removing* anything (as the verb *splice* might
imply), so the length of the sub-list we want to remove is... `0`.

Here is the full code, should you be curious about it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub search_insert_position ($aref, $new_item) {
   my ($lo, $hi, $i) = (0, $aref->$#*, undef);
   while ($lo <= $hi) {
      $i = int(($lo + $hi) / 2);
      my $item = $aref->[$i];
      if ($new_item == $item)   { return $i }
      elsif ($new_item < $item) { $hi = $i }
      else                      { $lo = $i }
      last if ($hi - $lo) <= 1;
   }
   splice $aref->@*, $i, 0, $new_item;
   return $i;
}

my $N = @ARGV ? shift @ARGV : 3;
my @N = @ARGV ? @ARGV : qw< 1 2 3 4 >;
my $i = search_insert_position(\@N, $N);
say "$i -> (@N)";
```

Have a good time!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#098]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-098/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-098/#TASK2
[Perl]: https://www.perl.org/
[binary search]: https://en.wikipedia.org/wiki/Binary_search_algorithm
[do]: https://perldoc.perl.org/functions/do
[splice]: https://perldoc.perl.org/functions/splice
