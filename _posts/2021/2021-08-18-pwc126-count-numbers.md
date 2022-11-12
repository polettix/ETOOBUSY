---
title: PWC126 - Count Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-18 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#126][]. Enjoy!

# The challenge

> You are given a positive integer `$N`.
> 
> Write a script to print count of numbers from 1 to `$N` that don’t
> contain digit `1`.
> 
> **Example**
>
>     Input: $N = 15
>     Output: 8
>    
>         There are 8 numbers between 1 and 15 that don't contain digit 1.
>         2, 3, 4, 5, 6, 7, 8, 9.
>    
>     Input: $N = 25
>     Output: 13
>    
>         There are 13 numbers between 1 and 25 that don't contain digit 1.
>         2, 3, 4, 5, 6, 7, 8, 9, 20, 22, 23, 24, 25.

# The questions

One question I would ask is whether there is a reasonable limit for the
input number `$N`. I mean, this is extremely simple to break with a
brute-force approach, but it becomes unfeasable with large number. On
the same tune there would be the question about how many times should
this be called in a speciic time slot.

Nit-picking a bit, I guess that we have to count the *integers* between
the two input numbers. I would double check that `$N` sould be indeed
included, although the second example makes it pretty clear that it is
indeed.

Last, I would also double check that we're talking base 10 here. Were it
base 2... the answer would be trivial 🤓

# The solution

The basic idea to address this puzzle is the observation that we can
proceed *in chunks*. As an example, let's take `5314` as an example
input.

It is greater than or equal to `5000`, so for sure it will contain all
matching number between `1` and `4999`, plus those between `5000` and
`5314`.

Calculating the first slot can be simplified by observing that we're
dealing with all the numbers whose first digit ranges from `0` to `4`
and the rest of three digits range from `0` to `9`. This also includes
`0000` of course, but we can just subtract 1 from the result.

Now:

- the first digit must not contain `1`, so out of the `4` in our
  example, we have to ignore that and be left with `0`, `2`, `3`, and
  `4`. That is... 4 numbers. Where does the 4 come from, anyway? It is
  the first digit $F$ of our input number, less 1, so there we have it;
- the other digits can range from `0` to `9`, skipping `1`. So each slot
  can only contain 9 possible candidates, all *independent* of one
  another. If there are 3 slot as in our case, we have a total of $9^3$
  allowed arrangement. In general, if the input number `$N` has $k$
  digits, this part will have $9^k$ possible arrangements.

All in all, then, we end up with $F \cdot 9^k$ possible allowed
arrangements.

At this point, we can chop off the first digit `5` and do the same with
the remaining part `314`.

Super-easy... right?!? Well... *almost*.

This is the general gist, but there are a *ton* of shady corners and
special cases to consider. As an example, as soon as we arrive to a
residual number starting with `1`, it has no use to move further the
basic calculation because all numbers will be prefixed with that `1`.

Considering that there are so many poorly lit corners, I decided to
start with a brute-force baseline calculator, just to be able and double
check my *smarter* solutions. I started with [Raku][]:

```raku
sub count-like-no-one-bf (Int:D $N where * > 0) {
   (2 .. $N).grep({! /1/}).elems
}
```

I don't know if it's *idiomatic*, but it works and it's *readable*. We
start with the list of candidates (starting from 2 because 1 is out of
the game, right?), remove any candidate with at least one `1` and count
how many items we're left with.

Theoretically speaking we would be done here, at least for inputs say
below `1000` (arbitrary) and few calls. Practically speaking, though,
it's time to move on.

For technical reasons I switched to [Perl][], again starting with the
brute force approach to have a baseline:

```perl
sub count_like_no_ones_bf ($N) { scalar grep {! m{1}mxs} 2 .. $N }
```

The description of the algorithm made me think about a recursive
implementation at first thought, then I realized that chopping off the
first digit was actually very easy to accomplish with a loop, so I ended
up with this:

```perl
sub count_like_no_ones ($N) {
   my $count = 0;
   my @digits = split m{}mxs, $N;
   while (@digits) {
      my $first = shift @digits;
      if (@digits) { # more to go after, use chunking
         my $factor = $first > 1 ? $first - 1 : $first;
         $count += $factor * 9 ** @digits;
      }
      else { # last digit, count all including 0
         $count += $first > 1 ? $first : 1;
      }
      last if ($first == 1);
   }
   # we took into account sequence of all 0, so we remove it
   return $count - 1;
}
```

I will never admit that it took me way more than I anticipated. Don't
even ask please.

Anyway, it works although it's not as elegant as I would have liked. All
the special cases are there, but they behave differently for the last
digit and this is somehow itchy. Anyway.

At this point I wondered how the recursive implementation would look
like. So, of course, I coded it:

```perl
sub count_like_no_ones_r ($N) {
   return($N > 1 ? $N - 1 : 0) if $N < 10;
   my $first = substr $N, 0, 1, '';
   my $factor = $first > 1 ? $first - 1 : $first;
   my $count = $factor * 9 ** length($N);
   $count += 1 + count_like_no_ones_r($N) if $first != 1;
   return $count - 1;
}
```

This is probably *slightly* more intuitive. Making a difference between
the general case and the one with one digit only is much simpler (first
line in the sub). There is one little catch where we have to add 1 to
the result of the recursive call, but it's needed to have the right
value eventually so there it is.

I think that the [Benchmark][] is interesting in this case. I first
started with computing all numbers from 1 to 9999:

```perl
use Benchmark 'cmpthese';
...
my @inputs = 0 .. 9999;
cmpthese(-5,
   {
      recursive => sub { count_like_no_ones_r($_) for @inputs },
      iterative => sub { count_like_no_ones($_) for @inputs },
   }
);
```

and, *surprise surprise*, the *recursive* function worked better:

```
            Rate iterative recursive
iterative 35.4/s        --       -8%
recursive 38.4/s        8%        --
```

Time and again I'm baffled by the fact that the recursive function works
faster. *Except* that it does not scale as well as the iterative one,
which can be seen by adding a few `9` before:

```perl
my @inputs = 99999999990000 .. 99999999999999;
cmpthese(-5,
   {
      recursive => sub { count_like_no_ones_r($_) for @inputs },
      iterative => sub { count_like_no_ones($_) for @inputs },
   }
);
```

Running it now yields:

```
            Rate recursive iterative
recursive 8.67/s        --      -22%
iterative 11.0/s       27%        --
```

which is what I was expecting to be honest.

Last, I returned to [Raku][], only porting the iterative version in what
is basically a straight translation with very few changes:

```raku
sub count-like-no-one (Int:D $N where * > 0) {
   my $count = 0;
   my @digits = $N.comb;
   while (@digits) {
      my $first = @digits.shift;
      if (@digits) {
         my $factor = $first > 1 ?? $first - 1 !! $first;
         $count += $factor * 9 ** @digits;
      }
      else {
         $count += $first > 1 ?? $first !! 1;
      }
      last if $first == 1;
   }
   return $count - 1;
}
```

And with this... I guess it's all for this puzzle! I hope you enjoyed
the ride and that will accept a recommendation... *to stay safe*!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#126]: https://theweeklychallenge.org/blog/perl-weekly-challenge-126/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-126/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Benchmark]: https://metacpan.org/pod/Benchmark
