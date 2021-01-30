---
title: 'AoC 2016/11 - New identifier'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-11 ]
series: Radioisotope Thermoelectric Generators (AoC 2016/11)
comment: true
date: 2021-01-16 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: a
> new *identifier sub* for the new representation.

Now that we have a [New representation][] and a way to [parse it][],
it's time to start adapting the machinery needed by the solving
algorithm.

We will start simple, i.e. the identifier function. This has to be a
string that can represent a state in a one-to-one mapping, so that
equivalent states (i.e. states where the elevator, the generators and
the microchips are all in the same place) map onto the same identifier,
and different states (for either the elevator, the generators or the
microchips) map onto different ones.

The need for a string is that it will eventually be used as a key in a
hash... so it's better that it stringifies well!

One alternative might be to just join these three components together:

```perl
sub id_of ($state) {
   return join '-', $state->@{qw<elevator generators microchips>};
}
```

To keep stuff as tight as possible, though, we can rely on [pack][]:

```perl
sub id_of ($state) {
   return pack 'AN2', $state->@{qw<elevator generators microchips>};
}
```

In this case:

- the elevator is encoded with a single octet, that is actually the same
  as the character representing the corresponding digit;
- both the generators and the microchips are represented as a 32-bit
  sequence, in network order. The order here is not important, as long
  as every state is encoded in the same way.

This yields a total of 9 octets for each identifier, yay!

[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[New representation]: {{ '/2021/01/12/aoc2016-11-new-representation/' | prepend: site.baseurl }}
[parse it]: {{ '/2021/01/15/aoc2016-11-new-parsing/' | prepend: site.baseurl }}
[pack]: https://perldoc.pl/functions/pack
