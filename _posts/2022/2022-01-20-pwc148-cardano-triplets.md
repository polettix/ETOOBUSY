---
title: PWC148 - Cardano Triplets
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-01-20 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#148][].
> Enjoy!

# The challenge

> Write a script to generate first 5 Cardano Triplets.
>
>> A triplet of positive integers (a,b,c) is called a Cardano Triplet if
>> it satisfies the below condition.
>
> $$ \sqrt[3]{a + b \sqrt{c}} + \sqrt[3]{a - b \sqrt{c}} = 1 $$
>
> **Example**
>
>     (2,1,5) is the first Cardano Triplets.


# The questions

Is *the internet* a valid source? Because I'm definitely using it!

To be more serious, I don't know what does it mean to generate *the
first* Cardano Triplets. What's the ordering supposed to be? Lowest sum
of the three values $a$, $b$, and $c$? Something else?

# The solution

It seems that our fine host discovered [Project Euler][] and gives us
(well... *me*) the occasion to *cheat a bit* and look for solutions
around.

It's *clear* that doing square and cube roots is going to spoil all the
fun with integers in a computer, so the solution MUST be something that
can be solved through integer-only maths. And there it is, the
[characterization][] I was looking for.

Alas, this week is finding me particularly *lazy*, so I'll take the
*extremely* simple route and adopt this:

$$
a = 3 b - 1 \\
c = 8 b - 3
$$

with $b > 0$ integer. This means that, from the [characterization][],
I'm assuming that $b = k + 1$, even though it *might* be that $8 k + 5$
is a square too... in which case I might have another candidate triple.
Whatever.

At this point, we just have to iterate over the needed values for $b$.
Let's get [Perl][]ish first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $n = shift // 5;
for my $b (1 .. $n) {
   my $a = 3 * $b - 1;
   my $c = 8 * $b - 3;

   my $sqrt = $b * sqrt($c);
   my $first = ($a + $sqrt) ** (1/3);
   my $second = ($sqrt - $a) ** (1/3);
   my $result = $first - $second;

   say "($a, $b, $c) -> $result";
}
```

The whole calculation for the `$result` seems to be kind with us:

```
$ perl perl/ch-2.pl 
(2, 1, 5) -> 1
(5, 2, 13) -> 1
(8, 3, 21) -> 1
(11, 4, 29) -> 1
(14, 5, 37) -> 1
```

Let's move on to [Raku][] now, with pretty much the same implementation,
apart the different syntax:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n = 5) {
   for 1 .. $n -> $b {
      my $a = 3 * $b - 1;
      my $c = 8 * $b - 3;

      my $sqrt = $b * $c.sqrt;
      my $first = ($a + $sqrt) ** (1 / 3);
      my $second = ($sqrt - $a) ** (1 / 3);
      my $result = $first - $second;

      "($a, $b, $c) -> $result".put;
   }
}
```

This time, anyway, the control calculations do not help us understand:

```
$ raku raku/ch-2.raku 
(2, 1, 5) -> 0.9999999999999999
(5, 2, 13) -> 1.0000000000000002
(8, 3, 21) -> 1
(11, 4, 29) -> 1
(14, 5, 37) -> 1
```

Well, at least we understood it correctly in the beginning... a solution
involving square and cube roots would not bring us too far.

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#148]: https://theweeklychallenge.org/blog/perl-weekly-challenge-148/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-148/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Project Euler]: https://projecteuler.net/
[characterization]: https://math.stackexchange.com/questions/1885095/parametrization-of-cardano-triplet
