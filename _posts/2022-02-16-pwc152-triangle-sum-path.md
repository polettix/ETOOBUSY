---
title: PWC152 - Triangle Sum Path
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-16 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#152][]. Enjoy!

# The challenge

> You are given a triangle array.
>
> Write a script to find the minimum sum path from top to bottom.
>
> **Example 1:**
>
>     Input: $triangle = [ [1], [5,3], [2,3,4], [7,1,0,2], [6,4,5,2,8] ]
>     
>                     1
>                    5 3
>                   2 3 4
>                  7 1 0 2
>                 6 4 5 2 8
>     
>     Output: 8
>     
>         Minimum Sum Path = 1 + 3 + 2 + 0 + 2 => 8
>
>
> **Example 2:**
>
>
>     Input: $triangle = [ [5], [2,3], [4,1,5], [0,1,2,3], [7,2,4,1,9] ]
>     
>                     5
>                    2 3
>                   4 1 5
>                  0 1 2 3
>                 7 2 4 1 9
>     
>     Output: 9
>     
>         Minimum Sum Path = 5 + 2 + 1 + 0 + 1 => 9

# The questions

Oh my how many questions I have.

The most basic one is *what is a path from top to bottom*. By the
arrangement of the numbers in the triangle, I was assuming that it's
some kind of graph where each node is connected to up to two nodes above
and up to two nodes below, e.g. the `3` at the very center of the first
example would be connected to the `5` and `3` above of it, and to the
`1` and `0` immediately below. On the other hand, *both* examples make
it clear that this is not the case: in the first example we go from the
`2` in third row to the `0` in the fourth, and they are definitely not
"close" by the definition above.

So... I'll assume that everything in a tier is connected to everything
in the tier below.

I would also ask what's the domain of the numbers in the nodes. In this
"total connection between two adjacent tiers" this question is kind of
moot but... I only figured that there is the total connection at a
second read of the input, so it *initially* mattered a lot!
Additionally, I think it's a good information to have around (especially
if negative numbers would be allowed).

# The solution

I initially totally misunderstood the task at hand and didn't think that
each tier was totally connected to its adjacent tiers... I only figured
this *after* botching both examples' result.

So my initial take was to consider this a graph, add a `goal` node at
the end (connected to all nodes in the bottom tier) and put my [A\*
implementation][astar] to work the best path and its cost:

```raku
sub triangle-restricted-sum-path (@triangle) {
   class Astar { ... }
   my $max-last = @triangle[*-1].max;
   my $astar = Astar.new(
      distance => sub ($u, $v) {
         return $v<goal> ?? 0 !! @triangle[$v<tier>][$v<index>];
      },
      successors => sub ($v) {
         my $tier = $v<tier> + 1;
         return hash(goal => 1) unless $tier <= @triangle.end;
         my @retval = gather {
            for 0 .. 1 -> $delta {
               my $index = $v<index> + $delta;
               take hash(tier => $tier, index => $index)
                  if $index <= @triangle[$tier].end;
            }
         };
         return @retval;
      },
      heuristic => sub ($u, $v) {
         return $u<goal> ?? 0 !! $u<tier> < @triangle.end ?? $max-last !! 0;
      },
      identifier => sub ($v) {
         return $v<goal> ?? 'goal' !! $v<tier index>.join(',');
      },
   );
   my $triangle-sum-path = $astar.best-path(
      hash(tier => 0, index => 0),
      hash(goal => 1),
   );
   my $sum = 0;
   for $triangle-sum-path.List -> $v {
      last if $v<goal>;
      $sum += @triangle[$v<tier>][$v<index>];
   }
   return $sum;
}
```

But... but... it turns out that life is *extremely* simpler in this
challenge, and it seems that taking the minimum value out of every tier
and summing them up does the trick, so...

```raku
sub triangle-sum-path (@triangle) { @triangle».min.sum }
```

I confess that this has been a bit of anti-climax, but the challenge is
the challenge. It's also a nice place to show off a bit of
hyperoperators!

When translating into [Perl][], though, I didn't do the same error, so
here's the full solution:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util qw< sum min >;

my @triangle = map { [split m{,}mxs] } @ARGV;
say triangle_sum_path(@triangle);

sub triangle_sum_path (@triangle) { sum map { min $_->@* } @triangle }
```

No hyperoperators here, but still [Perl][] rocks a lot with all the
needed batteries in CORE.

This, and [a `-r` flag][reference], are all I ask to be happy 😉

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#152]: https://theweeklychallenge.org/blog/perl-weekly-challenge-152/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-152/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[astar]: https://github.com/polettix/cglib-raku/blob/main/Astar.rakumod
[reference]: https://perlweekly.com/archive/551.html
