---
title: 'AoC 2022/4 - Poor planning'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-06 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 4][puzzle] from [2022][aoc2022]:
> planning can use some improvement next year!

Citing [this solution][]:

> I'm starting to think that Santa should reconsider his elf workforce.

Well, at least the lack of proper upfront planning seems to provide us
plenty of occasions to help a bit.

Each input line is a story by itself in this case, and we have to count
things. Input lines represent data related to pairs of elves (let's call
them *left* and *right*); each elf is given an integer (inclusive)
range. So the *left* elf will receive range $[l, L]$ and the *right*
one $[r, R]$.

Let's read it as a sequence of arrays, each containing `[$l, $L, $r,
$R]` for a pair:

```raku
my @inputs = '04.input'.IO.lines.map({ [.comb(/\d+/)] });
```

In part 1, we have to count all pairings where one range completely
contains the other. Let's consider the following quantity:

$$
(r - l) \cdot (R - L)
$$

i.e. the difference between the two minimum ends of the range, times the
difference between the two maximum ends:

- when the *right* range contains the *left* one, the first quantity
  will be non-positive and the second one will be non-negative. Hence,
  the product will be non-negative, i.e. less than, or equal to, zero.
- On the other hand, when the *left* range includes the *right*, the
  signs will be reversed for both quantities, and we still end up with a
  non-negative product.
- Every other case yields a strictly positive product.

Hence, we can just test that the product is less than, or equal to, zero
and count them all:

```raku
put +@inputs.grep(-> ($l, $L, $r, $R) { ($r - $l) * ($R - $L) <= 0 });
```

Part 2 goes on a similar tune, but this time we are asked to figure out
how many pairs have at least one overlapping value. This time we can
consider the following quantity:

$$
(R - l) \cdot (L - r)
$$

It's easy to see that one of these two quantities *must* be
non-negative, because one of the following is true:

$$
l \le L \le R \Rightarrow (R - l) \ge 0 \\
r \le R \le L \Rightarrow (L - r) \ge 0
$$

When there is an overlap, the *other* difference is non-negative too;
otherwise, it's strictly negative. Hence, our product will be
non-negative if, and only if, there is an overlap.

In [Raku][] terms:

```raku
put +@inputs.grep(-> ($l, $L, $r, $R) { ($R - $l) * ($L - $r) >= 0 });
```

[Full solution][].

Stay safe and have fun!


[puzzle]: https://adventofcode.com/2022/day/4
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[this solution]: https://www.reddit.com/r/adventofcode/comments/zc0zta/comment/iywc3vy/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/04.raku
