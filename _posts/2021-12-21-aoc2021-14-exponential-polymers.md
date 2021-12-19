---
title: 'AoC 2021/14 - Exponential polymerization'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 14][puzzle] from [2021][aoc2021]:
> taming exponential growth in the evolution mechanism.

This is another take to a two-fold puzzle in which the first part is
well within the bounds of doing that with simple brute force, but the
second one is proibitively forbidden from doing so.

This time I didn't have to think too much about this fact, just by
looking at the results in the puzzle example:

> In the above example, the most common element is B (occurring
> 2192039569602 times) and the least common element is H (occurring
> 3849876073 times); subtracting these produces 2188189693529.

I surely don't have all that memory!

The key here is that we only need counting stuff, but we are not
required to keep the whole polymer sequence. This means that something
like this:

```
ABABABABABABABABABAB
```

can be represented as `AB` occurring 10 times and `BA` occurring 9.

Each pair will then evolve independently, but all equal pairs will
evolve in the same manner. So our generic pair `AB` will evolve like
this (assuming we have to insert a `C`):

- the number of `AC` is incremented by 10 units;
- the number of `CB` is incremented by 10 units.

In the same spirit, if our generic pair `BA` is expanded with a `D` in
between:

- the number of `BD` is incremented by 9 units;
- the number of `DA` is incremented by 9 units.

We calculate the evolution in a separate hash, then assume the new hash
is the starting point of a future iteration.

This can then be used in both parts, with different number of
iterations.

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
   my @words = $filename.IO.lines.comb: / \w+ /;
   my $start = @words.shift;
   my %new-letter-for = @words;
   return {
      start => $start,
      nlfor => %new-letter-for,
   };
}

sub solve ($inputs) {
   my $nlfor = $inputs<nlfor>;
   my @s = $inputs<start>.comb: / \w /;
   my $bag = (@s Z @s[1 .. *])».join('').Bag.Hash;
   my %count = @s.Bag.Hash;
   my $part1;
   for 1 .. 40 -> $step {
      my %new;
      for $bag.kv -> $key, $factor {
         my @items;
         if $nlfor{$key}:exists {
            my $m = $nlfor{$key};
            %count{$m} += $factor;
            my ($l, $r) = $key.comb: / \w /;
            @items.push: $l ~ $m, $m ~ $r;
         }
         else { @items.push: $key };
         for @items -> $item {
            %new{$item} //= 0;
            %new{$item} += $factor;
         }
      }
      $bag = %new;
      $part1 = %count.values.max - %count.values.min if $step == 10;
   }
   return $part1, %count.values.max - %count.values.min;
}
```

The `%new` is the collector for the result of a new iteration, which is
eventually kept for future ones in `$bag`.

The intermediate result at step 10 is collected along the way, so the
`solve` function does a single iteration from 1 to 40.

I guess it's everything, please ask if you have questions and
otherwise... stay safe!

[puzzle]: https://adventofcode.com/2021/day/14
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
