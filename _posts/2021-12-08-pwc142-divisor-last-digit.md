---
title: PWC142 - Divisor Last Digit
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-08 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#142][]. Enjoy!

# The challenge

> You are given positive integers, `$m` and `$n`.
>
> Write a script to find total count of divisors of `$m` having last digit
> `$n`.
>
> **Example 1:**
>
>     Input: $m = 24, $n = 2
>     Output: 2
>     
>     The divisors of 24 are 1, 2, 3, 4, 6, 8 and 12.
>     There are only 2 divisors having last digit 2 are 2 and 12.
>
> **Example 2:**
>
>     Input: $m = 30, $n = 5
>     Output: 2
>     
>     The divisors of 30 are 1, 2, 3, 5, 6, 10 and 15.
>     There are only 2 divisors having last digit 5 are 5 and 15.

# The questions

I guess that `$n` might be... *different*, right? From how it's used, it
seems that it should be a single digit... and that it should also be
allowed to be `0`. Anyway, I'll enforce only that it's a single digit
(but only in [Raku][]).

# The solution

Well... let's do this the boring way. We build a function to find out
all divisors for the input `$m`, then filter it and count the result.

{% raw %}
```raku
#!/usr/bin/env raku
use v6;
subset PosInt of Int where * > 0;
subset PosDigit of Int where 0 < * <= 9;

sub divisors-for (PosInt:D $n) {
   (1 .. $n.sqrt.Int).grep({$n %% $_}).map({$_, ($n / $_).Int})
     .flat.Set.keys;
}

sub MAIN (PosInt:D $m = 24, PosDigit:D $n = 2) {
   divisors-for($m).grep({.substr(*-1, 1) == $n}).elems.put;
}
```
{% endraw %}

The iteration goes up to the square root of the input because each
divisor $k$ will also give its counterpart $\frac{n}{k}$. The `grep`
filters only the items that actually *divide* `$n` (using operator `%%`,
yay!), then the `map` gives out the number itself and its counterpart.

Here we might have two problems, though. First, the output of the `map`
is pairs of numbers, so we have to `flat` to get a plain list out.

Additionally, the square root of perfect squares would pop up twice, so
we need to make sure to eliminate the duplicate. So we pass the list
through a `Set` and then take the keys.

One last thing is... that `5` and `25/5` are *not* the same thing. The
first is an `Int`, the second a `Rat`! So we need to turn the division
into an `Int`.

Here's a [Perl][] translation. Somehow it seems much simpler!

{% raw %}
```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub divisors_for ($n) {
   keys %{{map { $_ => 1, int($n / $_) => 1 } grep { !($n % $_) }
     1 .. sqrt($n)}};
}

my $m = shift // 24;
my $n = shift // 2;
say scalar [grep { substr($_, -1, 1) == $n } divisors_for($m)]->@*;
```
{% endraw %}

OK, enough for today... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#142]: https://theweeklychallenge.org/blog/perl-weekly-challenge-142/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-142/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
