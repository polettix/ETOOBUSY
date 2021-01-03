---
title: 'AoC 2016/11 - Input parsing'
type: post
tags: [ advent of code, coding, perl, algorithm ]
comment: true
date: 2021-01-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: parsing the
> inputs.

In this first *practical* post we will take a look at the inputs and how
to parse them.

# Inputs

The example input in the first part of the puzzle is the following:

```text
The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
The second floor contains a hydrogen generator.
The third floor contains a lithium generator.
The fourth floor contains nothing relevant.
```

For completeness, this is the specific input I have:

```text
The first floor contains a promethium generator and a promethium-compatible microchip.
The second floor contains a cobalt generator, a curium generator, a ruthenium generator, and a plutonium generator.
The third floor contains a cobalt-compatible microchip, a curium-compatible microchip, a ruthenium-compatible microchip, and a plutonium-compatible microchip.
The fourth floor contains nothing relevant.
```

In addition, part 2 requires to put additional stuff on the first floor,
which I eventually added at the end like the following:

```text
The first floor contains a promethium generator and a promethium-compatible microchip.
The second floor contains a cobalt generator, a curium generator, a ruthenium generator, and a plutonium generator.
The third floor contains a cobalt-compatible microchip, a curium-compatible microchip, a ruthenium-compatible microchip, and a plutonium-compatible microchip.
The fourth floor contains nothing relevant.
The first floor contains a elerium generator and a elerium-compatible microchip.
The first floor contains a dilithium generator and a dilithium-compatible microchip.
```

# Parsing

Each line contains an indication of the floor and a list of contained
items.

To get the floor number (as text) we can use the following regular
expression:

```perl
my ($floor) = m{\A The \s+ (\S+) \s+ floor \s+ contains \s+}mxs;
```

This *floor name* can then be turned into some other index using a hash.

Getting the list of elements can be trickier because it's not known how
many of the are there. I resorted to the trick of taking a match and
deleting it at the same time, until there's no more left.

Hence, for microchips:

```perl
while (s{(\S+)-compatible}{}mxs) {
    # element name now in $1
    ...
}
```

Something similar, for generators:

```perl
while (s{(\S+) \s+ generator}{}mxs) {
    # element name now in $1
    ...
}
```

Having multiple lines referring to the contents of a floor is not
a problem with this approach, as long as we use the information extracted
about the floor for each line to fill in our data structures.

# This is it!

As the title implies, this is it for today. In the next post, we'll be
looking at the (initial) data structure where we will fit the parsed
data... so until then take care and stay safe!

[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
