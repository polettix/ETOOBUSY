---
title: PWC215 - Number Placement
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-05 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#215][].
> Enjoy!

# The challenge

> You are given a list of numbers having just 0 and 1. You are also
> given placement count (>=1).
>
> Write a script to find out if it is possible to replace 0 with 1 in
> the given list. The only condition is that you can only replace when
> there is no 1 on either side. Print 1 if it is possible otherwise 0.
>
> **Example 1:**
>
>     Input: @numbers = (1,0,0,0,1), $count = 1
>     Output: 1
>
>     You are asked to replace only one 0 as given count is 1.
>     We can easily replace middle 0 in the list i.e. (1,0,1,0,1).
>
> **Example 2:**
>
>     Input: @numbers = (1,0,0,0,1), $count = 2
>     Output: 0
>
>     You are asked to replace two 0's as given count is 2.
>     It is impossible to replace two 0's.
>
> **Example 3:**
>
>     Input: @numbers = (1,0,0,0,0,0,0,0,1), $count = 3
>     Output: 1

# The questions

The puzzle is a bit cryptic, e.g. I initially thought that `10` or
`10101` could be valid numbers in the list, as they have just 0 and 1.
The examples seem to hint that the numbers *themselves* can only be 0 or
1.

Then the placement count should be used to assess whether it's possible
to do *that many* replacements. So it's a *replacement* count maybe?

> I wonder how ChatGPT would generate code based on this prompt!

Last, and *most*, there's the question of how these replacements should
happen *chronologically*. There are at least two approaches:

- *sequential*: we do one replacement, decrease the replacement count by
  1, then start again if the count is still greater than 0.

- *parallel*: we assess the possibility to replace each `0` all at once.

The latter approach is what usually comes out of simulations, like e.g.
[Conway's Game of Life][]: the state of a cell in the *next* step is
solely determined by the state of the cell and its surroundings in the
*current* step.

As an example, given this input:

    $count = 2;
    @numbers = (1, 0, 0, 0, 0, 1);

we would get a `0` with the *sequential* approach, and a `1` with the
*parallel* (which would generate `1 0 1 1 0 1`).

So my question is... *which of the two?!?*

# The solution

Both the *sequential* and the *parallel* approaches are valid, so let's
address them both. Especially considering that they can be both solved
starting from the same pre-computation over the input numbers, i.e. the
list of counts of zeros in consecutive streaks.

As an example, the following input:

```
1 0 1 0 0 0 1 0 0
```

contains three streaks of zeros, with counts `(1, 3, 2)`.

In the *sequential* case, each streak of $n$ zeros can only accomodate
$\lfloor \frac{n - 1}{2} \rfloor$ replacements, because we have to keep
one boundary on the left (the $-1$) and then one on the right for each
replacement (i.e. we need two zeros for each replacement).

In the *parallel* case, we only have to make sure to keep a boundary `0`
on the left and another one on the right; all other zeros are good for
replacement. This rules out streaks with a single zero.

Let's start with [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use List::Util 'sum';

my @args = map { split m{[\s,]*}mxs } @ARGV;
@args = (1, 1, 0, 0, 0, 1) unless @args;
say number_placement_sequential(@args);
say number_placement_parallel(@args);

sub number_placement_sequential ($count, @numbers) {
   my $av = sum map { int(($_ - 1) / 2) } zero_streaks_counts(@numbers);
   return $count <= ($av // 0) ? 1 : 0;
}

sub number_placement_parallel ($count, @numbers) {
   my $av = sum map { $_ > 1 ? $_ - 2 : 0 } zero_streaks_counts(@numbers);
   return $count <= $av ? 1 : 0;
}

sub zero_streaks_counts (@numbers) {
   my @retval = (0);
   for my $n (@numbers) {
      if ($n) { push @retval, 0 if $retval[-1] }
      else    { $retval[-1]++                  }
   }
   pop @retval while @retval && $retval[-1] == 0;
   return @retval;
}
```

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my $count = @args.shift;
   put number-placement-sequential(@args, $count);
   put number-placement-parallel(@args, $count);
}

sub number-placement-sequential (@numbers, $count) {
   my $av = zero-streaks-count(@numbers)
      .map({ (($_ - 1) / 2).Int })
      .sum;
   return $count <= $av ?? 1 !! 0;
}

sub number-placement-parallel (@numbers, $count) {
   my $av = zero-streaks-count(@numbers)
      .map({ $_ > 1 ?? $_ - 2 !! 0 })
      .sum;
   return $count <= $av ?? 1 !! 0;
}

sub zero-streaks-count (@numbers) {
   my @retval = 0,;
   for @numbers -> $n {
      if $n.Int { @retval.push: 0 if @retval[*-1] }
      else      { @retval[*-1]++                  }
   }
   @retval.pop while @retval && @retval[*-1] == 0;
   return @retval;
}
```

I guess this is everything for this challenge, stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#215]: https://theweeklychallenge.org/blog/perl-weekly-challenge-215/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-215/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Conway's Game of Life]: {{ '/2020/04/23/conway-life/' | prepend: site.baseurl }}
