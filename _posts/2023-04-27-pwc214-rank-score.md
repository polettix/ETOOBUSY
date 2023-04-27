---
title: PWC214 - Rank Score
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-04-27 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#214][]. Enjoy!

# The challenge

> You are given a list of scores (>=1).
>
> Write a script to rank each score in descending order. First three will
> get medals i.e. G (Gold), S (Silver) and B (Bronze). Rest will just get
> the ranking number.
>
>> Using the standard model of giving equal scores equal rank, then
>> advancing that number of ranks.
>
> **Example 1**
>     
>     Input: @scores = (1,2,4,3,5)
>     Output: (5,4,S,B,G)
>
>     Score 1 is the 5th rank.
>     Score 2 is the 4th rank.
>     Score 4 is the 2nd rank i.e. Silver (S).
>     Score 3 is the 3rd rank i.e. Bronze (B).
>     Score 5 is the 1st rank i.e. Gold (G).
>
> **Example 2**
>
>     Input: @scores = (8,5,6,7,4)
>     Output: (G,4,B,S,5)
>
>     Score 8 is the 1st rank i.e. Gold (G).
>     Score 4 is the 4th rank.
>     Score 6 is the 3rd rank i.e. Bronze (B).
>     Score 7 is the 2nd rank i.e. Silver (S).
>     Score 4 is the 5th rank.
>
> **Example 3**
>
>     Input: @list = (3,5,4,2)
>     Output: (B,G,S,4)
>
> **Example 4**
>
>     Input: @scores = (2,5,2,1,7,5,1)
>     Output: (4,S,4,6,G,S,6)

# The questions

Uhm... I guess I'm a bit too tired for questions 🙄

# The solution

Scores must be sorted in descending order to be ranked, but we have to
assign ranks to their original positions. One way to do this is to record
these positions beforehand, associated to the scores.

Then it will be a matter of sweeping the pairs and assign scores
accordingly, putting them in place.

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@scores) { say rank-score(@scores) }

sub rank-score (@scores) {
   state @lower = <X G S B>;
   my @retval = 0 xx @scores;
   my $n = 0;
   my @pairs = (@scores Z (0 ... *)).sort({ $^a[0] <=> $^b[0] }).reverse;
   for ^@pairs -> $i {
      my ($v, $k) = @pairs[$i].Slip;
      $n = $i + 1 if $i == 0 || @pairs[$i - 1][0] > $v;
      @retval[$k] = $n < 4 ?? @lower[$n] !! $n;
   }
   return @retval;
}
```

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my @rs = rank_score(@ARGV ? @ARGV : (2, 5, 2, 1, 7, 5, 1));
say '(', join(',', @rs), ')';

sub rank_score (@scores) {
   state $lower = [ qw< X G S B > ];
   my @retval = (0) x @scores;
   my $n = 0;
   my @pairs = reverse sort { $a->[0] <=> $b->[0] }
      map { [$scores[$_], $_] }
      0 .. $#scores;
   for my $i (0 .. $#pairs) {
      my ($v, $k) = $pairs[$i]->@*;
      $n = $i + 1 if $i == 0 || $pairs[$i - 1][0] > $v;
      $retval[$k] = $n < 4 ? $lower->[$n] : $n;
   }
   return @retval;
}
```

Stay safe and within *ranks*!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#214]: https://theweeklychallenge.org/blog/perl-weekly-challenge-214/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-214/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
