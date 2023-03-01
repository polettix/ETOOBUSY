---
title: PWC206 - Shortest Time
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-02 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#206][]. Enjoy!

# The challenge

> You are given a list of time points, at least 2, in the 24-hour clock
> format `HH:MM`.
>
> Write a script to find out the shortest time in minutes between any
> two time points.
>
> **Example 1**
>
>     Input: @time = ("00:00", "23:55", "20:00")
>     Output: 5
>
>     Since the difference between "00:00" and "23:55" is the shortest (5 minutes).
>
> **Example 2**
>
>     Input: @array = ("01:01", "00:50", "00:57")
>     Output: 4
>
> **Example 3**
>
>     Input: @array = ("10:10", "09:30", "09:00", "09:55")
>     Output: 15

# The questions

I *hope* that `00:00` is considered the *first* minute in the period and
that `23:59` the last one. In this case, then, I'm assuming that:

- the minimum interval between any two minutes is always taken;
- the interval can span across a day boundary.

# The solution

Well folks, put your dear ones into a shelter because [Raku][] is on its
way:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put shortest-time(@args) }

sub shortest-time (@times) {
   my \period = 24*60;
   @times
      .map({(.comb(/\d+/)».Int «*» (60, 1)).sum})  # turn everything into minutes
      .combinations(2)                             # create all possible pairs
      .map(->($x, $y) { ($x - $y) % period })      # calculate difference, modulo "period"
      .map({min($^x, period - $^x)})               # consider that and its reciprocal
      .min                                         # take the minimum, as requested
}
```

The comments say pretty everything. I had to decide between using two
`map`s (like I eventually did above) or coalescing them into one, but I
didn't like the end result too much and it was less clear in my opinion.
So there we go.

[Perl][] follows the same ideal approach, but moving at a lower level
because there are less batteries included (no hyperstuff and no
`combinations`). Taking pairs is just a couple of nested loops, so no
big deal; I'd also argue that it should be a little easier on memory
because we're not keeping all deltas as we go, but I'll stop it here.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;

say shortest_time(@ARGV);

sub shortest_time {
   my @times = map { my ($h, $m) = split m{:}mxs; $h * 60 + $m } @_
      or return;
   my $period = 24 * 60;
   my $min = $period;
   for my $i (0 .. $#times - 1) {
      for my $j ($i + 1 .. $#times) {
         my $delta = ($times[$i] - $times[$j]) % $period;
         $min = ($_ < $min ? $_ : $min) for ($delta, $period - $delta);
      }
   }
   return $min;
}
```

I guess it's everything for this challenge... stay safe!!!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#206]: https://theweeklychallenge.org/blog/perl-weekly-challenge-206/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-206/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
