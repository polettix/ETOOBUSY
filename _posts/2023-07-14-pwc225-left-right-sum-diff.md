---
title: PWC225 - Left Right Sum Diff
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-07-14 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#225][].
> Enjoy!

# The challenge

> You are given an array of integers, @ints.
>
> Write a script to return left right sum diff array as shown below:
>
>     @ints = (a, b, c, d, e)
>
>     @left  = (0, a, (a+b), (a+b+c))
>     @right = ((c+d+e), (d+e), e, 0)
>     @left_right_sum_diff = ( | 0 - (c+d+e) |,
>                              | a - (d+e)   |,
>                              | (a+b) - e   |,
>                              | (a+b+c) - 0 | )
>
> **Example 1:**
>
>     Input: @ints = (10, 4, 8, 3)
>     Output: (15, 1, 11, 22)
>
>     @left  = (0, 10, 14, 22)
>     @right = (15, 11, 3, 0)
>
>     @left_right_sum_diff = ( |0-15|, |10-11|, |14-3|, |22-0|)
>                          = (15, 1, 11, 22)
>
> **Example 2:**
>
>     Input: @ints = (1)
>     Output: (0)
>
>     @left  = (0)
>     @right = (0)
>
>     @left_right_sum_diff = ( |0-0| ) = (0)
>
> **Example 3:**
>
>     Input: @ints = (1, 2, 3, 4, 5)
>     Output: (14, 11, 6, 1, 10)
>
>     @left  = (0, 1, 3, 6, 10)
>     @right = (14, 12, 9, 5, 0)
>
>     @left_right_sum_diff = ( |0-14|, |1-12|, |3-9|, |6-5|, |10-0|)
>                          = (14, 11, 6, 1, 10)

# The questions

I mean... the initial *inspiration* is wrong, I assume, because the array
has five elements but the output only contains four, which seems to be
contradicted by every single example provided. Hence, I guess that the
actual specification's example should be:

```
@ints = (a, b, c, d, e)

@left  = (0, a, (a+b), (a+b+c), (a+b+c+d))
@right = ((b+c+d+e), (c+d+e), (d+e), e, 0)
@left_right_sum_diff = ( | 0 - (b+c+d+e) |,
                         | a   - (c+d+e) |,
                         | (a+b) - (d+e) |,
                         | (a+b+c)   - e |,
                         | (a+b+c+d) - 0 |)
```

Anyway!

# The solution

Well, first of all **congratulations to [manwar][] for his well-deserved
achievement**. I couldn't think of someone more deserving of the *White
Camel Award*, **especially** in the year that it transitions from three
people down to one.

I only have two regrets regarding this: the [video][] does not show him
properly, and I would have liked to congratulate with him in person.

OK, let's get back to (his) business. We will pass through the array twice:
on the first we will accumulate values, building what amounts to the `@left`
array in the examples; on the second, we will subtract values in-place as we
go.

[Perl][] first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

{ local $" = ', '; say "(@{[ left_right_sum_diff(@ARGV) ]})" }

sub left_right_sum_diff (@input) {
   my $sum = 0;
   my @retval;
   for my $i (0 .. $#input) {
      push @retval, $sum;
      $sum += $input[$i];
   }
   for my $i (0 .. $#input) {
      $sum -= $input[$i];
      my $diff = $retval[$i] - $sum;
      $retval[$i] = $diff > 0 ? $diff : -$diff;
   }
   return @retval;
}
```

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@inputs) { say left-right-sum-diff(@inputs) }

sub left-right-sum-diff (@inputs) {
   my $sum = 0;
   my @retval;
   for ^@inputs -> $i {
      @retval.push: $sum;
      $sum += @inputs[$i];
   }
   for ^@inputs -> $i {
      $sum -= @inputs[$i];
      @retval[$i] = abs(@retval[$i] - $sum);
   }
   return @retval;
}
```

And... that's all folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#225]: https://theweeklychallenge.org/blog/perl-weekly-challenge-225/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-225/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[video]: https://www.youtube.com/watch?v=F36Tdrcg1tI
