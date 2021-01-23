---
title: 'AoC 2016/19 - Halving Josephus'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-19 ]
comment: true
date: 2021-01-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 19][p19] from [2016][aoc2016]: part
> 2 of the puzzle is a detour that I call *halving Josephus*.
> This is a series of posts, [click here][series] to list them all!

[series]: {{ '/tagged#aoc-2016-19' | prepend: site.baseurl }}

I hope I'm not giving too much out, but after solving part 1 of [puzzle
19][p19] (see [AoC 2016/19 - Josephus problem]) I was presented with the
following *part 2*:

> Realizing the folly of their present-exchange rules, the Elves agree
> to instead steal presents from the Elf directly across the circle. If
> two Elves are across the circle, the one on the left (from the
> perspective of the stealer) is stolen from. The other rules remain
> unchanged: Elves with no presents are removed from the circle
> entirely, and the other elves move in slightly to keep the circle
> evenly spaced.

It's an interesting twist because it's different from the
generalizations of taking every $n$-th item (the default case being
taking every second item) and has this interesting *even*/*odd*
differentiation.

# Some brute force can help

As I'm requested to solve the puzzle with $3014603$ elves... going the
brute force way is *doable* although not fast at all.

As a matter of fact, here's what happened to me: I started a brute force
simulation, let it run and in the meantime worked on a more efficient
solution. Which arrived before the one from the brute force approach 😄

So is the brute force approach useful at all! Yes *it does*! It is
reasonable fast when run on smaller inputs, so it can help in looking at
the data and trying to spot any regularity that we can exploit to solve
the problem. Even if we don't *prove* that the regularity is going to
apply for whatever input... we can still try to code it, get a result
and cross fingers 😎

Here is a sub implementing the brute force approach for this problem:

```perl
sub josephus_bf ($n) {
   my @slots = 1 .. $n;
   while ((my $N = @slots) > 1) {
      my $opponent = $N % 1 ? ($N - 1) / 2 : $N / 2;
      splice @slots, $opponent, 1;
      push @slots, shift @slots;
   }
   return $slots[0];
}
```

It implements the problem almost literally:

- initialize with all applicable elves;
- the "current elf" is *always* the first one in the `@slots` array
  (`push @slots, shift @slots` makes sure to move it at the end of the
  array after its turn, so that its successor will be the first item in
  the next iteration)
- until there's more than one elf with a present, find out the index of
  the mid-placed elf (getting the lowered-number elf for an odd number
  of elves in `@slots`) and remove it (using `splice`).

# Looking at some data

Let's first get a look at some data for low numbers:

```
            11 ->  2    21 -> 15
 2 ->  1    12 ->  3    22 -> 17
 3 ->  3    13 ->  4    23 -> 19
 4 ->  1    14 ->  5    24 -> 21
 5 ->  2    15 ->  6    25 -> 23
 6 ->  3    16 ->  7    26 -> 25
 7 ->  5    17 ->  8    27 -> 27
 8 ->  7    18 ->  9    28 ->  1
 9 ->  9    19 -> 11    29 ->  2
10 ->  1    20 -> 13    30 ->  3
```

There are a couple of interesting patterns:

- the "winner" elf slot (starting from `1`) tends to increase until it
  reaches a point where it is reset. This is similar to what happens
  with the *traditional* [Josephus problem][];

- the *reset* seems to happen immediately after a power of $3$, and also
  powers of $3$ seem to have that the last elf is also the winner (e.g.
  see the values for $3$, $9$, and $27$);

- the increasing goes by one unit up to a point, then it goes by two
  units (apparently). It seems to go by one up to the double of the last
  power of $3$, in particular.

At this point we can leverage the brute force function again and check
what happens around other powers of $3$:

```
3^4 = 81     3^5 = 243     3^6 = 729

78 ->  75    240 -> 237    726 -> 723
79 ->  77    241 -> 239    727 -> 725
80 ->  79    242 -> 241    728 -> 727
81 ->  81    243 -> 243    729 -> 729
82 ->   1    244 ->   1    730 ->   1
83 ->   2    245 ->   2    731 ->   2
84 ->   3    246 ->   3    732 ->   3
```

and around their doubles:

```
2*3^4 = 162    2*3^5 = 486    2*3^6 = 1458

159 ->  78     483 -> 240     1455 -> 726
160 ->  79     484 -> 241     1456 -> 727
161 ->  80     485 -> 242     1457 -> 728
162 ->  81     486 -> 243     1458 -> 729
163 ->  83     487 -> 245     1459 -> 731
164 ->  85     488 -> 247     1460 -> 733
165 ->  87     489 -> 249     1461 -> 735
```

OK! From a mathematician's point of view these are fair clues that cry
for some demonstration. From an engineer's point of view... it's time to
*code*.

# Let's call it a heuristic...

... for lack of any formal demonstration.

The basic idea is the following:

- first, let's find the power of $3$ that is *immediately lower than, or
  equal to,* our number.
- if it's *equal* we're done: our small investigation suggests that
  returning the input number itself is a good guess;
- otherwise, we have to understand where we lie between that power of
  $3$ and the one immediately following and, depending on the position,
  go ahead:
  - if in the first half, the increase is one by one;
  - from the start of the second half on, the increase is two by two.

This is the code:

```
 1  sub josephus_ternary ($n) {
 2     my $u3 = 3 ** int(log($n) / log(3));
 3     return $n if $n == $u3;
 4     my $threshold = int($u3 * 2);
 5     return $n - $u3 if $n <= $threshold;
 6     return ($n - $u3) + ($n - $threshold);
 7  }
```

Variable $u3$ in line 2 is initialized to the power of $3$ we are after.
the ratio of the two logarithms is a way of calculating the logarithm in
base $3$; we take its integer part and the use it as an exponent for $3$
and *voilà* we have a power of $3$.

As promised, if this power of $3$ is equal to our input number... we
know pretty well that the last elf is the one that gets it all. Line 3
puts this in code.

Line 4 finds out the threshold between the *increment by one* and the
*increment by two* parts. Then we return the right value (lines 5 and 6)
depending on where `$n` lies with respect to this threshold.

# And it works!

As anticipated, while the *brute force* algorithm was still running with
an input of `3014603`, I was able to use `josephus_ternary` and get the
right answer: `1420280`.

Now you can, too.



[p19]: https://adventofcode.com/2016/day/19
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[AoC 2016/19 - Josephus problem]: {{ '/2020/01/24/aoc2016-19-josephus/' | prepend: site.baseurl }}
[Josephus problem]: https://en.wikipedia.org/wiki/Josephus_problem
