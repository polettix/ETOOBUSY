---
title: 'AoC 2022/11 - Monkey business'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][puzzle] from [2022][aoc2022]:
> cheating is bad. **BUT** cheating gets the job done!

So I confess, this is where I cheated. Only a bit, and *to be honest*
it's not cheating by the challenge standards. I mean, I came to the
solution all by myself, without looking at others' solutions before I
completed the puzzles myself.

So what's the cheating I'm talking about?

Well, it's in how I read the inputs:

```raku
sub get-inputs ($with-full) {
   return [
      monkey([79, 98],           sub { $^old * 19 },     23, 2, 3),
      monkey([54, 65, 75, 74],   sub { $^old + 6 },      19, 2, 0),
      monkey([79, 60, 97],       sub { $^old * $^old },  13, 1, 3),
      monkey([74],               sub { $^old + 3 },      17, 0, 1),
   ] unless $with-full;
   return [
      monkey([64],                              sub { $^old * 7 }    , 13, 1, 3),
      monkey([60, 84, 84, 65],                  sub { $^old + 7 }    , 19, 2, 7),
      monkey([52, 67, 74, 88, 51, 61],          sub { $^old * 3 }    ,  5, 5, 7),
      monkey([67, 72],                          sub { $^old + 3 }    ,  2, 1, 2),
      monkey([80, 79, 58, 77, 68, 74, 98, 64],  sub { $^old * $^old }, 17, 6, 0),
      monkey([62, 53, 61, 89, 86],              sub { $^old + 8  }   , 11, 4, 6),
      monkey([86, 89, 82],                      sub { $^old + 2 }    ,  7, 3, 0),
      monkey([92, 81, 70, 96, 69, 84, 83],      sub { $^old + 4 }    ,  3, 4, 5),
   ];
}

sub monkey ($items, &op, $divisor, $next-true, $next-false) {
   my %retval =
      items   => $items,
      op      => &op,
      divisor => $divisor,
      true    => $next-true,
      false   => $next-false;
   return %retval;
}
```

Yup, right - they are hardcoded. This works for my puzzle inputs only.
Considering that I might even use pencil and paper, massaging the inputs
a bit is not a big deal.

Anyway.

The *fun* part this day was in part 2, where we are requested to
potentially deal with humoungous *stress levels*. I mean, almost
literally.

Lucky me that I attended many Algebra courses and remembered one thing
or two. Like the fact that these modulo operations would help a lot
keeping the stress levels low. It sufficies to do all operations modulo
a *sufficiently large* number, that can cope with all the cases.

Which means: do operations modulo the product of all the different
divisibility test denominators.

So, here's how a single *round* goes for me in [Raku][]:

```raku
sub round (@monkeys, @stats, $divisor = 1) {
   state $period = [*] (2, 3, 5, 7, 11, 13, 17, 19, 23);
   for @monkeys.kv -> $i, $monkey {
      while $monkey<items>.elems {
         my $item = $monkey<items>.shift;
         @stats[$i]++;
         my $new = ($monkey<op>($item) / $divisor).Int % $period;
         if $new %% $monkey<divisor> {
            @monkeys[$monkey<true> ]<items>.push: $new
         }
         else { 
            @monkeys[$monkey<false>]<items>.push: $new
         }
      }
   }
}
```

The calculated `$period` is good for both the example data and my
specific puzzle input, YMMV.

At this point, the two parts are solved in the same way, just with
different numbers:

```raku
sub part1 (@monkeys) {
   my @stats;
   round(@monkeys, @stats, 3) for ^20;
   return [*] @stats.sort.tail(2);
}

sub part2 (@monkeys) {
   my @stats;
   round(@monkeys, @stats, 1) for ^10000;
   return [*] @stats.sort.tail(2);
}
```

This was also a good occasion to remember about `.tail($n)`.

[Full solution][].

Stay safe folks!

[puzzle]: https://adventofcode.com/2022/day/X
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/11.raku
