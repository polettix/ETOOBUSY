---
title: 'AoC 2021/8 - Treachery is contagious'
type: post
tags: [ advent of code, coding, rakulang, perl, algorithm ]
comment: true
date: 2021-12-11 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 8][puzzle] from [2021][aoc2021]:
> the first betrayal of [Raku][] 🙄

On december 8th I woke up early. I mean, it's a bank holiday in Italy,
and I was keen on getting some good result in [Advent of Code][], so why
not?

Countdown ticking... 4... 3... 2... 1... open!

I start reading and I don't know if it's the early hours, my aging
brain, or simply panic but *I barely understand what's written*.

Well, there's surely panic, because I do what most of us do under
panic: revert to a safe spot. Which, for me, means coding in [Perl][].
So yes, I confess this: my original solution to get the job done was in
[Perl][].

In my defense, I was probably drawn on the dark side by [The Treachery
of Whales][].

> Jokes apart, [Perl][] is amazing and regularly saves my day.

One thing I learned is to go fast up to the question. This was so true
in this case: the first part of the puzzle is actually a very simple
exercise of *counting* simple stuff, and I could have done it in *much
less* than the `10:36` I actually scored. At least TIL 😅

The second part was much harder, and honestly I didn't want my brittle
knowledge of [Raku][] to get in the way.

BUT.

This year I'm also determined into understanding more of [Raku][], so I
eventually translated my solution into it. And, while on it, I tried to
use some specific data structure that have to be *imagined* in [Perl][].

> As an example, think using a *hash* to implement a *set*.

So here I come, repentant but not too much 😉:

{% raw %}
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
   $filename.IO.lines.map({
      my @chunks = .comb: / \w+ /;
      my @hints = @chunks.splice(0, 10);
      [@hints, @chunks];
   }).Array;
}

sub solve ($inputs) {
   return (part1($inputs), part2($inputs));
}

sub part1 ($inputs) {
   state %cfl = 2 => 1, 4 => 4, 3 => 7, 7 => 8;  # unambiguous lengths
   return $inputs
      .map({$_[1].Slip})            # get only outputs, individually
      .grep({%cfl{.chars}:exists})  # filter the right lengths only
      .elems;                       # count 'em
}

sub part2 ($inputs) {
   state %cfl = 2 => 1, 4 => 4, 3 => 7;  # unambiguous, used lengths
   my $sum = 0;
   for @$inputs -> ($hints, $outputs) {
      # first, let's collect a few statistics and detect 1, 4, and 7
      my %set;
      my $seen = BagHash.new;
      for @$hints -> $hint {
         $seen.add($_) for my @chars = $hint.comb: / \w /;
         %cfl{my $n = @chars.elems}:exists or next;
         %set{%cfl{$n}} = @chars.Set;
      }

      # next, build a mapping from "right" segment name to "jumbled"
      # mapping for "a" is by difference from "7" and "1"
      my %sof = a => (%set<7> (-) %set<1>).keys[0];

      # some frequencies are known
      state %known = 4 => 'e', 6 => 'b', 9 => 'f';

      # iterate over the %seen statistic to determine the mapping
      for $seen.kv -> $k, $n {
         if (%known{$n}:exists) { %sof{%known{$n}} = $k }
         elsif ($n == 8) { %sof<c> = $k if $k ne %sof<a> }
         elsif ($n == 7) {
            my $right = (%set<4> (-) set($k)).elems == 3 ?? 'd' !! 'g';
            %sof{$right} = $k;
         }
      }

      # with the %sof mapping we can assign a value to each sequence
      #my %nfor = (0 .. 9).map: { assemble(%sof, $_) => $_ };
      my %nfor = assemble(%sof);

      # we can determine the output digits at last
      $sum += $outputs.map(
         {
            my $key = .comb(/\w/).sort({$^a cmp $^b}).join('');
            %nfor{$key};
         }
      ).join('');
   }
   return $sum;
}

sub assemble (%sof) {
   state @segments-for = [
      [< a b c   e f g >],
      [<     c     f   >],
      [< a   c d e   g >],
      [< a   c d   f g >],
      [<   b c d   f   >],
      [< a b   d   f g >],
      [< a b   d e f g >],
      [< a   c     f   >],
      [< a b c d e f g >],
      [< a b c d   f g >],
   ];
   return (0 .. 9).map: -> $n {
      %sof{@segments-for[$n].Slip}.sort({ $^a cmp $^b }).join('') => $n
   };
}
```
{% endraw %}

The margins of this blog are too narrow to put a full explanation of
what's going on... I hope the comments are sufficient!

Stay safe everyone!

[puzzle]: https://adventofcode.com/2021/day/8
[The Treachery of Whales]: https://adventofcode.com/2021/day/7
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
