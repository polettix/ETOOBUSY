---
title: PWC079 - Trapped Rain Water
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-09-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where we solve [Perl Weekly Challenge][] [#079][] [task #2][].

# The challenge

> You are given an array of positive numbers `@N`.
>
> Write a script to represent it as Histogram Chart and find out how
> much water it can trap.

# The questions

I think that there's a bulk of questions that we should always ask:

- what about invalid inputs?
- are there limits on the size of the array?

# The solution

One possible simplistic approach is to ask: how much water do we find at
each location? This is easily determined: let's look at the maximum
height on the left (including where we are standing), then let's look at
the maximum height on the right (again, inclucing where we are
standing). The minimum of these two maxima will be the height of the
water; subtract the height of the spot and we have the answer. Repeat
for all locations... and we're done.

This can be translated into code in a quite straightforward way:

```perl
 1 sub trapped_rain_water_dumb (@N) {
 2    my $retval = 0;
 3    for my $i (1 .. $#N - 1) {
 4       my $max_left  = max(@N[0 .. $i]);
 5       my $max_right = max(@N[$i .. $#N]);
 6       my $min_max   = min($max_left, $max_right);
 7       $retval += $min_max - $N[$i];
 8    }
 9    return $retval;
10 }
```

I'm calling this implementation *dumb* because it's qute inefficient.
calculating the maximum value for all spots in both direction time and
again is... suboptimal. We are iterating over the array (external loop
starting in line 3) and then we are iterating again on the array
(internal loop, divided between lines 4 and 5). Overall... not an
encouraging complexity ($N^2$). Anyway... a good benchmark.

So how can we make it better? Let's reverse the perspective: we can
sweep the array from left to right and set the maximum value found for
each location as coming from the left. Then we do a similar sweep from
the right, and update the maximum value taking the minor of the two.
This means that we can do just two sweeps in total and have an asyntotic
complexity of $O(N)$... yay!

Which leads us to the following code:

```perl
 1 sub trapped_rain_water (@N) {
 2    my $max = 0;
 3    my @maxes;
 4 
 5    # first pass, left to right
 6    for my $v (@N) {
 7       $max = max($max, $v);
 8       push @maxes, $max;
 9    }
10 
11    # second pass, right to left
12    my $retval = 0;
13    $max = 0;
14    for my $v (reverse @N) {
15       $max = max($max, $v);
16       my $w = min($max, shift @maxes);
17       $retval += $w - $v;
18    }
19    return $retval;
20 }
```

In the *first pass* (lines 5 through 9) we set the maximum value coming
from the left, saving it into `@maxes`.

Then, we do a second pass from right to left, calculate the maximum
value "from the right" for each spot and then take the minimum of the
two maxima (line 16).

Now, the difference between this "maximum minimum" and the height at the
spot is how much water is held in place, so we can add thsi value to the
total returned.

I hope you enjoyed it!

[task #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-079/#TASK2
[#079]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-079/
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
