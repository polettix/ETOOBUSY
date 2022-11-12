---
title: PWC083 - Flip Array
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#083][].
> Enjoy!

# The challenge

> You are given an array `@A` of positive numbers. Write a script to
> flip the sign of some members of the given array so that the sum of
> the all members is minimum non-negative. Given an array of positive
> elements, you have to flip the sign of some of its elements such that
> the resultant sum of the elements of array should be minimum
> non-negative(as close to zero as possible). Return the minimum no. of
> elements whose sign needs to be flipped such that the resultant sum is
> minimum non-negative.

# The questions

I guess the only question here is... *why* 😂

Jokes apart, it's an interesting challenge, and maybe a few questions
might be asked regarding validation of data and whether the return value
should be the minimum number of sign changes that accomplish the goal.
Not that I have a clever solution about it, just saying.

# The solution

I guess it's fair at this point to declare that I'm totally clueless
regarding any clever and optimized way to do this, so I'll resort to
good old exhaustive search, with the possible slight addition of a test
when the result is 0 (which is as low as we can possibly get).

If the array contains $n$ elements, we will need to place $n$ signs,
either `+` or `-` for each element. Which means that our approach grows
exponentially with the number of elements - there's hopefully a *lot* of
space for optimization!

## An initial solution

To remain on the lazy size, we can observe that we can iterate through
all of them by simply *counting*. Well... that, and turning the count in
a binary representation, where we will conventiently interpret `1` as
`-` and `0` as `+`:

```
 1 sub flip_array_basic (@A) {
 2    my $n = scalar(@A); # number of signs that can be flipped
 3    my $N = 2 ** $n;
 4    my $i = 0;
 5    my ($min, $retval);
 6    while ($i < $N) {
 7       my $signs = $i++;
 8       my $sum = 0;
 9       my $flipped = 0;
10       for my $j (0 .. $#A) {
11          if ($signs & 0x1) { # flip
12             $sum -= $A[$j];
13             $flipped++;
14          }
15          else {
16             $sum += $A[$j];
17          }
18          $signs >>= 1;
19       }
20       next if $sum < 0;
21       ($min, $retval) = ($sum, $flipped)
22          if !defined($min)
23             || $sum < $min
24             || ($sum == $min && $flipped < $retval);
25    }
26    return $retval;
27 }
```

After counting the number $n$ of signs that we have to assign, we
calculate `$N` as $2^n$, i.e. the number of different sign assignments
that we can do (line 3).

Afterwards, we will iterate through all of them (lines 6 and 7, where
our counter `$i` is incremented) and use the bits of the counter
variable `$i` to assign a `+` or a `-` to each item in `@A` (lines 11
through 17). Line 18 shifts our counter to prepare it for the extraction
of the next bit.

After we've exited, it's only meaningful to consider values that are not
negative (line 20).

Last, if this specific arrangement was better than a previous one (or
it's the first), we update our result and move on (lines 21 through 24).

## A slight improvement

There's a nice duality in all our iterations: for every arrangement that
yields a sum $S$, the opposite arrangement (i.e. obtained by switching
the `+` and `-` for every input) yields a sum of $-S$. So we can spare
doing half of the sums actually, by leveraging on this:

```
 1 sub flip_array (@A) {
 2    my $first = shift @A;
 3    my $n = scalar(@A); # number of signs that can be flipped
 4    my $N = 2 ** $n;
 5    my $i = 0;
 6    my ($min, $retval);
 7    while ($i < $N) {
 8       my $signs = $i++;
 9       my $sum = $first;
10       my $flipped = 0;
11       for my $j (0 .. $#A) {
12          if ($signs & 0x1) { # flip
13             $sum -= $A[$j];
14             $flipped++;
15          }
16          else {
17             $sum += $A[$j];
18          }
19          $signs >>= 1;
20       }
21       my $complementary = $n + 1 - $flipped;
22       ($sum, $flipped) = (-$sum, $complementary) if $sum < 0;
23       $flipped = $complementary if $sum == 0 && $flipped > $complementary;
24       ($min, $retval) = ($sum, $flipped)
25          if !defined($min)
26             || $sum < $min
27             || ($sum == $min && $flipped < $retval);
28    }
29    return $retval;
30 }
```

To leverage our intuition, we remove the first item from `@A` (line 2)
and assume it will always be assumed to have a `+` sign when calculating
the sum (line 9, where `$sum` is initialized to the positive value of
`$first`).

Removing the first item means that we have to assign one less sign (line
3) and do half of the iterations (line 4) than before, which saves us
half of the sums!

After calculating the sum for our assignment, two possibilities have to
be taken into account:

- if the sum is negative, we just flip it (line 22) to get a positive
  one, which is useful for our purposes;
- if the sum is zero, we can still choose the flipped one (which also
  has zero sum) by comparing the number of bits that were flipped, and
  choosing the other one if it implies less flipping (line 23).

The last part is the same as before, i.e. update the tracker for the
return value.

Now one consideration: this is potentially a big improvement, because it
potentially halves the time to calculate the result. Fact is... halving
the time is not that great. The algorithm is still exponential... so it
still scales extremely bad. Ouch.

## The whole thing

As usual, if you are curious of the whole script here's it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub flip_array_basic (@A) {
   my $n = scalar(@A); # number of signs that can be flipped
   my $N = 2 ** $n;
   my $i = 0;
   my ($min, $retval);
   while ($i < $N) {
      my $signs = $i++;
      my $sum = 0;
      my $flipped = 0;
      for my $j (0 .. $#A) {
         if ($signs & 0x1) { # flip
            $sum -= $A[$j];
            $flipped++;
         }
         else {
            $sum += $A[$j];
         }
         $signs >>= 1;
      }
      next if $sum < 0;
      ($min, $retval) = ($sum, $flipped)
         if !defined($min)
            || $sum < $min
            || ($sum == $min && $flipped < $retval);
   }
   return $retval;
}

sub flip_array (@A) {
   my $first = shift @A;
   my $n = scalar(@A); # number of signs that can be flipped
   my $N = 2 ** $n;
   my $i = 0;
   my ($min, $retval);
   while ($i < $N) {
      my $signs = $i++;
      my $sum = $first;
      my $flipped = 0;
      for my $j (0 .. $#A) {
         if ($signs & 0x1) { # flip
            $sum -= $A[$j];
            $flipped++;
         }
         else {
            $sum += $A[$j];
         }
         $signs >>= 1;
      }
      my $complementary = $n + 1 - $flipped;
      ($sum, $flipped) = (-$sum, $complementary) if $sum < 0;
      $flipped = $complementary if $sum == 0 && $flipped > $complementary;
      ($min, $retval) = ($sum, $flipped)
         if !defined($min)
            || $sum < $min
            || ($sum == $min && $flipped < $retval);
   }
   return $retval;
}

my @A = @ARGV ? @ARGV : (3, 10, 8);
say flip_array(@A);
```

Have fun and be safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#083]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-083/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-083/#TASK2
