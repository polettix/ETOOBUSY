---
title: PWC133 - Integer Square Root
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#133][]. Enjoy!

# The challenge

> You are given a positive integer `$N`.
> 
> Write a script to calculate the integer square root of the given
> number.
> 
> Please avoid using built-in function. Find out more about it [here][].
>
> **Examples**
>
>     Input: $N = 10
>     Output: 3
>     
>     Input: $N = 27
>     Output: 5
>     
>     Input: $N = 85
>     Output: 9
>     
>     Input: $N = 101
>     Output: 10

# The questions

Not much to ask for this challenge, as it's actually the gamification of
some study. And I like both studying and games, so I can only thank our
host here.

Were it an interview, though, I'd probably ask this:

- how hard should we validate our inputs? Input validation is a good
  thing, but it might also imply a performance cost which might be
  avoided by doing proper validation only at the beginning of some data
  munging. Hence, it might be avoided if the function we're after will
  only be used on *valid* data.

- what is the maximum value for the input `$N`? Very big numbers might
  imply the adoption of specific techniques; moreover it's good to test
  with a few values in that ballpark.

# The solution

Speaking of validation, [Raku][] basically gives it for free programmer
time, so why not?

```raku
#!/usr/bin/env raku
use v6;
sub integer-square-root (Int:D $n where * >= 0) {
   return $n if $n < 2;
   my $x = $n +> 1;  # first estimate
   my $y = $x + 1;   # just to get started with $x < $y
   ($x, $y) = (($x + ($n / $x).Int) +> 1, $x) while $x < $y;
   return $y;
}
sub MAIN (Int:D $n where * >= 0) { put integer-square-root($n) }
```

I don't know about the performance hit of using incremental typing here,
though.

Looking at the algorithm in C proposed [here][], it's easy to spot that
`x0` is just a way to memorize the *previous* value that was calculated.
For this reason, I changed the variables' names to reflect it: `$x`
evolves only in terms of itself, and `$y` gets the previous value.

To get the ball rolling, `$y` is arbitrarily initialized to be *greater*
than `$x`. This ensures that the `while` is triggered at least once,
giving `$y` a proper value.

The same algorithm is also implemented in [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
sub integer_square_root ($n) {
   return $n if $n < 2;
   my $x = $n >> 1;  # first estimate
   my $y = $x + 1;   # just to get started with $x < $y
   ($x, $y) = (($x + int($n / $x)) >> 1, $x) while $x < $y;
   return $y;
}
say integer_square_root(shift // die "$0 <n>\n");
```

Here I'm giving up on input validation and only accounting for the user
forgetting to pass a value on the command line. For the rest, it's the
same as the [Raku][] version, with due changes in the right places (e.g.
`>>` instead of `+>`, as well as `int` instead of `.Int`).

I considered putting a `use integer` inside the function, but eventually
decided to avoid it for the explicit `int(...)` - at the end of the day,
it's just one single place where I have to put it, so there's little
space for getting this wrong.

I hope it's everything for this post because I'm closing it and...
wishing you to have a nice and safe day!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#133]: https://theweeklychallenge.org/blog/perl-weekly-challenge-133/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-133/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[here]: https://en.wikipedia.org/wiki/Integer_square_root
