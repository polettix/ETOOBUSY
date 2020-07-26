---
title: 'Algorithm::Loops'
type: post
tags: [ algorithm, perl ]
comment: true
date: 2020-07-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> [`NestedLoops`][] from [Algorithm::Loops][] can come handy. Other
> functions can too.

In a little side project I ended up with some four or five *nested
loops* and to be honest it seemed a tad too many. Then I remembered about
this neat module [Algorithm::Loops][] and in particular the
[`NestedLoops`][] function, that aims at solving exactly that problem.

In my case I just needed to generate the *cartesian product* of a few
input arrays - i.e. I needed all the possible arrangements taking one
item from each array. Hence, it can be as simple as this:

```perl
use Algorithm::Loops 'NestedLoops';
my @dimensions = (
    ['A' .. 'F'],          # first slot has some uppercase letters
    [ 2, 3, 5, 7 ],        # then some digits
    [ qw< foo bar baz > ], # thsn some words
);
NestedLoops(\@dimensions, sub { print join('-', @_), "\n" });
```

which, as you can correctly guess, prints out $6 \cdot 4 \cdot 3 = 72$
items out:

```shell
$ perl test.pl | nl
     1	A-2-foo
     2	A-2-bar
    ...
    71	F-7-bar
    72	F-7-baz
```

There are other subtler ways to generate and manage smarter loops... you
can get them in the docs, as well as other functions, like:

- the `MapCar`* family (to iterate over multiple arrays, in parallel)
- `NextPermute` and `NextPermuteNum`, which provide iterators to go
  through all or part of the permutations in a list of elements.

`Filter` is probably no more needed nowadays after the `r`
[non-destructive substitution] modifier was added to the `s` and
`tr`/`y` operators in 2011.

[Algorithm::Loops]: https://metacpan.org/pod/Algorithm::Loops
[Perl]: https://www.perl.org/
[`NestedLoops`]: https://metacpan.org/pod/Algorithm::Loops#NestedLoops1
[non-destructive substitution]: https://perldoc.perl.org/perl5140delta.html#Regular-Expressions
