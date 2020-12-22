---
title: PWC092 - Insert Interval
type: post
tags: [ perl weekly challenge, perl ]
comment: true
date: 2020-12-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#092][].
> Enjoy!

# The challenge

> You are given a set of sorted non-overlapping intervals and a new
> interval. Write a script to merge the new interval to the given set of
> intervals.

# The questions

I think that the examples here help a lot *by example*. Basically the
expected output is a sequence of non-overlapping intervals, sorted in
ascending order, much like the first input.

The intervals seem to be defined by integers, but I guess that it's fair to
assume whatever number that can be represented by the computer.

# The solution

I think that this challenge requires a bit of *discipline*.

```perl
sub insert_interval ($S, $N) {
   my @S = map { [$_->@*] } $S->@*;
   my ($l, $h) = $N->@*;
   my @retval;

   # first of all, "transfer" all preceding intervals
   push @retval, shift(@S) while @S && $S[0][1] < $l;
   if (! @S) { # all intervals were preceding, easy
      push @retval, [$l, $h];
      return \@retval;
   }

   # now $S[0] might be after the new interval
   if ($S[0][0] > $h) {
      push @retval, [$l, $h], @S;
      return \@retval;
   }

   # now there is some overlap between $S[0] and $N. We can fix the start
   $l = min($l, $S[0][0]);

   # ... and look for the end...
   while (@S && $h >= $S[0][0]) {
      $h = max($h, $S[0][1]);
      shift @S;
   }

   push @retval, [$l, $h], @S;
   return \@retval;
}
```

The copies at the beginning is to avoid spoiling the inputs. This is a
design choice, you might prefer something different.

The first loop takes care to transfer all intervals that come *completely
before* the new one to the list that we will eventually return (held in
`@retval`). This can lead to three situations:

- the input list is completely transferred because the new interval is
  higher than everything already in the list: in this case, we just add the
  new interval and we're done. Something like this:

```text
                         N----N
S-----S   S-----S S--S
|<---- all lower --->|
```


- otherwise, there is the possibility that all the remaining items in `@S`
  are *higher* than the new interval. Easily enough, we put the new interval
  in place, followed by the remaining items in `@S`, and we call it a day.
  As an example:

```text
                         N----N
S-----S   S-----S S--S            S----S     S--------S
|<---- all lower --->|            |<-- all higher --->|
```

- last, there is some degree of *overlapping* between the new interval and
  what's currently at the beginning of `@S`, so we have to go on. The
  following is an example, but there are a lot of cases here:

```text
                  N------------N
S-----S   S-----S  S------S   S--S  S----S     S--------S
|<- all lower ->|  |<- overlap ->|  |<-- all higher --->|
```

In general, we will have to insert a new range that is the merge of the new
interval and one or more intervals in `@S`. This new range will start with
the lowest of the two lower boundaries, so we can save it immediately. The
following is an example in which the first overlapping interval in S has a
lower bound that is smaller than the lower bound of the new interval N:

```text
       N--...
... S-----...
    | 1st overlapping
    v
    X start of new merged range
```

To find the upper bound we have to look in `@S` until we find overlaps. For
whatever overlap, we keep the higher value and check the next interval,
until there's no more overlap. At this point, we also know the upper bound
of the new *merged* interval, and we can add it to `@retval`, followed by
what's left in `@S`. The following picture shows an example in which the
upper bound of the new interval is higher than the upper bound of the last
overlapping interval.

```text
...-------------------------N
...           S----------S  |  S----S    S--------S
...   last overlapping --^  |  |<-- all higher -->|
                            v
... end of new merged range X
```

How to find out the first interval in S that is no more overlapping with the
new interval N? After we have found the first overlapping one, we can check
whether the upper bound of N is greater than, or equal to, the lower bound
of the interval in S. If it is, then there is an overlap; otherwise, the
interval in S is beyond N and makes part of the "all higher" part. This is
the sense of the condition in the last `while` loop, where `$h` is the
candidate upper bound for the interval to insert so far, and `$S[0][0]` is
the lower bound of the interval we are comparing against (in the loop, we
`shift @S` so the first item is always the one we are considering in each
round):

```perl
   while (@S && $h >= $S[0][0]) {
      $h = max($h, $S[0][1]);
      shift @S;
   }
```

I guess it's all for today... good bye and stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#092]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-092/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-092/#TASK2
[Perl]: https://www.perl.org/
