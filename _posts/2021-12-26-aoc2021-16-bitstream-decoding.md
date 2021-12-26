---
title: 'AoC 2021/16 - Bitstream decoding'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 16][puzzle] from [2021][aoc2021]:
> good old bit stream decoding

This day's puzzle required some care in the decoding algorithm but I did
not find it hard.

I had the occasion of using `multi` methods to cope with a specific
dispatch, instead of using hashes or `if`s:

```raku
class BitsNode {
   has $.version is built is required;
   has $.type    is built is required;
   has $.value   is built is required;
   has $.bits    is built is required;

   method version-sum () {
      my $retval = $.version;
      if $.type != 4 {
         $retval += .version-sum for $.value.List;
      }
      return $retval;
   }

   method evaluate () { self.evaluate-by(self.type) }

   multi method evaluate-by (4) { self.value }
   multi method evaluate-by (0) { [+] self.value».evaluate }
   multi method evaluate-by (1) { [*] self.value».evaluate }
   multi method evaluate-by (2) { self.value».evaluate.min }
   multi method evaluate-by (3) { self.value».evaluate.max }
   multi method evaluate-by (5) { ([>] self.value».evaluate) ?? 1 !! 0 }
   multi method evaluate-by (6) { ([<] self.value».evaluate) ?? 1 !! 0 }
   multi method evaluate-by (7) { ([==] self.value».evaluate) ?? 1 !! 0 }
}
```

It's the implementation of the different operations depending on their
code in the hierarchy inside the bit stream. Should I have used
inheritance instead? It seemed overkill.

Overall it reminded me when I did ASN1 parsing a long, long time ago.
I'm also a bit disappointed that I could not use a grammar here...

Anyway, that's all for today and stay safe!

[puzzle]: https://adventofcode.com/2021/day/16
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
