---
title: Fibonacci Sum part 1
type: post
tags: [ perl weekly challenge, maths, combinatorics ]
comment: true
date: 2020-09-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The [first task][task #1] in the [Perl Weekly Challenge][]
> [#077][Challenge 077] is about summing Fibonacci numbers, and it's
> transformed into a tricky one.

When I read the first challenge, I already knew that it was somehow
misleading (there's no occasion where it's not possible to find at least
a solution) and easy to address.

As a matter of fact, [Zeckendorf's theorem][] states this:

> every positive integer can be represented uniquely as the sum of one
> or more distinct Fibonacci numbers in such a way that the sum does not
> include any two consecutive Fibonacci numbers.

It's funny that the result was discovered 20 years before Zeckendorf by
[Gerrit Lekkerkerker][]. I guess this is life. It's also funny that a
simple *greedy* algorithm takes care of the issue, so the challenge
became just a *simple matter of programming*, right?

Wrong.

The initial text of the question was a bit vague on the expected
output and I asked a question... which I suspect led to the final shape
of the question, which requires to print out *all possible ways* to
break down a positive integer into non-overlapping Fibonacci numbers.

So, all of a sudden, we had two problems to solve! Well, I guess it's
better to get started with the first one (the full solution is available
[here][]).

Finding the Zeckendorf's decomposition is straightforward: at each step,
find the biggest Fibonacci number that fits, take it, subtract and
repeat:

```perl
 1 sub lekkerkerker {
 2    my ($n) = @_;
 3    my @fibo = (1, 2);
 4    push @fibo, $fibo[-2] + $fibo[-1] while $fibo[-1] < $n;
 5    my $i = $#fibo;
 6    my @indexes;
 7    while ($n > 0) {
 8       --$i while $fibo[$i] > $n;
 9       unshift @indexes, $i;
10       $n -= $fibo[$i];
11    }
12    return {
13       fibo => \@fibo,
14       indexes => \@indexes,
15    };
16 }
```

This function is a bit more complicated than it should, because it
returns a full sequence of Fibonacci numbers in an array reference
(pointed by key `fibo`) and the indexes of the elements in this array
that collectively form the target input number `$n`. 

The Fibonacci sequence starts with `1` and `2`, because at the end of
the day we're after *different* numbers anyway. It is then filled with
all numbers up to `$n`, because we don't need anything beyond (line 4).

The implementation of the greedy algorithm is in lines 7 to 11:

- the biggest Fibonacci number fitting `$n` is looked for by walking
  into the array of Fibonacci numbers in reverse (line 8);
- the corresponding index is saved (line 9);
- the Fibonacci number is subtracted from `$n` to prepare for the next
  iteration.

We eventually return both the Fibonacci numbers and the indexes (lines
12 through 15). This additional complexity paves the way for the other
half of the question - finding all possible arrangements of different
Fibonacci numbers that collectively yield `$n`. This... we will see the
next time!

[task #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-077/#TASK1
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[Challenge 077]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-077/
[Zeckendorf's theorem]: https://en.wikipedia.org/wiki/Zeckendorf%27s_theorem
[Gerrit Lekkerkerker]: https://en.wikipedia.org/wiki/Gerrit_Lekkerkerker
[here]: https://github.com/manwar/perlweeklychallenge-club/blob/master/challenge-077/polettix/perl/ch-1.pl
