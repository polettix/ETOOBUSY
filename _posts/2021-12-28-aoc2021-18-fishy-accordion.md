---
title: 'AoC 2021/18 - Fishy accordion'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 18][puzzle] from [2021][aoc2021]:
> using a grammar for a side reason.

This day's puzzle was an interesting one because it allowed me to
discover a bit about myself.

Let's move on in order, anyway.

In a nutshell, we're given a string describing a binary tree like this:

```
[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[8,2]]]
```

which corresponds to this:

```
-+-+-+-+- 1
 | | | |
 | | | +- 3
 | | |
 | | +-+- 5
 | |   |
 | |   +- 3
 | |
 | +-+-+- 1
 |   | |
 |   | +- 3
 |   |
 |   +-+- 8
 |     |
 |     +- 7
 |
 +-+-+-+- 4
   | | |
   | | +- 9
   | |
   | +-+- 6
   |   |
   |   +- 9
   |
   +-+- 8
     |
     +- 2
```

Only leave nodes have numbers and non-leaf nodes always have exactly two
branches.

The puzzle instructions provide instructions for transforming these
structures as they become *too* big. In particular, these *snailfish*
data structures can't go past the fourth level of nesting; when two of
them are combined and this rule is broken, some transformations are
applied to go back within the bounds.

My initial approach was to parse the data structure into a proper tree
in memory, then apply the transformations onto the tree. Fact is that
there might be some interaction between branches that are possibly quite
*apart* from each other, which requires some book-keeping that reminded
me of [Red-Black trees][].

While I think  that Red-Black trees are amazing, my brain immediately went in
*fight or flight* mode, trying to see if there would be some other
(better?) way of doing this.

And flight it was.

I eventually landed on a different solution that is somehow easier to
manage due to the specific requirements of the transformations. I mean,
as user [isaaccp][] implicitly [pointed out][i-post], working with the
binary tree was definitely doable, but for me it would have required
*much more effort* and I *flew*.

In particular, the *explode* move allows reducing the depth of the tree
or at least move towards reducing it, but it's not *local* to a specific
section of the tree. In fact this explosion involves the closest leaves
on the left and right of the textual representation of the tree; for
this reason, it's easier to work either on the textual representation
itself, or in a linear list of elements. I settled on isolating square
brackets, numbers and commas for ease of reconstruction.

Example of this representation:

```
# '[[13,2123],[1232,11]]' would be divided in a list as follows: 

                [  [  13  ,  2123  ]  ,  [  1232  ,   5   ]   ] 
# elements -->  ^  ^  ^^  ^  ^^^^  ^  ^  ^  ^^^^  ^   ^   ^   ^
#               0  1  2   3   4    5  6  7   8    9   10  11  12
```

> The example above is *not* a valid snailfish but it illustrates the
> concept.

The other operation (*split*) might potentially increase the overall
depth of the tree but it's easier and it can be handed quickly in both
the hierarchical tree and in the plain list representations. I decided
to go for the latter for consistency with the *explode* part though.

These two operations are applied in a certain order until the resulting
structure is within the bounds (i.e. no more tha level 4 and each leave
no more than 9).

```raku
method !_reduce () {
   @!array = $!string.comb: / ( '[' | \d+ | ',' | ']' ) / unless @!array.elems;
   while self!explode || self!split {}
   $!string = Nil;
}
```

The fun thing was that the code initially meant for parsing the input
into a tree structure for all operations was not a waste of time. While
the *explode* (and *split*, for proximity) operations are better handled
with the *linear* representation, calculating the *magnitude* of a
snailfish is better approached with the tree representation (although
it's definitely approachable with the linear approach). Hence I took the
Grammar and Actions back, adapted them a bit and had my magnitude
calculation code in little time (by my standards, that is):

```raku
grammar Grammar {
   rule  TOP      { ^ <compound> $ }
   rule  compound { '[' <left> ',' <right> ']' }
   rule  left     { <elem> }
   rule  right    { <elem> }
   rule  elem     { <compound> | <value> }
   token value    { \d+ }
}

class Actions {
   method TOP ($/) { $/.make: $<compound>.made }
   method compound ($/) {
      $/.make: 3 * $<left>.made + 2 * $<right>.made;
   }
   method left ($/) { $/.make: $<elem>.made }
   method right ($/) { $/.make: $<elem>.made }
   method elem ($/) {
      $/.make: $<value> ?? $<value>.made !! $<compound>.made;
   }
   method value ($/) { $/.make: $/.Int }
}

method !calc-magnitude () {
   return Grammar.parse(self.Str, actions => Actions).made;
}
```

To be *totally* fair, though, this is overkill and I used it only
because I already had the grammar and most of the actions. Otherwise,
this iterative string transformation would have been sufficient and much
more compact:

```raku
method !calc-magnitude () {
   my $s = self.Str;
   with $s { s{\[ (\d+) ',' (\d+) \]} = $0 * 3 + $1 * 2 while /\D/ }
   return 0+$s;
}
```

The joys of reuse, I guess.

Stay safe everybody!


[puzzle]: https://adventofcode.com/2021/day/X
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[isaaccp]: https://www.reddit.com/user/isaaccp/
[i-post]: https://www.reddit.com/r/adventofcode/comments/rizw2c/comment/hp3cxbh/
[Red-Black trees]: https://en.wikipedia.org/wiki/Red%E2%80%93black_tree
