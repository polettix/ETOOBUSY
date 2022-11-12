---
title: PWC127 - Conflict Intervals
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-26 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#127][].
> Enjoy!

# The challenge

> You are given a list of intervals.
> 
> Write a script to find out if the current interval conflicts with any
> of the previous intervals.
> 
> **Example**
>
>     Input: @Intervals = [ (1,4), (3,5), (6,8), (12, 13), (3,20) ]
>     Output: [ (3,5), (3,20) ]
>     
>         - The 1st interval (1,4) do not have any previous intervals to compare with, so skip it.
>         - The 2nd interval (3,5) does conflict with previous interval (1,4).
>         - The 3rd interval (6,8) do not conflicts with any of the previous intervals (1,4) and (3,5), so skip it.
>         - The 4th interval (12,13) again do not conflicts with any of the previous intervals (1,4), (3,5) and (6,8), so skip it.
>         - The 5th interval (3,20) conflicts with the first interval (1,4).
>     
>     Input: @Intervals = [ (3,4), (5,7), (6,9), (10, 12), (13,15) ]
>     Output: [ (6,9) ]
>     
>         - The 1st interval (3,4) do not have any previous intervals to compare with, so skip it.
>         - The 2nd interval (5,7) do not conflicts with the previous interval (3,4), so skip it.
>         - The 3rd interval (6,9) does conflict with one of the previous intervals (5,7).
>         - The 4th interval (10,12) do not conflicts with any of the previous intervals (3,4), (5,7) and (6,9), so skip it.
>         - The 5th interval (13,15) do not conflicts with any of the previous intervals (3,4), (5,7), (6,9) and (10,12), so skip it.

# The questions

Well... this challenge seems to go all by induction from the examples.
Which means... let's guess a rule, and stick to that.

In this case, I'll assume that two *conflicting* intervals share a
sub-interval or an endpoint. Hence, `(1,4)` and `(3,5)` conflict because
they share the sub-interval `(3,4)`. By this definition, anyway, also
`(1,3)` and `(3,5)` conflict, because they share one endpoint.

I'll also assume that it's OK to print conflicting intervals as we like
it and not necessarily in the order they appear in the input sequence of
intervals. This is because it's not written and... my algorithm does not
necessarily preserve the input order 🙄

# The solution

Although the challenge talks about "looking backwards" for conflicting
predecessors, I opted for a *look-ahead* approach where I take the
interval at the beginning and see if it generates any conflict ahead.

The first interval is always safe, because it has no conflicting
predecessors. For each successor that the first interval conflicts with,
we eliminate that interval from the list of candidates (because we know
it has a conflict) and merge it with the initial one, going on to find
out additional conflicting intervals up to the end.

At the end of one such pass, the first element can be safely ignored,
all conflicting intervals associated to that element and other
conflicting with it have been eliminated from the input list, and we can
restart the process with the intervals we're left with. When we exhaust
this list... we're done.

To be fair, I started with [Perl][]:

```perl
sub conflict_intervals (@intervals) {
   my @conflicting; # keep the answer
   while (@intervals) {

      # if there is a "first" one, it's safe because it has not been
      # eliminated by its predecessors. Its endpoints will be used to
      # possibly eliminate successors, we keep them in two convenience
      # variables.
      my ($X, $Y) = shift(@intervals)->@*;

      # we filter the remaining intervals ditching all those that
      # conflict with ($X, $Y) or whatever it becomes on the way. In
      # particular, at every conflict we expand ($X, $Y) to also
      # include the conflicting item, because we will ditch it from
      # the candidate "clean" intervals and put it in @conflicting.
      @intervals = grep {
         my ($A, $B) = $_->@*;

         # this is a general check to see if the two intervals are
         # disjoint. It assumes that touching intervals are conflicting.
         ($A - $Y) * ($B - $X) > 0 or do {
            push @conflicting, $_;
            $X = $A if $X > $A;  # "eat" the ($A, $B) interval in ($X, $Y)
            $Y = $B if $Y < $B;
            0; # this interval conflicted and does not get passed along
         }
      } @intervals;
   }
   return @conflicting;
}
```

The [Raku][] translation required very little changes, admittedly:

```raku
sub conflict-intervals (@intervals) {
   return gather {
      while @intervals {

         # if there is a "first" one, it's safe because it has not been
         # eliminated by its predecessors. Its endpoints will be used to
         # possibly eliminate successors, we keep them in two convenience
         # variables.
         my ($X, $Y) = @intervals.shift.Slip;

         # we filter the remaining intervals ditching all those that
         # conflict with ($X, $Y) or whatever it becomes on the way. In
         # particular, at every conflict we expand ($X, $Y) to also
         # include the conflicting item, because we will ditch it from
         # the candidate "clean" intervals and put it in @conflicting.
         @intervals = @intervals.grep: -> $interval {
            my ($A, $B) = |$interval;

            # this is a general check to see if the two intervals are
            # disjoint. It assumes that touching intervals are conflicting.
            ($A - $Y) * ($B - $X) > 0 or do {
               take $interval;
               $X = $A if $X > $A;  # "eat" ($A, $B) in ($X, $Y)
               $Y = $B if $Y < $B;
               0; # this interval conflicted and does not get passed along
            }
         }
      }
   }
}
```

I'm stubborn as a mule and I insist on using [`gather/take`][gt] despite
the performance tax. I stand by it, though: it's such a useful construct
that I'll not be hindered by its slowness. Until I can, anyway.
Besides... it might become fast one day, who knows?

I hope you found this interesting! Stay safe and... have `-Ofun`!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#127]: https://theweeklychallenge.org/blog/perl-weekly-challenge-127/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-127/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[gt]: https://docs.raku.org/syntax/gather%20take
