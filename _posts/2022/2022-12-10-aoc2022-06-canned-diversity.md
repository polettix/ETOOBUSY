---
title: 'AoC 2022/6 - Canned diversity'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
series: Advent of Code 2022
comment: true
date: 2022-12-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 6][puzzle] from [2022][aoc2022]:
> finding diversity in strings.

This challenge was pretty straightforward but tickling. So many ways of
addressing it!

The gist is to find the leftmost sequence of $n$ characters that are all
different from one another. Part 1 and 2 only differ for the number of
different characters that should be in the sequence.

Some people went on taking substrings and building sets out of them,
stopping when the set size is the right one. So clever.

I'm always scared of this kind of solutions because it seems to me that
some work is being done over and over again. Which is unfortunate in a
challenge like this, which has a speed factor.

Well, unless you don't mind about the speed factor.

In my case, I decided to keep track of a sliding window, counting stuff
with a [BagHash][]. The *compact* solution is the following:

```raku
sub detect-different($string, $n) {
   my ($i, $window) = $n - 1, BagHash.new($string.substr(0, $n - 1).comb);
   loop {
      $window.add($string.substr($i++, 1));
      return $i if $window.elems == $n;
      $window.remove($string.substr($i - $n, 1));
   };
}
put '06.input'.IO.lines.map({detect-different($_, 4)});
put '06.input'.IO.lines.map({detect-different($_, 14)});
```

The [BagHash][] is perfect in this case, because it allows to implement
the sliding window counting in the right way. Getting one character in
means increasing one of the counts; getting one out, decreasing the
count.

I mean, this is just a regular hash/dictionary which holds a count, but
the name is fun!

[Full solution][].

Stay safe!

[puzzle]: https://adventofcode.com/2022/day/6
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[BagHash]: https://docs.raku.org/type/BagHash
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/06.raku
