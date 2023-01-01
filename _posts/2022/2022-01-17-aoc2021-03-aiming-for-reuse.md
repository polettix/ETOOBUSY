---
title: 'AoC 2021/3 - Aiming for reuse'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-17 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 3][puzzle] from [2021][aoc2021]:
> aiming for reuse of code.

This day's puzzle introduces another theme that we will encounter again
during this year's installment: the *wall of text*. There must be some
trick that the fast people use to sift through all that text, but I
honestly don't know.

```raku
#!/usr/bin/env raku
use v6;

sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.sample')) {
   my $inputs = get-inputs($filename);
   my ($part1, $part2) = solve($inputs);

   my $highlight = "\e[1;97;45m";
   my $reset     = "\e[0m";
   put "part1 $highlight$part1$reset";
   put "part2 $highlight$part2$reset";
}

sub get-inputs ($filename) {
   $filename.IO.basename.IO.lines».comb(/<[0 1]>/)».Array;
} ## end sub get_inputs ($filename = undef)

sub solve ($inputs) {
   return (part1($inputs), part2($inputs));
}

sub part1 ($inputs) {
   my @benchmarks = $inputs.elems / 2 xx $inputs[0].elems;
   my @sums = [Z+] @$inputs;
   my $epsilon = ((@sums Z< @benchmarks)».Int).join('');
   my $gamma = TR/01/10/ given $epsilon;
   return $epsilon.parse-base(2) * $gamma.parse-base(2);
}

sub part2 ($inputs) {
   my $result = 1;
   TARGET:
   for 0, 1 -> $t {
      my @candidates = @$inputs;
      for 0 .. @candidates[0].end -> $bit {
         my @s; # array of arrays of arrays, top indexed by 0, 1
         @s[$_[$bit]].push: $_ for @candidates;
         @candidates = @(@s[0] <= @s[1] ?? @s[$t] !! @s[1 - $t]);
         if (@candidates.elems == 1) {
            $result *= @candidates[0].join('').parse-base(2);
            next TARGET;
         }
      }
   }
   return $result;
}
```

The first part is about considering each bit from the inputs, in
isolation to the other bits. To figure out whether there are more 0 or 1
values, it's sufficient to sum them all and compare against the half of
their number. This explains the `@benchmarks`.

There's a lot of showing off in this part 1, e.g. the hyper-application
of the zipped version of the sum. A compact way to sum all the inputs
bit by bit (assuming, as it is in this case, that all input sequences
are stored as arrays of 0 and 1 values).

Calculating `$epsilon` is easy by comparing each bit position with the
benchmark. Again, we leverage the Zip operator here, though not in its
hyper form.

It's interesting to note that `$gamma` is the bitwise complement of
`$epsilon`, so this is how we calculate it.

Part 2 is a bit more... *convoluted* and I could not figure out how to
show-off a few tricks. So there we go, with traditionally nested `for`
loops as well as `if` conditions etc. etc. At each stage going ahead, we
work on a different "vertical" slice like before, this time restricted
to the the "survivors" in the previous pass.

So... this completes the [2021][aoc2021] edition of [Advent of Code][].
Did you enjoy it? Complete it? Get crazy for it? Let me know!

[puzzle]: https://adventofcode.com/2021/day/3
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
