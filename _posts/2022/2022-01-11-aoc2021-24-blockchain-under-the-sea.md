---
title: 'AoC 2021/24 - Blockchain under the sea'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 24][puzzle] from [2021][aoc2021]:
> taming exponential explosion and magic smoke.

This day's puzzle is *special*.

Usually we have to figure out what to do by reading through the puzzle
description, and look at the specific inputs only to figure out how to
parse it and then our specific solution.

This time, though, either we have **a lot** of computational power, or
we have to figure out what's going on from the inside and find out a way
to cut down the exponential growth of the brute force approach.


It's a program for a specific, simple CPU with 4 registers, taking an
input string of 14 digits that has to be crafted to obtain a specific
result (0). Overall, the program reminds me of calculating some hash
function, so the goal of obtaining a *specific* result reminds me of
Bitcoin mining and in general of blockchain fun.

I can only guess that *my* specific input is a small variation of the
same puzzle. The program is composed of 14 sections that are variations
from the same template, like the following where the places with
differences are highlighted with arrows and letters `i`, `j`, and `k`:

```
inp w
mul x 0
add x z
mod x 26
div z 1    # <- i
add x 12   # <- j
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 1    # <- k
mul y x
add z y
```

Of the four registers, `w` is always used to get one input digit, while
`x` and `y` are always reset inside each function. So, the only one that
goes through the sequence of operations is register `z`.

The whole function can be syntesized as follows:

```raku
sub basic-function ($i, $j, $k, $z, $w) {
   my $x = (($z % 26) + $j == $w) ?? 0 !! 1;
   ($z / $i).Int * (25 * $x + 1) + ($w + $k) * $x;
}
```

where `$z` comes from the previous function (starts at 0), `$w` comes
from the input sequence under test, and the other three parameters are
specific for each of the 14 sections of the whole program.

Of the three parameters, `$i` is the most interesting, because it can
only assume values 1 and 26. A 1 generally means that `$z` will come out
greater than how it came in, while 26 leaves space for going down by
choosing the right value for `$w`. As we are aiming to reach 0
eventually, this means that we have to choose *that* specific value in
order to reach our goal.

Out of 14 functions, 7 go up and 7 allow to go down, so instead of
$9^14$ possible arrangements we only have to sift through at most $9^7$,
because the 7 functions that can go down will have their value for `$w`
fixed in order to actually go down. Muuuch better.

To solve to whole puzzle, we first read all input functions and record
their values for `$i`, `$j`, and `$k` in an array of triples:

```raku
sub get-inputs ($input) {
   my (@short, @short-cur);
   my (@full,  @full-cur);
   for $input.IO.lines -> $line {
      with $line {
         when /^ div \s+ z \s+ <( \-? \d+ )> / {
            @short-cur[0] = +$/;
         }
         when /^ add \s+ x \s+ <( \-? \d+ )> / {
            @short-cur[1] = +$/;
         }
         when /^ add \s+ y \s+ <( \-? \d+ )> / {
            @short-cur[2] = +$/;
         }
         when 'add z y' { @short.push: [@short-cur.List] }
      }

      my $op = $line.comb(/\S+/);
      if ($op[0] eq 'inp') {
         @full.push: [@full-cur.List] if @full-cur.elems;
         @full-cur = ();
      }
      else {
         @full-cur.push: $op;
      }
   }
   @full.push: [@full-cur.List] if @full-cur.elems;
   return {short => @short, full => @full};
}
```

The `basic-function` is transformed to use each triple, but it's
basically the same function and I'm penalized by my brittle [Raku][]-fu
here:

```raku
sub eval-short ($func, $z, $w) {
   my ($i, $j, $k) = @$func;
   my $x = (($z % 26) + $j == $w) ?? 0 !! 1;
   ($z / $i).Int * (25 * $x + 1) + ($w + $k) * $x;
}
```

The quest for a valid arrangement is performed recursively, using each
function for different `$depth`s, until we reach the final one where we
check whether `$z` has the *right* value or not:

```raku
sub eval-rec ($funcs, $greatest = True, $depth = 0, $z = 0, @w = []) {
   return $z == 0 ?? @w.join('') !! '' if $depth == $funcs.elems;
   my $func = $funcs[$depth];
   my @candidates;
   if $func[0] == 26 { # might going backwards, yay!
      my $w = $z % 26 + $func[1];
      @candidates.push: $w if 1 <= $w <= 9;
   }
   else { # try 'em all...
      @candidates = 1 .. 9;
      @candidates = @candidates.reverse if $greatest;
   }
   for @candidates -> $w {
      my $outcome = eval-rec($funcs, $greatest, $depth + 1,
         eval-short($func, $z, $w), [@w.Slip, $w]);
      return $outcome if $outcome.chars;
   }
   return '';
}
```

As anticipated, parameter `$i` (which is `$func[0]` here makes all the
difference. If it is equal to 26, we have our chance to "go down" by
choosing the right value for `$w` (i.e. the right value for the input
digit). This is calculated according to the value of `$j`/`$func[1]` and
requires no try-or-backtrack. In case no suitable value can be found,
then `@candidates` will be left empty, the `for` loop will be ignored
and the `return` will trigger some backtracking in the upper level call.

Otherwise... we have to go through several possible values and get *the
best*. The two halves of the puzzle ask for the bigger and the smaller
values, so we have to count down from 9 to 1 in part 1 and up from 1 to
9 in part 2. This is why we also have a `$greatest` input variable, set
by default (for part 1) but optionally overridable (for part 2).

```raku
sub part1 ($inputs) { return eval-rec($inputs, True)  }
sub part2 ($inputs) { return eval-rec($inputs, False) }
```

Overall a nice puzzle, although I'm not sure I totally enjoyed it. I
mean, looking into the functions and getting the gist of their
implementation *is* the puzzle, but left me with the strange feeling
that my solution might not be that generic and valid for other inputs
too.

Anyway... I got past it, and I hope every one of you will stay safe!


[puzzle]: https://adventofcode.com/2021/day/24
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
