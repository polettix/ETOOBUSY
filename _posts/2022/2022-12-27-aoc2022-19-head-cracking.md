---
title: 'AoC 2022/19 - Head cracking'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-27 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 19][puzzle] from [2022][aoc2022]:
> instead of me cracking this challenge, the challenge cracked my head!

This was, for me, the most difficult challenge of this year. Getting it
on a monday did not help, because I had to work and then spent a lot of
time in the evening/night... to no avail.

Then I kind of freaked out until... today. My personal discipline
imposes me to *solve* the puzzle with the right answer before looking
for other solutions, and (luckily) I did. As I wanted to minimize the
possible "noise sources", I decided to shift gears and solve it in
[Perl][], which is much more my... *first language*, so to say.

Then, of course, I looked at others' solutions and implemented one in
[Raku][]. Special thanks to [frufru6][] and [the non-optimized
solution][frufru6-solution], where I draw most of the inspiration for
the [Raku][] implementation, as well as a couple of [optimization
hints][] by [Coffee\_Doggo][cd].

OK, enough talking. The solution is basically a breadth-first search
over the space, taking care to prune the search tree in a few spots:

- cutting solutions that cannot go beyond the best found so far (even
  assuming that there will be a new geode-cracking robot at each
  following step, which is extremely optimistic).
- Avoiding further expansion of conditions where *geode-cracking* robots
  can be generated.
- Avoiding the expansion of nodes that generate a robot, when the same
  robot could have been generated at the previos step, but we're
  investigating a pause instead.
- Capping the number of robots according to the maximum amount of
  resources that are needed (so there's no cap for geode-cracking
  robots). This makes sense because the robot-generating machine can
  only produce a single robot per minute.

These three seem pretty spot-on, even though I might question that the
second one really holds in the very general case. Whatever, it
eventually worked on my inputs!

There is another heuristic that I copied from [frufru6][]'s
[non-optimized solution][frufru6-solution]. Briefly speaking, we put cap
on the *amount of resources* for each type. The rationale is that excess
resources are not used (*usually!*) and putting the cap allows
restricting the possible values, increasing the possibility to hit an
already-analyzed combination and giving space to some more pruning of
the search tree. This, too, works for all my inputs, so I call it a win.

Here's the code, starting with reading the inputs:

```raku
class BluePrint { ... }
sub get-inputs ($filename) {
   [ $filename.IO.lines.map: { BluePrint.new(line => $_) } ]
}

# ...

class BluePrint {
   has $.bid;
   has @!costs-for;
   has @!robot-cap-for;
   has @!resource-cap-for;

   submethod BUILD (:$line) {
      my ($bid, $rr, $cr, $br, $bc, $gr, $gb) = $line.comb(/\d+/)».Int.Slip;
      $!bid = $bid;
      @!costs-for =
         [ $rr,   0,   0,   0 ], # ore
         [ $cr,   0,   0,   0 ], # clay
         [ $br, $bc,   0,   0 ], # obsidian
         [ $gr,   0, $gb,   0 ]; # geodes
      @!robot-cap-for = ($rr, $cr, $br, $gr).max, $bc, $gb, Inf;
      @!resource-cap-for = (@!robot-cap-for «*» 2) «-» 2;
   }

   # ...
}
```

Using a class seemed... *right*. I don't know how much performance this
chops off, though.

The main search function, as anticipated, does BFS with some pruning
here and there:

```raku
method max-geodes ($time) {
    $*ERR.say("blueprint $!bid");
    my @consider-all = True xx 3;
    my @stack = [[0 xx 4], [1, |(0 xx 3)], $time - 1],;
    my %seen;
    my $best = -1;
    while @stack {
        my $frame = @stack.pop;
        my ($resources, $n-robots, $time, $consider) = @$frame;
        $consider //= @consider-all;

        # cut seen states, cap resources. No need to cap geodes!
        for ^3 -> $i {
        $resources[$i] = @!resource-cap-for[$i]
            if $resources[$i] > @!resource-cap-for[$i];
        }
        my $key = (|$resources, |$n-robots, $time).join(' ');
        next if %seen{$key}++;

        my $best-hope = $resources[3] + $n-robots[3] * (1 + $time)
        + ((1 + $time) * $time) div 2;
        next if $best-hope < $best;

        if self.can-build($resources, $n-robots, 3) { # geode-cracking, yay!
        $resources = [ |$resources ]; # clone
        $n-robots = [ |$n-robots ];         # clone
        self.build($resources, $n-robots, 3);
        @stack.push: [$resources, $n-robots, $time - 1]
            if $time > 0;
        }
        else {
        my @future-consider = |@consider-all;
        for ^3 -> $robot { # don't consider geode-cracking, see above
            next unless $consider[$robot]
                && self.can-build($resources, $n-robots, $robot);
            @future-consider[$robot] = False;
            my @new-resources = |$resources;
            my @new-n-robots  = |$n-robots;
            self.build(@new-resources, @new-n-robots, $robot);
            @stack.push: [@new-resources, @new-n-robots, $time - 1]
                if $time > 0;
        }

        # just let time pass here
        $resources «+=» $n-robots;
        @stack.push: [$resources, $n-robots, $time - 1] if $time > 0;
        }

        $best = $resources[3] if $time == 0 && $best < $resources[3];
    }
    return $best;
}
```

[Full solution][].

Stay safe!

[puzzle]: https://adventofcode.com/2022/day/19
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[optimization hints]: https://www.reddit.com/r/adventofcode/comments/zpihwi/comment/j0vvtdt/
[frufru6-solution]: https://www.reddit.com/r/adventofcode/comments/zpihwi/comment/j0wi3x1/
[frufru6]: https://www.reddit.com/user/frufru6/
[cd]: https://www.reddit.com/user/Coffee_Doggo/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/19.raku
