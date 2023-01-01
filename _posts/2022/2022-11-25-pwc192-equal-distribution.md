---
title: PWC192 - Equal Distribution
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

**OR: don't be so negative!**

> On with [TASK #2][] from [The Weekly Challenge][] [#192][].
> Enjoy!

# The challenge

> You are given a list of integers greater than or equal to zero,
> `@list`.
>
> Write a script to distribute the number so that each members are same.
> If you succeed then print the total moves otherwise print -1.
>
> Please follow the rules (as suggested by `Neils van Dijke`
> \[2022-11-21 13:00\]
>
>     1) You can only move a value of '1' per move
>     2) You are only allowed to move a value of '1' to a direct neighbor/adjacent cell
>
> **Example 1:**
>
>     Input: @list = (1, 0, 5)
>     Output: 4
>
>     Move #1: 1, 1, 4
>     (2nd cell gets 1 from the 3rd cell)
>
>     Move #2: 1, 2, 3
>     (2nd cell gets 1 from the 3rd cell)
>
>     Move #3: 2, 1, 3
>     (1st cell get 1 from the 2nd cell)
>
>     Move #4: 2, 2, 2
>     (2nd cell gets 1 from the 3rd cell)
>
> **Example 2:**
>
>     Input: @list = (0, 2, 0)
>     Output: -1
>
>     It is not possible to make each same.
>
> **Example 3:**
>
>     Input: @list = (0, 3, 0)
>     Output: 2
>
>     Move #1: 1, 2, 0
>     (1st cell gets 1 from the 2nd cell)
>
>     Move #2: 1, 1, 1
>     (3rd cell gets 1 from the 2nd cell)

# The questions

Our fine host [manwar][] is finding new ways of being creative *and*
inclusive, so this time he handed over rules description to Neils van
Dkjke. Excellent job both!

I might regret asking this question, but why only non-negative integers?

Another question --and this is serious-- are we supposed to find the
*minimum* number of steps if the **equal distribution** can be done? It
seems... not! I'll try to aim at it, anyway.

# The solution

This. Was. Fun.

I started thinking of complex algorithms for finding the best place to
put stuff, *this might go here, but what if that is closer* when it
suddenly appeared.

Let's start from the far left. Suppose we have a spare unit that we have
to reallocate somewhere. The optimal choice is to find the closer gap
going rightwards, and this also moves us closer to an optimal solution.

How come? Suppose there's another spare unit *somewhere*. For equal
distribution to be feasible, then there must be another empty slot
somewhere else. If this additional spare unit is left of the first slot,
then using it for the leftmost leads us to a solution that has the same
cost as not doing this. On the other hand, if it's on the right of the
leftmost empty slot, then using it for the leftmost spare unit is going
to save us some steps (at least one).

The first case is like this:

```
Spare         Spare   Gap           Gap
  1             2      1             2

  XX            XX
  XX     XX     XX            XX
  XX     XX     XX     XX     XX     XX
  XX     XX     XX     XX     XX     XX
```

Using Spare 1 to fill in Gap 1 costs 3 moves, which means that we spend
other 3 moves to use Spare 2 to fill Gap 2, for a total of 6 moves.
Doing this in reverse order means that we move Spare 2 for 1 step, and
Spare 1 for 5 steps, for a total of 6 steps again. Hence, our strategy
of filling the leftmost gap (Gap 1) with the leftmost Spare (Gap 2) is
optimal in this case.

Let's not consider the second case:

```
Spare          Gap   Spare          Gap
  1             1      2             2

  XX                   XX
  XX     XX            XX     XX
  XX     XX     XX     XX     XX     XX
  XX     XX     XX     XX     XX     XX
```

Our strategy costs us 4 moves (2 + 2); the reverse strategy costs 6 (5
to send Spare 1 to Gap 2, 1 to send Spare 2 into Gap 1). So, our
strategy wins.

Iterate, and we have an optimal strategy.

So OK, now we have a strategy, but do we have an *algorithm*? An
*efficient algorithm*?

If we address one spare and gap matching at a time, we surely don't as
this more or less scales like $O(DN)$, where $D$ is the number of
displaced elements and $N$ is the number of slots in the list.

On the other hand, our strategy tells us that going from left to right
*works*. So we'll just organize a bus tour from left to right: at each
stop, we either take passengers onboard (when there are spare ones), or
we do nothing (when the slot has the right number of elements), or we
drop passengers (to fill the gaps).

Only... *what do we do if the gap is left of the spare*? No worries!
We'll leave one real passenger in the gap, taking onboard a *negative
passenger*, and then we'll fill in the negative passenger later when we
stop at the slot with the spare one. We have anti-matter, why can't we
have *anti-passengers*?!?

OK, shut the fun up and show the code time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

my @inputs = map { split m{[\s,]+}mxs } @ARGV;
@inputs = qw< 1 0 5 > unless @inputs;

say equal_distribution(@inputs);

sub equal_distribution (@inputs) {
   my $total = sum(@inputs);
   return -1 if $total % @inputs;
   my $average = $total / @inputs;
   my ($delta, $moves) = (0, 0);
   for my $value (@inputs) {
      $moves += abs($delta);
      $delta += $value - $average;
   }
   return $moves;
}
```

Variable `$delta` tells us how many positive or negative passengers we
have onboard. Each bus stop, anyway, counts one move for either ones, so
we consider the absolute value to count the overall number of `$moves`.

[Raku][] time:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @inputs = @args».split(/<[ \s , ]>+/).Slip.flat;
   @inputs = <1 0 5> unless @inputs;
   put equal-distribution(@inputs);
}

sub equal-distribution (@inputs) {
   my $total = @inputs.sum;
   return -1 unless $total %% @inputs;
   my $average = ($total / @inputs).Int;
   my ($delta, $moves) = 0, 0;
   for @inputs -> $value {
      $moves += $delta.abs;
      $delta += $value - $average;
   }
   return $moves;
}
```

Bonus point if you can guess how long it took me to figure the right
incantation of `Slip` and `flat` this time.

I almost forgot to mention that the failure case when there is no *equal
distribution* can be tackled by simply checking if the sum of all items
can be divided evenly among the available slots.

This algorithm now goes $O(N)$, because we have one full initial sweep
to find the amount of elements that should end up in each slot, plus
another full sweep of the bus going from left to right.

Stay safe and beware the anti-passengers that are suspiciously similar
to you... you might annihilate one another!



[The Weekly Challenge]: https://theweeklychallenge.org/
[#192]: https://theweeklychallenge.org/blog/perl-weekly-challenge-192/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-192/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
