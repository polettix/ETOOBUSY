---
title: 'AoC 2022/16 - Pressured shame'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 16][puzzle] from [2022][aoc2022]:
> with a little help from trial-and-error...

> **UPDATE**: this post is incomplete, the full solution (including part
> 2) is provided in [AoC 2022/16 - Paying a debt][].

So... this was hard. December 16th was a working day (mostly, I was in
quasi-vacation) so I could not devote *all the time* to the puzzle.

Which means that I managed to get a decent solution for part 1 (runs in
17 seconds, which is fair by my standards and expectations), but somehow
botched part 2.

So I did what I've also done last year in this case: *cheat a bit*.
Still solved the puzzle using my solution, no looking at hints and so
on, but when it was clear it might take *ages* then I coded it to spit
out the best result *so far* as soon as a new one was found. Then wait
until things seems stable, and *try that*.

This approach eventually paid. My first guess was rejected (I could have
avoided it by just waiting some 10 seconds more), then I got it right.

Hooray for getting the star, shame on me for not coming up with a decent
solution for part 2. I call it a draw.

Anyway, let's at least take a look at part 1, and let's start with
reading the inputs. I opted for a simplified parsing regular expression
to just collect stuff in the right places; this has been interesting
because I got to (re)discover the [Match][] class/object.

```raku
sub get-inputs ($filename) {
   $filename.IO.lines.map(
      {
         my $match = m{^Valve \s+ (\S+) .*? (\d+) .*? valves? \s+ (.*)};
         $match[0].Str => {
            name     => $match[0].Str,
            rate     => $match[1].Int,
            adjacent => $match[2].comb(/\w+/).Array,
         };
      }
   ).Hash;
}
```

With a little insight from a few days later, I'd probably write it like
this for added readability:

```raku
sub get-inputs ($filename) {
   $filename.IO.lines.map(
      {
         my $match = m{^Valve \s+
            $<name>=(\S+) .*?
            $<rate>=(\d+) .*?
            valves? \s+ $<adjacencies>(.*)};
         $match[0].Str => {
            name     => $match<name>.Str,
            rate     => $match<rate>.Int,
            adjacent => $match<adjacencies>.comb(/\w+/).Array,
         };
      }
   ).Hash;
}
```

Anyway, we're not here to do simple parsing, we're here to crack a
puzzle. At least, the first part of it.

My first --and only-- insight was to get rid of all 0-flow valves
because they get in the way without providing any advantage. So I
decided to calculate a different graph containing only non-null valves
(so to speak), where the arcs between nodes give the best time to go
from one to the other. As it happens, I have [an implementation of the
Floyd-Warshall algorithm][fw] around, so I used it:

```raku
sub generate-graph ($inputs) {
   class FloydWarshall { ... }
   my $fw = FloydWarshall.new(
      identifier => -> $v { $v },
      distance   => -> $v, $w { 1 },
      successors => -> $v { $inputs{$v}<adjacent>.Slip.Array },
      starts     => ['AA'],
   );
   my @keys = $inputs.keys.grep({ $inputs{$_}<rate> }).sort;
   my %allowed = @keys.Set;
   my %edges;
   for ('AA', @keys).flat -> $v {
      for @keys -> $w {
         next if $v eq $w;
         my @path = $fw.path($v, $w);
         %edges{$v}{$w} = @path - 1;
      }
   }
   return {
      nodes => ('AA', @keys).flat.map(
         { $_ => hash(name => $_, rate => $inputs{$_}<rate>) }
      ).Hash,
      edges => %edges,
   };
}
```

Now my problem was to find the best score given the rules and this
*equivalent* graph, which is what `find-best-score` is for:

```raku
sub find-best-score ($graph, $node, $minutes, $done = {}) {
   return 0 if $minutes <= 0 || $done{$node};
   $done{$node} = 1;

   my $score = $graph<nodes>{$node}<rate> * ($minutes - 1); # take

   my $best-sub-score = 0;
   for $graph<edges>{$node}.kv -> $neighbor, $cost {
      next if $done{$neighbor};
      my $score = find-best-score($graph, $neighbor, $minutes - 1 - $cost, $done);
      $best-sub-score = $score if $best-sub-score < $score;
   }

   $done{$node} = 0;
   return $score + $best-sub-score;
}
```

It's a recursive solution implementing a *depth-first search* over the
possible alternatives, with a *cut* condition on having run out of time
(i.e. `$minutes` having dropped to 0 or lower) or having already visited
a specific node (this is cached through argument `$done`, which starts
empty).

At each iteration, we visit the input `$node`, which is why we start at
`AA`:

```raku
sub part1 ($inputs) {
   my $graph = generate-graph($inputs);
   return find-best-score($graph, 'AA', 31);
}
```

We also start at minute `31` (instead of 30) because in my hurry I
decided that `$minutes` would be the minute *from which* I entered a
specific node/state. In hindsight, this is quite funny because the
changes to make it different (and more intuitive) seem trivial.

Anyway, back to `find-best-score`, the *basic* score at this point is
taken by opening the valve and accounting for its pressure release from
the minute *after* (see above about it...) on to the end of the
simulation.

After that, as anticipated, it's just a depth-first search. The `$done`
cache is used in two places, not necessarily because this is actually
needed, but because I changed my mind a few times and I decided to leave
the additional check just to be on the safe side. For each alternative,
I'm keeping the `$best-sub-score` so that I can use it to return the
overall score for this node (i.e. the *intrinsic* score plus the best
score with recursion).

I'll not put the proper answer to part 2 here, because my own solution
is despicable *at best*, and I have yet to code a proper one. Anyway, my
self-imposed rule allowed me to go through the [SOLUTION MEGATHREAD][sm]
(because I did solve the puzzle and get the starts, eventually), so I
read how I was supposed to address this.

Suppose that we have the solution... what would it be like? Surely...

- the human and the elephant open *different* sets of valves, because it
  makes no sense for either one to open the same valve as the other
- they *jointly* choose sets that *overall* lead to an optimal solution.

The second bullet tells us that it's not necessarily good to take the
*best* solution in 26 minutes for one of the two, then figure out the
best solution in 26 minutes over the other valves that were not open in
the first run. This "greedy" approach might land us on a sub-optimal
solution.

Instead, one way is to do something like this:

- compute *all* solutions that can be obtained in 26 minutes and store
  them in a *basket*
- take every possible pair from the basket, rejecting pairs that overlap
  (i.e. where the same valve appears in both solutions)
- take the best pair out of the non-rejected ones.

Well, there are *still* things to iron out with this plan. One thing is
that it might be that *every* pair might have an overlap. To see this,
consider if the total simulation time were 1000 minutes instead of 26:
sure every sequence would fit this huge time, including every valve at
some point. Result: all solutions would share all valves, representing a
permutation over them.

So yeah, I still have to go some way before I have a general solution
program.

> **UPDATE**: the full solution (including part 2) is provided in [AoC
> 2022/16 - Paying a debt][].

Cheers!


[puzzle]: https://adventofcode.com/2022/day/16
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Match]: https://docs.raku.org/type/Match
[fw]: https://github.com/polettix/cglib-raku/blob/main/FloydWarshall.rakumod
[sm]: https://www.reddit.com/r/adventofcode/comments/zn6k1l/2022_day_16_solutions/
[AoC 2022/16 - Paying a debt]: {{ '/2023/01/07/aoc2022-16-debt-payment/' | prepend: site.baseurl }}
