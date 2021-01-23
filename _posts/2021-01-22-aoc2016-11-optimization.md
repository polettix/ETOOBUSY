---
title: 'AoC 2016/11 - Optimization'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-11 ]
comment: true
date: 2021-01-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]:
> reading some advice, implementing it... and **wow**.

In previous post [AoC 2016/11 - Part 2 solution][previous] we left
with... [*something to read*][top post].

Well, folks... it was indeed a very *interesting* reading.

> This is a series of posts, [click here][aoc2016-11-tag] to list them
> all!

[aoc2016-11-tag]: {{ '/tagged#aoc-2016-11' | prepend: site.baseurl }}


# First... let's try the code!

The first thing I did was to try the code, of course. In particular,
[this code][code].

And something weird happened with my own puzzle input:

```
$ time ruby 11.rb 11.input
35
57

real  0m0.497s
user  0m0.440s
sys   0m0.012s
```

First of all, it didn't take 2 seconds... it took less than a half!

The real weird fact, anyway, was that the solution to the second puzzle
(57) was correct... but the solution to the first one (35) was not!
Being that thorn in the side that I am... I opened an [issue][] 🤓

*Anyway* it seemed clear that the direction was correct, and probably
the author had been a bit too *enthusiastic* in optimizing.

# Then... let's read the spoilers

The [post on Reddit][top post] includes a few hints in the form of
*spoilers*. By default they are not shown, you have to click on them to
read.

SPOILER ALERT: I'll put the most effective hint right below!

> THE MOST IMPORTANT, ABSOLUTELY ESSENTIAL: ALL PAIRS ARE
> INTERCHANGEABLE - The following two states are EQUIVALENT:
> (HGen@floor0, HChip@floor1, LGen@floor2, LChip@floor2), (LGen@floor0,
> LChip@floor1, HGen@floor2, HChip@floor2) - prune any state EQUIVALENT
> TO (not just exactly equal to) a state you have already seen!

This is so true!

And humbling 🙇

If there was a thing that I was sure of... was that the *identifier
function* was correct. Remember what I stated in [New
identifier][new-id]:

> [The identifier] has to be a string that can represent a state in a
> one-to-one mapping, so that equivalent states (i.e. states where the
> elevator, the generators and the microchips are all in the same place)
> map onto the same identifier, and different states (for either the
> elevator, the generators or the microchips) map onto different ones.

It turns out that *equivalent* does not mean what I wrote *at all*. I
only had in mind that two different hashes with the same values inside
were equivalent, but this hint changed everything.

So thanks [p\_tseng][ptseng] for shedding a light!

The new implementation for the `id_of` function takes into account the
new insight:

```perl
sub id_of ($state) {
   state $floor_idx_of = {
      map {
         my $mask = 0x01 << $_;
         map { (($mask << (8 * $_)) => $_) } 0 .. 3;
      } 0 .. 7
   };
   my ($generators, $microchips) = $state->@{qw< generators microchips >};
   return join ',', $state->{elevator},
      map { $_->@* }
      sort { ($a->[0] <=> $b->[0]) || ($a->[1] <=> $b->[1]) }
      map {
         my $mask = 0x01010101 << $_;
         [
            $floor_idx_of->{$generators & $mask},
            $floor_idx_of->{$microchips & $mask},
         ];
      } 0 .. ($state->{n_elements} - 1);
}
```

It is *quite more complex* than before, but not necessarily more
*complicated*. The gist of it is the following:

- for each element generate a pair with the floor id of the generator,
  followed by the floor id of the microchip;
- sort all these pairs by the generator's floor first, then by the
  microchip's floor;
- flatten all these pairs into a single list;
- pre-pend the elevator floor;
- join everything together with a separator (in our case, this separator
  might even be the empty string).

Why does this work? Simply put, the only thing that *matters* is the
relation of each generator with respect to its corresponding microchip.
Hence we form the pairs to make sure that these two halves stick
together, then do the sorting to make sure that different permutations
of the same underlying situation are *squashed* onto the same
identifier.

The A\* implementation will then do the rest: whenever it encounters the
same identifier, it will mark that specific *state* as a duplicate,
because at the end of the day... *it is*!

You can get the final code from the [local version here][]. Here's how
it goes:

```
$ time perl 11.pl 11.input2
57

real  0m1.019s
user  0m0.988s
sys   0m0.024s
```

We are still about half a second off with respect to the solution by
[p\_tseng][ptseng]... but I guess we can declare ourselves very, very
satisfied!

# Today I Learned...

... that taking things for granted can hide a lot of interesting and
useful things.

It might have its merit - after all, we shouldn't always be reinventing
the wheel - but it's probably also good to get into the habit of
*questioning* also things that seem carved in the stone.

Just in case.


[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[previous]: {{ '/2021/01/19/aoc2016-11-part2-solution/' | prepend: site.baseurl }}
[top post]: https://www.reddit.com/r/adventofcode/comments/5hoia9/2016_day_11_solutions/db1v1ws?utm_source=share&utm_medium=web2x&context=3
[code]: https://github.com/petertseng/adventofcode-rb-2016/blob/c73e49d5a21d8e72b016b171f1a490978929d0dc/11_chips_and_generators.rb
[issue]: https://github.com/petertseng/adventofcode-rb-2016/issues/4
[new-id]: {{ '/2021/01/16/aoc2016-11-new-identifier/' | prepend: site.baseurl }}
[ptseng]: https://www.reddit.com/user/p_tseng/
[local version here]: {{ '/assets/code/aoc2016-11-04.pl' | prepend: site.baseurl }}
