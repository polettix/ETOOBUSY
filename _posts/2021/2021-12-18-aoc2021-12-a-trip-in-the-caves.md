---
title: 'AoC 2021/12 - A trip in the caves'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-18 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 12][puzzle] from [2021][aoc2021]:
> a trip in the caves.

Today's puzzle is about visiting a graph. I'm always amazed by how many
different interesting problems can be formulated around them, each
requiring its own algorithm to be solved.

I'm also amazed by my being amazed, now that I think of it. Why
shouldn't be that many problems and that many algorithms?!?

Anyway, this time we have to find all possible paths from a beginning
node `start` to the final node `end`, with some constraints about
passing multiple times in the nodes in between. Without these
constraints there would be *a tad* too many solutions... infinite!

Anyway, in this case we have to mark *lowercase-named* caves (our nodes)
when we pass through them, so that we avoid passing through them twice.
This sets us up for part 1.

Part 2 is almost the same, with the small twist that we are allowed to
pass *twice* through *at most* one lowercase-named cave. This can easily
be tracked with a kind of *semaphore* variable to mark if we can still
do the double pass or not.

As a result, both visits to the graph can be coalesced into a single
function, for maximum refactoring.

```raku
#!/usr/bin/env raku
use v6;

sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.tmp')) {
   my $inputs = get-inputs($filename);
   my ($part1, $part2) = solve($inputs);

   my $highlight = "\e[1;97;45m";
   my $reset     = "\e[0m";
   put "part1 $highlight$part1$reset";
   put "part2 $highlight$part2$reset";
}

sub get-inputs ($filename) {
   my %neighbors-for;
   for $filename.IO.words -> $pair {
      my ($x, $y) = $pair.split('-');
      %neighbors-for{$x}.push: $y;
      %neighbors-for{$y}.push: $x;
   };
   return %neighbors-for;
}

sub solve ($inputs) {
   my @counts = 0 xx 2;
   my @stack = ['start'],;
   my $twice-taken = 0; # "can go twice" semaphore
   my %flag;
   while @stack {
      my $top = @stack[*-1];  # top frame in the stack
      my $key = $top[0];      # key of top frame

      if ($top.elems == 1) { # first visit, entering node after a push
         if ($key eq 'end') { # reaching the end is a special condition
            ++@counts[0] unless $twice-taken;  # path valid for part 1
            ++@counts[1];                      # path valid for part 2
            @stack.pop;                        # "return"
            next;
         }

         # check if we can visit this node (possibly... again)
         if %flag{$key}.so && ($twice-taken || $key eq 'start') {
            @stack.pop;      # "return"
            next;
         }

         # lowercase caverns get flagged to avoid multiple visits
         %flag{$key}++ if $key ~~ / <[ a..z ]> /;
         $twice-taken = 1 if %flag{$key} && %flag{$key} > 1;

         # regular, intermediate node - add list of successors to visit
         $top.push: [$inputs{$key}.List];
      }

      if ($top[1].elems) { # still successors to go, try a new one
         @stack.push: [$top[1].shift];
      }
      else { # no more successors for this frame
         %flag{$key}-- if %flag{$key};    # can pass here again
         $twice-taken = 0 if %flag{$key}; # free this up too, in case
         @stack.pop;     # "return"
      }
   }
   return @counts;
}
```

I hope the comments make things clear... stay safe folks!


[puzzle]: https://adventofcode.com/2021/day/12
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
