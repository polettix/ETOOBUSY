---
title: 'AoC 2016/11 - New heuristic'
type: post
tags: [ advent of code, coding, perl, algorithm ]
comment: true
date: 2021-01-17 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: a
> new heuristic for evaluating our distance to the end goal.

While we are at it, it's also time to take a closer look at the
*heuristic* function that we use to guess how far we are from the
destination.

To stress this fact, we will name the function as `distance_to_goal`;
although it takes two states as input, the goal state is actually
ignored here because we will assume that it's always to bring everything
down to the lowest octet in both `generators` and `microchips`.

As already observed in [New algorithm: A\*][new-algo], the *heuristic*
is a good one for A\* only if it's either correct, or it
*underestimates* the distance. Otherwise, we would risk finding a
sub-optimal solution, which would spoil the fun in this puzzle.

Withouth further ado, here's the `distance_to_goal` function that we
will adopt:

```
 1 sub distance_to_goal ($node, $goal) { # we *know* what the goal is
 2    my ($g, $m) = $node->@{qw< generators microchips >};
 3    my $d     = 0;
 4    my $mask  = 0x80000000;
 5    my $count = 0;
 6    for my $w (3, 2, 1) {
 7       for (1 .. 8) {
 8          $count++ if $g & $mask;
 9          $count++ if $m & $mask;
10          $mask >>= 1;
11       }
12       next unless $count;
13       $d++;    # at least one movevement with one or two items
14       $d += 2 * ($count - 2) if $count > 2;   # back and forth for the rest
15    } ## end for my $w (3, 2, 1)
16    return $d;
17 } ## end sub distance_to_goal
```

We are counting how many steps it would take us to complete the puzzle
if we had no constraint on the simultaneous placement of generators and
microchips. This ensures that we have an *underestimation*, because that
added constraint is what requires us to take extra steps.

At each floor (line 6) we count the number of generators and the number
of chips that we have, by using a moving bit in `$mask` (lines 7 to 11).
We will assume that the elevator starts from floor 1, but it will not
determine moves until we find something.

Next, we count how many steps it would take us to bring all the
microchips and generators from the current floor to the next one. This
is only done if there are any, of course (line 12), and proceeds like
this:

- we have to take at least one step to bring one or two items, which
  accounts for line 13;
- whatever goes beyond two items will be transported singularly (because
  the elevator must go back to take anything else) and will determine a
  back-and-forth, hence two steps as shown in line 14.

When this has been done, `$count` is ready to be potentially
*incremented* with the items that were already in the destination floor,
i.e. we are ready for the next iteration of the loop in line 6.

After scanning all three floors like this... we can return the total
minimum distance found so far (line 16).

I hope it was all clear! Possibly it might be smarter... but it's better
than before, *admissible* and for the time being we can just wait to use
it!

[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[new-algo]: {{ '/2021/01/11/aoc2016-11-new-algorithm/' | prepend: site.baseurl }}
