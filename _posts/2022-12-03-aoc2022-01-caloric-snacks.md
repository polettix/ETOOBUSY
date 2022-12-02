---
title: 'AoC 2022/1 - Caloric snacks'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 1][puzzle] from [2022][aoc2022]:
> where reading inputs takes way more time than solving the puzzle!

So... here we start!

The gist of the input is that there are *paragraphs*, each one
cointaining a collection of integers. It's somehow clear that each
collection should be handled separately.

As I'm still *very* new to [Raku][], I just know that I don't know *a
lot* about how to be efficient to do stuff, especially input and output.
Here's what burned most of my time for getting to the solution of the
first part:

```raku
sub get-inputs ($filename) {
   my @list-for = [], ;
   for $filename.IO.lines -> $line {
      if $line ~~ /^ \s* $/ { @list-for.push: [] }
      else { @list-for[*-1].push: $line.Int }
   }
   @list-for.pop unless @list-for[*-1].elems;
   return @list-for;
}
```

What a mess. My strong [Perl][] accent is immediately recognizable.

To really learn something, we can draw inspiration from [0rac1e][]'s
[solution][0rac1e solution] and write this instead:

```raku
sub get-inputs ($filename) {
   $filename.IO.split("\n\n").map(*.words)».Array
}
```

I admit that I still have to get the hang of it when it comes to turning
stuff into arrays. I was forced to add the `».Array` because I got error
messages about sequences being already used, but I can't understand then
why the following is giving the same error:

```raku
# THIS DOES NOT WORK FOR ADDRESSING BOTH PARTS!
sub get-inputs ($filename) {
   $filename.IO.split("\n\n").map({[.words]})
}
```

I suspect that the error is at the *outer* level this time.

*Anyway*.

The first part of the puzzle is very straightforward: find the
collection with the highest sum. This is short and sweet:

```raku
sub part1 ($inputs) { $inputs».sum.max }
```

I really like when I can use hyperoperators and I really like that I
have `«` and `»` easily mapped in my keyboard. So *snob*.

The second part is about finding the sum of the three collections with
the highest sum. This is my approach:

- calculate the sum of each collection, like before
- sort them in descending order
- take the sum of the first three elements.

```raku
sub part2 ($inputs) { $inputs».sum.sort.reverse[0..2].sum }
```

The annoying part here is that sorting is in ascending order by default,
so I'm using `reverse` mainly for readability (I could have played with
fancier indexes instead of `[0..2]` and spare the `reverse`).

But, of course... **This**! **Is**! **[Raku][]!**

So kudos to [liztormato][] for chiming in and suggesting that there is
indeed a small aptly-shaped tool that is fit for this need, as expressed
in [this hint][liztormato hint]:

```raku
sub part2 ($inputs) { $inputs».sum.sort.tail(3).sum }
```

What can I say? Day one is supposed to get some rust off, and I'm
already learning a lot.

Cheers!

[puzzle]: https://adventofcode.com/2022/day/1
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[0rac1e]: https://www.reddit.com/user/0rac1e/
[0rac1e solution]: https://www.reddit.com/r/adventofcode/comments/z9ezjb/comment/iygmo7x/
[liztormato]: https://www.reddit.com/user/liztormato/
[liztormato hint]: https://www.reddit.com/r/adventofcode/comments/z9ezjb/comment/iyjp2xi/
