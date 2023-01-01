---
title: PWC173 - Esthetic Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-13 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#173][]. Enjoy!

# The challenge

> You are given a positive integer, `$n`.
>
> Write a script to find out if the given number is `Esthetic Number`.
>
>> An esthetic number is a positive integer where every adjacent digit
>> differs from its neighbour by 1.
>
>
> For example,
>
>     5456 is an esthetic number as |5 - 4| = |4 - 5| = |5 - 6| = 1
>     120 is not an esthetic numner as |1 - 2| != |2 - 0| != 1

# The questions

There might be some nit-picking here: which base to consider? It would
be a moot question, though, because there's still ample space for a
base-2 number to NOT be esthetic (think '11`, for example), so there is
no outsmarting our fine host here.

The other question I would have asked a long time ago would be the
output format. I came from experiences in which my output would have
been tested against some reference; here, though, there's the pleasure
of cracking challenges without the annoyance of getting the exact result
as initially thought. I see this as an application of TIMTOWTDI spirit.

# The solution

We'll have to compare adjacent pairs of digits, so I thought to toss in
some generalization and code a function to perform generic tests on
adjacent pair of elements in an array. [Raku][]:

```raku
sub test-adjacents (&test, *@input) {
   for 1 ..^ @input -> $i {
      return False unless &test(|@input[$i - 1, $i]);
   }
   return True;
}
```

[Perl][]:

```perl
sub test_adjacents ($test, @input) {
   for my $i (1 .. $#input) {
      return 0 unless $test->(@input[$i - 1, $i]);
   }
   return 1;
}
```

At this point, it's just a matter of feeding these functions with the
right inputs, i.e. a test function and the list of digits. [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@candidates) {
   put is-esthetic($_) ?? "$_ is esthetic" !! "$_ is NOT esthetic"
      for @candidates;
   return 0;
}

sub is-esthetic ($candidate) {
   test-adjacents(-> $x, $y { abs($x - $y) == 1 }, $candidate.comb());
}
```

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say is_esthetic($_) ? "$_ is esthetic" : "$_ is NOT esthetic"
   for @ARGV;

sub is_esthetic ($candidate) {
   test_adjacents(
      sub ($x, $y) { use integer; abs($x - $y) == 1 },
      split m{}mxs, $candidate
   );
}
```

I tried to look for something already baked into [Raku][], but without
much luck. I'm curious to look at others' solutions!

Stay safe and change the right amount every day!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#173]: https://theweeklychallenge.org/blog/perl-weekly-challenge-173/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-173/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
