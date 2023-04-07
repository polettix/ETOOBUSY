---
title: PWC206 - Array Pairings
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#206][].
> Enjoy!

# The challenge

> You are given an array of integers having even number of elements..
>
> Write a script to find the maximum sum of the minimum of each pairs.
>
> **Example 1**
>
>     Input: @array = (1,2,3,4)
>     Output: 4
>
>     Possible Pairings are as below:
>     a) (1,2) and (3,4). So min(1,2) + min(3,4) => 1 + 3 => 4
>     b) (1,3) and (2,4). So min(1,3) + min(2,4) => 1 + 2 => 3
>     c) (1,4) and (2,3). So min(1,4) + min(2,3) => 2 + 1 => 3
>
>     So the maxium sum is 4.
>
> **Example 2**
>
>     Input: @array = (0,2,1,3)
>     Output: 2
>
>     Possible Pairings are as below:
>     a) (0,2) and (1,3). So min(0,2) + min(1,3) => 0 + 1 => 1
>     b) (0,1) and (2,3). So min(0,1) + min(2,3) => 0 + 2 => 2
>     c) (0,3) and (2,1). So min(0,3) + min(2,1) => 0 + 1 => 1
>
>     So the maximum sum is 2.

# The questions

I guess I'd ask if there's a limit on the input integers (to possibly
use a big-integer library), as well as a limit on the size of the array.

# The solution

This challenge made me realize that I'm a (cyber)bully.

My first go-to solution is to go *brute force*. For the kind of inputs
that we get as examples in these challenges, it's even too much call it
*brute* (or *force*).

But brute force is just the tool of the bully: it works on the weak, but
backfires on the strong. So, in occasions like this, it's good to think
about *something else*.

The bottom line of the intuition in this case is that it's better to
sort the array first (it doesn't matter if in increasing or decreasing
order, would you say that?), then take items in pairs starting from
either end.

I'll not provide a formal proof here, but suffices to say that if we
start from such an array (let's say in increasing order), then we have
something like this:

$$
(x_0 \le x_1) \le (x_2 \le x_3) \le ... \le (x_{2k} \le x_{2k+1})
$$

Now let's consider any couple of pairs, with $A \le B \le C \le D$:

$$
... (A \le B) ...  (C \le D) ...
$$

This contributes $A + C$ to the sum.

What would happen if we do any swap between the two? The contribution
from *other* pairs would be unchanged, so the modification depends on
what swap we do. There are a few possibilities, but the bottom line is
that the new contribution is *always* going to be $A + B$, because they
appear in different pairs and are (by definition) less than, or equal
to, both $C$ and $D$.

Hence, the swap leads us to:

$$
A + B \le A + C
$$

Which means that either it does not change, or it gets worse.

Which means that we're good with our sorted array.

OK, enough wavy maths, let's get to the code, [Perl][] first:

```perl
use List::Util qw< pairkeys sum >;
print array_pairings(@ARGV), "\n";
sub array_pairings { sum pairkeys sort { $a <=> $b } @_ }
```

Oh, the joys of CORE! Batteries *mostly* included, at last!

[Raku][] goes on a similar note, we take advantage of lazy lists with
automatic inference here:

```raku
sub MAIN (*@args) { put array-pairings(@args) }
sub array-pairings (Array[Int]() $array) { $array.sort[0, 2 ... *].sum }
```

I also got to [learn something][] from [liztormato][], yay!

So... stay safe and well ordered!



[The Weekly Challenge]: https://theweeklychallenge.org/
[#206]: https://theweeklychallenge.org/blog/perl-weekly-challenge-206/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-206/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[learn something]: https://stackoverflow.com/questions/75167025/raku-signature-array-r-is-not-arrayd/75170578#75170578
[liztormato]: https://rakudoweekly.blog/author/liztormato/
