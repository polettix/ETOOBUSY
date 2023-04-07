---
title: PWC202 - Consecutive Odds
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-02 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#202][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to print `1` if there are `THREE` consecutive odds in
> the given array otherwise print `0`.
>
> **Example 1**
>
>     Input: @array = (1,5,3,6)
>     Output: 1
>
> **Example 2**
>
>     Input: @array = (2,6,3,5)
>     Output: 0
>
> **Example 3**
>
>     Input: @array = (1,2,3,4)
>     Output: 0
>
> **Example 4**
>
>     Input: @array = (2,3,5,7)
>     Output: 1

# The questions

Wow, is *this* ambiguous!

Suppose that you're the proud owner of **five** paintings by [Vincent
van Gogh][]. Wow.

Then someone comes and asks you: *Hey! Do you have **three** paintings
by [Vincent van Gogh][]?!?*.

Sure, you *do* have them (you have more, actually), but chances are that
your answer will be *Why... no! I have five!*.

So I guess that my questions is... can we allow for any other odd in the
array? Can they appear consecutive to the first three ones?

# The solution

OK, let's take into consideration a couple options, in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my ($n-streaks, $longest-streak) = consecutive-odds(@args);

   # strict
   $*ERR.put('(one single streak of exactly three odds, no other odd)');
   $*OUT.put(($n-streaks == 1 && $longest-streak == 3) ?? 1 !! 0);

   # lax
   $*ERR.put('at least three odds in a row');
   $*OUT.put(($longest-streak >= 3) ?? 1 !! 0);
}

sub consecutive-odds (@array) {
   my $longest-streak = 0;
   my $current-streak = 0;
   my $n-streaks = 0;
   for @array -> $item {
      if $item %% 2 {
         ++$n-streaks if $current-streak;
         $current-streak = 0;
      }
      else {
         ++$current-streak;
         ++$longest-streak if $longest-streak < $current-streak;
      }
   }
   ++$n-streaks if $current-streak;
   return $n-streaks, $longest-streak;
}
```

And the obvious [Perl][] translation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my ($n_streaks, $longest_streak) = consecutive_odds(@ARGV);

# strict
say {*STDERR} '(one single streak of exactly three odds, no other odd)';
say {*STDOUT} $n_streaks == 1 && $longest_streak == 3 ? 1 : 0;

# lax
say {*STDERR} 'at least three odds in a row';
say {*STDOUT} $longest_streak >= 3 ? 1 : 0;

sub consecutive_odds (@array) {
   my $longest_streak = 0;
   my $current_streak = 0;
   my $n_streaks = 0;
   for my $item (@array) {
      if ($item % 2) {
         ++$current_streak;
         ++$longest_streak if $longest_streak < $current_streak;
      }
      else {
         ++$n_streaks if $current_streak;
         $current_streak = 0;
      }
   }
   ++$n_streaks if $current_streak;
   return ($n_streaks, $longest_streak);
}
```

In both cases, we're collecting some *statistics* about the `@array`, so
that we can take our decision at a later time. The explanation for the
result is printed on *standard error*, so that *standard output* only
gets `0` or `1`.

And that's all, folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#202]: https://theweeklychallenge.org/blog/perl-weekly-challenge-202/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-202/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Vincent van Gogh]: https://it.wikipedia.org/wiki/Vincent_van_Gogh
