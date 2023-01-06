---
title: 'AoC 2022/3 - Misplaced supplies and where to find them'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-05 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 3][puzzle] from [2022][aoc2022]:
> we're definitely gone the abstract way here.

I like the background story of [Advent of Code][], even though I
understand that *sometimes* it can be difficult to frame a challenge
within it. My feeling is that this... was one of those times.

The final byproduct in puzzle 1 and, as it is eventually revealed,
puzzle 2 is a sum of *priorities*, which are assigned statically based
on the character. So going bottom-up here's the relevant function:

```raku
sub char-to-value ($char) {
   return 1 + $char.ord - 'a'.ord if $char ~~ /<[ a .. z ]>/;
   return 27 + $char.ord - 'A'.ord;
}
```

OK, with that out of the way, let's look at part 1. Here we have to
consider each input line/string as composed of two halves; our task is
to find the common character between them, turn it into a value with
`char-to-value` above and sum everything:

```raku
sub part1 ($inputs) {
   return $inputs.map({
      my $hlen = ($_.chars / 2).Int;
      my ($h, $l) =
         ($_.substr(0, $hlen), $_.substr($hlen)).map({ $_.comb.Set });
      char-to-value(($h ∩ $l).keys);
   }).sum;
}
```

[Raku][] comes with both batteries and a lot of nice tools tailored for
a lot of different tasks. In this case:

- we get each character using `comb`
- we don't care about them *individually*, but treat each half as a
  *set* of characters.
- with two sets available, finding the common character means finding
  the *intersection* of the two sets, which is what the `∩` operator is
  for.

Part 2 goes on a similar tune, only we have to find the common character
across triplets taken from the input. [Raku][] comes to help us with a
way to take the intersection of *many* sets at once with hyperoperator
`[∩]`:

```raku
sub part2 ($inputs) {
   gather {
      for @$inputs -> $a, $b, $c {
         take char-to-value(([∩] ($a, $b, $c)».comb».Set).keys)
      }
   }.sum;
}
```

I could not think of some clever/idiomatic way of expressing the concept
of *taking inputs three at a time*, so I just did that with the `for`
loop specification.

This somehow "breaks the flow" for composition, which would make adding
a final `.sum` complicated. So I thought of using `gather`/`take`. I
like it. Maybe one day it will be efficient, if it's not already.

[Full solution][].

Now, before leaving, [a hint][] from [mschaap][]:

> But you don't have to `.Set` the lists in order to be able to `[∩]`
> them, that is done automatically, see [my solution][].

I love that there's always something to learn!

All in all, a nice one... stay safe!

[puzzle]: https://adventofcode.com/2022/day/X
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/03.raku
[a hint]: https://www.reddit.com/r/adventofcode/comments/zb865p/comment/iyqm7w9/
[mschaap]: https://www.reddit.com/user/mschaap/
[my solution]: https://www.reddit.com/r/adventofcode/comments/zb865p/comment/iyqks7y/
