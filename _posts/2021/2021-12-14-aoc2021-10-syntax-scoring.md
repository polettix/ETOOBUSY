---
title: 'AoC 2021/10 - Syntax scoring'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 10][puzzle] from [2021][aoc2021]:
> playing with parentheses.

Today's challenge is a bit more *abstract* than the others, being
centered on a matter of programming itself. I guess this might be some
recurring these - I mean, matching of parentheses - but it might just be
that I did too many programming puzzles around and they are all mixed up
in my brain.

Whatever.

We are given a list of parentheses, all of which are *wrong* in some
sense.

Some of them which are the subject of puzzle 1, are just plain wrong.
Parentheses have a tradition of liking to be paired with one another in
a sort of russian dolls way, so this:

```
[(])
```

is, usually, a no-no. Well, unless you decide to give some meaning to
it, of course.

In this case, anyway, this is considered wrong and we are required to
detect all sequences that are *wrong* in this way in the lot, and
calculate a number from them with some weights.

> I couldn't find some evident rule why those weights were chose, but I
> suspect that they allow anyway to go back from the number to the exact
> number of illegalities found. At least if there are no more than about
> 18 illegalities for each type of parenthesis.

This job of finding correspondences, or lack thereof, is usually well
addressed by means of a *stack* data structure, so I didn't go too far
and used it in my solution:

```raku
sub part1 ($inputs) {
   state %data-for = ')' => ['(', 3], ']' => ['[', 57],
      '}' => ['{', 1197], '>' => ['<', 25137];
   my $sum = 0;
   my @incomplete;
   SEQ:
   for $inputs[0].List -> @seq {
      my @stack;
      for @seq -> $item {
         if %data-for{$item}:exists {
            my $top = @stack.elems ?? @stack.pop !! '';
            if %data-for{$item}[0] ne $top {
               $sum += %data-for{$item}[1];
               next SEQ;
            }
         }
         else {
            @stack.push: $item;
         }
      }

      state %score-for = '(' => 1, '[' => 2, '{' => 3, '<' => 4;
      my $score = 0;
      $score = 5 * $score + %score-for{$_} for @stack.reverse;
      @incomplete.push: $score;
   }
   my $mid = (@incomplete.elems - 1) / 2;
   $inputs[1] = @incomplete.sort[$mid];
   return $sum;
}
```

The `%data-for` at the beginning is useful for figuring out the opening
corresponding to each closing, as well as the cost of each illegal
closing. Mabye using *two* hashes would have been clearer, in hindsight.

The algorithm is: every open parenthesis is pushed onto the stack, every
close parenthesis is checked against the stack and, if successful,
removes one element from it. If the stack is empty... no worries: we
assume it's something that is surely a *mismatch* (the empty string does
not correspond to any closing) and this will ensure a failure.

The second part is implemented here as well. It requires us to estimate
how would it cost us to *complete* an incomplete sequence of otherwise
correct parentheses. In this case, the weight is calculated with a
base-5 number, where 0 means "good, nothing needed".

To do this calculation, it suffices to get elements out of the stack in
the order the stack gives us (i.e. from last to first) and we can easily
calculate our second part score.

Well well well.. a quite boring solution, isn't it? Yes, it is.

If you want to read a quite illuminating one, though, [this Perl
solution][] is brilliant in my opinion. I'll copy it here, hoping nobody
will complain (did I say it's not mine?):

```
perl#!/usr/bin/perl -w

use strict;

my %points1 = (')' => 3, ']' => 57, '}' => 1197, '>' => 25137);
my %points2 = ('(' => 1, '[' => 2,  '{' => 3,    '<' => 4);

my $score1 = 0;
my @list2;
while (<>) {
    chomp;
    1 while s/(\(\)|\{\}|\[\]|<>)//;
    if (m/([\]>\}\)])/) {
        $score1 += $points1{$1};
        next;
    }
    my $score2 = 0;
    foreach (split //, reverse) {
        $score2 = $score2 * 5 + $points2{$_};
    }
    push @list2, $score2 if $score2;
}
print $score1, "\n";
@list2 = sort { $::a <=> $::b } @list2;
print $list2[@list2/2], "\n";
```

The core of part 1 is just this:

```
1 while s/(\(\)|\{\}|\[\]|<>)//;
if (m/([\]>\}\)])/) {
    $score1 += $points1{$1};
    next;
}
```

I know it looks like the noise that stains [Perl][]'s reputation for
many, but there are a lot of backslashes because we're dealing with
parentheses, most of which have a specific meaning in regular
expressions.

The `while` runs as soon as there are matching consecutive pairs,
eliminating them. What we're left with is only what is illegal or what
is incomplete. Genius.

Well, enough for today... stay safe folks!

[puzzle]: https://adventofcode.com/2021/day/10
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[this Perl solution]: https://www.reddit.com/r/adventofcode/comments/rd0s54/2021_day_10_solutions/hnysmp7
[Perl]: https://www.perl.org/
