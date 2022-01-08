---
title: 'AoC 2021/23 - Then came amphipods...'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-10 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 23][puzzle] from [2021][aoc2021]:
> another tough puzzle!

It was about after solving day 19 that I thought *OK, now it should get
a little easier*. Hear hear, I was so much wrong, and the puzzle from
[day 22][] should have warned me.

This time we're introduced to [amphipods][amphipoda], little creatures
that have probably been generated in [Hanoi][] (maybe in one of [its
towers][tower]).

At this point in december I was kind of depleted of puzzle energies and
completely dazzled, like a boxer who took way too many hits. I just
wanted to arrive to that bell sound which would give me some additional
rest.

So I coded a solution that was relying on depth-first searching and some
search-tree cutting techniques to bring down the amount of computation.
Except that it was still taking *ages*.

So I cheated. I mean, sort of. I printed new, better solutions as long
as I found them, and then tried them after a while that no new one was
printed. And, eventually, I got it.

> Yes, I am ashamed of me now. Well, even then.

Stolen or not, anyway, I had the keys that unlock my mental block to
look at other player's solution before having solved the puzzle myself,
and [the thread][] was full of *Dijkstra, Dijkstra*!

Well, of course it already occurred to me to adopt a *best-first*
approach, but remember the boxer?!? Anyway, it would have been the right
thing to do, and [I did it afterwards][solution] (along with
implementing [Dijkstra.rakumod][] in [cglib-raku][], at last!).

I had the luck to recover a lot from my previous implementation, though,
because also in that case I was visiting a graph and I was already
thinking in terms of "finding all successors from a given node". Time
and again, though, I learned that a good algorithm makes all the
difference.

```raku
sub successors-factory ($graph) {
   return sub ($state) {
      my $nodes = $state<nodes>;
      my (@ok, @target);
      for (7 .. $nodes.end).reverse -> $j {
         if @ok[$j + 4] // 1 { @ok[$j] = $nodes[$j] == $j % 4 }
         else                { @ok[$j] = 0 }
         my $class = $j % 4;
         next if defined(@target[$class]) || @ok[$j];
         @target[$class] = $nodes[$j] == 4 ?? $j !! 0; # real target > 0
      }

      my @letter_for = < B C D A >;
      my $positions = $state<positions>;
      my @succs;
      for ^$positions -> $apod {
         my $p = $positions[$apod];
         next if @ok[$p];
         my $class = ($apod + 3) % 4;
         if ($p <= 6) { # in the corridor
            my $t = @target[$class] or next;
            my $cost = cost($graph, $state, $p, $t) or next;
            @succs.push: new-state($state, $apod, $t, $cost);
         }
         else { # in a "room"
            my $t = @target[$class];
            if ($t && (my $cost = cost($graph, $state, $p, $t))) {
               @succs.push: new-state($state, $apod, $t, $cost);
               next;
            }
            # add corridor positions
            for 0 .. 6 -> $t {
               my $cost = cost($graph, $state, $p, $t) or next;
               @succs.push: new-state($state, $apod, $t, $cost);
            }
         }
      }
      return @succs;
   }
}
```

In my particular representation, the whole thing is kept in a single
array with all positions, and the "rooms" where amphipods have to go
start from position 7. This is why I have the fancy `@letter_for` array
that places `A` at the end: the position of a letter is the remainder of
the division of the associated "room" modulo 4.

We iterate over all amphipods, skipping those that are already in place
(`@ok[$p]`) and looking at the position of the other ones:

- in the corridor? Then they can only go in their "room"
- in a room? Then we first check if they can go in their "room", and as
  a fallback we consider sending them in the corridor.

This puzzle drove me a little crazy, but was worth the effort, because I
had a small bug in my [PriorityQueue.rakumod][] (and [its
counterpart][PriorityQueue.pm] in [Perl][]) that prevented me from
updating the saved items as they changed priority on the way. Solving
puzzles saves code!

OK, enough rambling for today... stay safe!

[day 22]: https://adventofcode.com/2021/day/22
[puzzle]: https://adventofcode.com/2021/day/23
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[amphipoda]: https://en.wikipedia.org/wiki/Amphipoda
[Hanoi]: https://en.wikipedia.org/wiki/Hanoi
[tower]: https://en.wikipedia.org/wiki/Tower_of_Hanoi
[the thread]: https://www.reddit.com/rmnozs
[Dijkstra.rakumod]: https://github.com/polettix/cglib-raku/blob/main/Dijsktra.rakumod
[cglib-raku]: https://github.com/polettix/cglib-raku
[solution]: {{ '/assets/code/aoc2021-23.raku' | prepend: site.baseurl }}
[PriorityQueue.rakumod]: https://github.com/polettix/cglib-raku/blob/main/PriorityQueue.rakumod
[PriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/PriorityQueue.pm
[Perl]: https://www.perl.org/
