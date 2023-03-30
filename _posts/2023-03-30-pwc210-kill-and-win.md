---
title: PWC210 - Kill and Win
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-30 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#210][]. Enjoy!

# The challenge

> You are given a list of integers.
>
> Write a script to get the maximum points. You are allowed to take out
> (kill) any integer and remove from the list. However if you do that then
> all integers exactly one-less or one-more would also be removed. Find out
> the total of integers removed.
>
> **Example 1**
>
>     Input: @int = (2, 3, 1)
>     Output: 6
>
>     First we delete 2 and that would also delete 1 and 3. So the maximum points we get is 6.
>
> **Example 2**
>
>     Input: @int = (1, 1, 2, 2, 2, 3)
>     Output: 11
>
>     First we delete 2 and that would also delete both the 1's and the 3. Now we have (2, 2).
>     Then we delete another 2 and followed by the third deletion of 2. So the maximum points we get is 11.

# The questions

I guess there's too many this time. Rules are not entirely clear to me, and
the examples (especially the second one) do not help clearing them out.

The main question is: how many throws do we get? If this has to be about
finding some optimal solution, I'd say that the answer should be 1, so that
we inspect the input array, aim at one and one number only and let the rules
win us point.

The second example is a bit obscure about this. It seems to hint that we can
take multiple shots, but interestingly we're only left with 2 at the end of
the first shot, so... does this mean that *take out (kill) any integer* is
not about a single item in the list, but the entire subset of items that
happen to have the same value?

Does killing propagate automatically? I mean, if I have the list `(1, 2, 3,
4)` as input, does killing 1 in turn kill 2 (OK, this is clear), then this
kill of 2 trigger automatic killing of 3, then this kill of 3 trigger
automatic killing of 4? In other terms, does this cause a chain reaction of
any type?


# The solution

Given that the prompt is a bit obscure to me, here's what I'm solving in the
code below:

- we get one single shot to one single item in the list
- a shot causes a chain reaction

In this case, our approach will be the following.

First, we're going to sort the array. This will leave us with contiguous
sub-lists of closely related values, each a candidate for calculating the
score. For example, the following sorted list provides us with three
candidate sub-lists, as hinted by the spacing:

```
1 1 2 2 2 3    6 7    8 8 8 8

```

Under our rules above, the best score here is `13 = 6 + 7`, because:

- the first sub-list yields 11, like this:
    - we hit the very first `1`
    - this causes all the `2` to be killed due to chain reaction
    - this causes the remaining `1` and the `3` to be killed due to chain
      reaction
- the second sub-list yields 13, like this:
    - we hit the `6`
    - this causes the `7` to be killed due to chain reaction
- the third sub-list yields 8, because we only shoot at one single item and
  no chain reaction is triggered (there's no `7` nor `9`).

So, at this point, it's a matter of calculating how much each sub-list is
worth, firing at the lowest item of each and tracking chain reactions by
moving on increasingly. If a chain reaction happens, the score of a sub-list
is the sum of all elements; otherwise, it's the value of one single item in
the sub-list.

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put kill-and-win(@args) }

sub kill-and-win-basic (@args) { return @args.sum }

sub kill-and-win (@args) {
   my $best-score = 0;
   my $score = 0;
   my $previous = 0;
   my $n-streak = 0;
   sub close-streak {
      return if $n-streak < 1;
      $score = $previous if $n-streak == 1; # "singleton"
      $best-score = $score if $score > $best-score;
      $score = 0;
      $n-streak = 0;
   }

   for @args.sort({$^a <=> $^b}) -> $item {
      close-streak() if $item > $previous + 1;
      $n-streak++    if $item > $previous;
      $score += $item;
      $previous = $item;
   }
   close-streak();

   return $best-score;
}
```

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say kill_and_win(@ARGV);

sub kill_and_win (@args) {
   my $best_score = 0;
   my $score = 0;
   my $previous = 0;
   my $n_streak = 0;
   my $close_streak = sub {
      return if $n_streak < 1;  # should not happen
      $score = $previous if $n_streak == 1; # "singleton"
      $best_score = $score if $score > $best_score;
      $score = 0;
      $n_streak = 0;
   };

   for my $item (sort { $a <=> $b } @args) {
      $close_streak->() if $item > $previous + 1;
      $n_streak++       if $item > $previous;
      $score += $item;
      $previous = $item;
   }
   $close_streak->();

   return $best_score;
}
```

I call it a day... stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#210]: https://theweeklychallenge.org/blog/perl-weekly-challenge-210/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-210/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
