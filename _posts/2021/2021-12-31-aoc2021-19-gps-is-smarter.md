---
title: 'AoC 2021/19 - GPS is smarter'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-31 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 19][puzzle] from [2021][aoc2021]:
> GPS is smarter.

This day's puzzle is a definite increase in difficulty for this year. Or
is it really? Looking back at it, the solution I found is devoid of
cleverness but it still manages to run well below the solution from the
previous day.

Anyway, it was hard to stitch all parts together, with the constant fear
that something might be buggy as well the constant time pressure. I
mean, the next day approaching.

> Before moving on, let's rant a bit and also explain why **GPS is
> smarter**. I mean... *how on Earth* is it possible that a scanner
> senses a bunch of beacons with an exact measurement of their relative
> position, but each beacon does not emit a **unique identifier**?!?
>
> Admittedly, this would have made part 1 way simpler.

At the highest abstraction level, my algorithm for placing all scanners
is the following:

```
my @unbound = get-inputs($filename);                  # [1]
my @bound = @unbound.shift;                           # [2]

my $alice-id = 0;                                     # [3]
while @unbound.elems > 0 {                            # [4]
    my $alice = @bound[$alice-id];                    # [5]
    my @left;
    for @unbound -> $umberto {                        # [6]
        if my $new = match-unbound($alice, $berto) {  # [7]
            @bound.push: $new;
        }
        else {
            @left.push: $umberto;
        }
    }
    die 'disconnected' if ++$alice-id > @bound.end;   # [8]
    @unbound = @left;                                 # [9]
}
```

> I started laying this out as pseudocode, then I figured that the
> [Raku][] implementation was clearer!

Here's a few comments on the algorithm:

- we keep two arrays, one with the unbound inputs (`[1]`) and one with
  the bound ones, i.e. the scanners that we have placed in the same
  coordinate systems.
- The `@bound` array is initialized with the first scanner (`[2]`),
  which will be our reference one for the coordinate system.
- Integer index variable `$alice-id` will track our analysis to bind
  more and more elements, so it starts from the first (and only) element
  in `@bound` (`[3]`) and it MUST always be valid to index something in
  `@bound` (`[8]`).
- We loop until all scanners have been bound and set in our chosen
  coordinate systems (`[4]`).
- Variable `$alice` (`[5]`) is our reference scanner for finding and
  binding new neighbors. It is taken from the `@bound` array, so it's
  already in the right coordinate system. Alas, in each iteration not
  all unbound scanners will be properly bound, so `@left` will keep
  track of those that will have to wait some more time.
- Variable `$umberto` (`[6]`) iterates over the unbound elements to see
  if it can be matched against `$alice`, i.e. if they are neighbors.
- All the magic of the match between `$alice` and `$umberto` is
  encapsulated within function `match-unbound` (`[7]`). This returns the
  representation of `$umberto` in the target coordinates system if the
  match is successful, leading to its addition to `@bound`, or nothing
  if the match fails, in which case `$umberto` is added to `@left` for
  future consideration.
- After sweeping through all `@unbound` scanners, we prepare for the
  next iteration by setting the `@left` scanners as those `@unbound`
  elements to analyze. If any.

Now this is a rather verbose description for a quite boring algorithm,
whose complexity is not even that great. If there are $N$ scanners,
the worst case would require $N * (N - 1)$ matches for an overall
complexity of $O(N^2)$.

Anyway, it's at least simple: just keep onboarding new elements from the
pool of unknowns until all of them have been placed. Like doing a puzzle
in a very systematic way.

Both parts of the puzzle can be solved easily once we have all our
scanners in place, with their absolute positions (and that of all
beacons too).

In the first part we are required to understand how many different
beacons are there. My go-to solution in these cases is to populate a
hash with the unique identifiers of all beacons (in this case, their
position represented as a string) and then count how many elements are
in the hash:

```raku
my %beacon-at;
for @bound -> $scanner {
   for $scanner<coords>.List -> $p {
      my $key = $p.join(',');
      %beacon-at{$key}++;
   }
}
my $part1 = %beacon-at.elems;
```

The second part is conceptually simpler: take any pair of scanners,
calculate their Manhattan distance, then take the maximum value. Again
not a fantastic complexity (still $O(N^2)$) but quite effective.

```raku
my $part2 = (@bound X @bound).map(
   -> ($foo, $bar) { ($foo<origin> «-» $bar<origin>)».abs.sum }
).max;
```

In this case [Raku][] is helping us a lot:

- hyperoperator `«-»` allows us to take the difference of the positions
  of a pair of scanners, coordinate by coordinate, getting back the
  difference as a vector;
- hyperoperator `».abs` takes the absolute value through all the
  dimensions, which is also the Manhattan distance component for each
  dimension;
- `.sum` does the final sum to get the Manhattan distance;
- `.max` takes the maximum value out of a list of Manhattan distances.

I guess it's everything for today, right?

What? *Well, ehr... yes*! We're missing the details for `match-unbound()`,
of course!

But... I guess this will be for another post. And another year!

Stay safe, stay tuned and enjoy the last hours of 2021!

[puzzle]: https://adventofcode.com/2021/day/X
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
