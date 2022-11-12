---
title: PWC080 - Count Candies
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> On with [Perl Weekly Challenge][] [TASK #2][] in issue [#080][].

# The challenge

> You are given rankings of @N candidates. Write a script to find out
> the total candies needed for all candidates. You are asked to follow
> the rules below:
> 1. You must given at least one candy to each candidate.
> 2. Candidate with higher ranking get more candies than their immediate
> neighbors on either side.

# The questions

First and foremost... it's nowhere to be found that we should find the
*minimum* number of candies that still satisfy the constraints.
This makes the problem prone to something like *just sum up the ranks*
or, in case, use that sum plus the number of candidates (which
corresponds to adding one candy to everyone).

Which also brings us to... are ranks positive? Non-negative? Any
possible real value? Finding the minimum value and offseting by it, as
well as taking integers might help. But I digress.

As often happens, a question or two about corner cases and invalid input
would be well placed, like:

- what happens if an input rank is not a number?
- what happens if the input list is empty? (I guess the result can be
  0... or any number above it!)

# The solution

Assuming we want to calculate the *minimum number of candies that still
satisfy the requirements*, the best I could think of was to just
starting distributing candies in *waves* and stop when all constraints
are satisfied.

We *know* that we will stop at some time because adjacent candidates
with the same ranking do not interact with each other - in other terms,
it's perfectly OK to have two equally ranked candidates hold a different
number of candies.

Enough with talking, let's take a look at the solution:


```perl
 1 sub candies_for_candidates (@N) {
 2    return unless @N;
 3 
 4    my @candies = (1) x @N; # everybody gets a candy!
 5    push @N, max($N[0], $N[-1]) + 1; # add "edge" value to simplify loops
 6 
 7    while ('necessary') {
 8       my $something_changed = 0;
 9       for my $i (0 .. $#candies) {
10          for my $delta (-1, 1) {
11             next if $N[$i] <= $N[$i + $delta];
12             next if $candies[$i] > $candies[$i + $delta];
13             $candies[$i] = $candies[$i + $delta] + 1;
14             $something_changed = 1;
15          }
16       }
17       last unless $something_changed;
18    }
19    return sum @candies;
20 }
```

The `@candies` return value is initialized with one candy per candidate
in line 4.

Then we add a *fake candidate* at the end of the list (but not at the
end of the candy list) which is surely *better* thank both the first and
the last candidates. This will not change the candies assigned to these
two candidates, but makes it easy to loop over the inputs because this
*fake candidate* will be the follower of the last candidate, as well as
the predecessor of the first one (that's thanks to how [Perl][] handles
negative indexes while accessing arrays). So we will not have to do
anyting special for these two candidates, which simplifies our loops
later.

Line 7 is my take on an *indefinitely long* loop; string `necessary` is
*true* (because it's not a value that [Perl][] thinks is *false*), so
the `while` condition is always true. As a matter of fact, exiting from
the loop *can* happen in line 17, where we exit from this outer loop
only when we didn't add any new candy to the lot. Variable
`$something_changed` (defined in line 10) allows us figure out if this
happened or not.

The medium loop in line 9 sweeps through the list of indexes in the
candies and the *actual* input candidates (i.e. disregarding the *fake*
one). At each of the index, we compare the element with its neighbors
(using `$delta` to look on the left and the right, defined in line 10).

If the element under analisys is lower than the neighbor... move on, and
this happens in line 11.

Otherwise: if the current candidate *already* holds more candies... move
on, it does not get more!

Otherwise... well, we have to give more candies. For good measure, let's
just add one to the neighbor's count, and we're done.

After the last wave, we exit from the outer loop in line 17 and return
the sum of candies.

Sweet!

# Full code for playing

Here you go, with all `use`s and some tests to play with:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util qw< max sum >;

sub candies_for_candidates (@N) {
   return unless @N;

   my @candies = (1) x @N; # everybody gets a candy!
   push @N, max($N[0], $N[-1]) + 1; # add "edge" value to simplify loops

   while ('necessary') {
      my $something_changed = 0;
      for my $i (0 .. $#candies) {
         for my $delta (-1, 1) {
            next if $N[$i] <= $N[$i + $delta];
            next if $candies[$i] > $candies[$i + $delta];
            $candies[$i] = $candies[$i + $delta] + 1;
            $something_changed = 1;
         }
      }
      last unless $something_changed;
   }
   return sum @candies;
}

for my $test (
   [ 1, 2, 2 ],
   [ 1, 3, 4, 1 ],
   [ 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7 ],
   ) {
   say candies_for_candidates($test->@*);
}
```


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#080]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-080/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-080/#TASK2
[Perl]: https://www.perl.org/
