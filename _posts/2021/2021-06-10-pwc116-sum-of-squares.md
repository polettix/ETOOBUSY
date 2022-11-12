---
title: PWC116 - Sum of Squares
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-10 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#116][].
> Enjoy!

# The challenge

> You are given a number `$N >= 10`.
>
> Write a script to find out if the given number `$N` is such that sum
> of squares of all digits is a perfect square. Print 1 if it is
> otherwise 0.
>
> **Example**
>
>     Input: $N = 34
>     Ouput: 1 as 3^2 + 4^2 => 9 + 16 => 25 => 5^2
>
>     Input: $N = 50
>     Output: 1 as 5^2 + 0^2 => 25 + 0 => 25 => 5^2
>
>     Input: $N = 52
>     Output: 0 as 5^2 + 2^2 => 25 + 4 => 29

# The questions

The first is a meta-question: what's with all these `$N >= 10` this
week? Are we're celebrating something that happened 10 years ago?!?

The number will be an *integer*, right? Also, I'll assume that it's OK
to avoid too big integers and assume that we will always remain within
*reasonable bounds*. Whatever this means.

Technically speaking this assumption is totally arbitrary though, as
there is no upper limit as to having numbers that *match*.

Not convinced? Well:

- take any integer (the bigger, the better!)
- square it
- now take a sequence of that square number of any single digit.

Like you chose `3` to start with, so the square is `9` and then we get,
let's say, `777777777` i.e. `7` repeated `9` times.

Each `7` squares to `49`, and we have exactly `9` of them... So there
you have it, the sum is a perfect square!

# The solution

This time I coded the [Raku][] solution first:

```raku
#!/usr/bin/env raku
use v6;

sub sum-of-squares (Int $N where * >= 10 --> Int:D) {
   my $M = $N.comb.map(* ** 2).sum;
   my $m = $M.sqrt.Int;
   return $m * $m == $M ?? 1 !! 0;
}

sub MAIN (*@inputs) {
   @inputs = < 34 50 52 > unless @inputs.elems;
   sum-of-squares($_).put for @inputs;
}
```

I have to admit that I was a bit disappointed in *not* finding a
`is-square` method in `Int`. Also, I have to admit that `* ** 2` is not
an invitation to *read* 🙄

Then I thought... it's [Raku][]!

Then I [looked in the internet][] and here we are:

```raku
#!/usr/bin/env raku
use v6;
use MONKEY-TYPING;

augment class Int {
   method is-square (--> Bool:D) { self == self.sqrt.Int ** 2 }
}

sub sum-of-squares (Int $N where * >= 10 --> Int:D) {
   $N.comb.map(* ** 2).sum.is-square ?? 1 !! 0;
}

sub MAIN (*@inputs) {
   @inputs = < 34 50 52 > unless @inputs.elems;
   sum-of-squares($_).put for @inputs;
}
```

It *works*!!!

Here's the good, ol' [Perl][] solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'sum';

sub sum_of_squares ($N) {
   my $M = sum map { $_ * $_ } split(m{}mxs, $N);
   my $m = int sqrt $M;
   return $m * $m == $M ? 1 : 0;
}

my @inputs = @ARGV ? @ARGV : qw< 34 50 52 >;
say sum_of_squares($_) for @inputs;
```

In both cases we split the input as a string into its constituent
digits, square them and produce the sum. Then, we check if this is a
perfect square, by taking the square root, cutting it to an integer and
checking whether squaring it again produces the sum we started with.

Stay safe folks!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#116]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-116/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-116/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[looked in the internet]: https://stackoverflow.com/a/34508956/334931
