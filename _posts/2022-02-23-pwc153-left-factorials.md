---
title: PWC153 - Left Factorials
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#153][]. Enjoy!

# The challenge

> Write a script to compute `Left Factorials` of `1` to `10`. Please
> refer [OEIS A003422][oeis] for more information.
>
> **Expected Output:**
>
>     1, 2, 4, 10, 34, 154, 874, 5914, 46234, 409114

# The questions

Our fine host is a fox disguised as an innocent lamb!

After having endured countless petty nitpicks (by many, yours truly
included) about missing stuff in formulating the challenges, we are
gently redirected to a place that leaves no doubt about what we're asked
to do:

$$ !n = \sum_{k = 0}^{n-1} k!$$

Well played indeed!


# The solution

Why provide a solution when we can provide... *three*?

[Raku][] goes first, with two of them that will be printed one along the
other, for comparison:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $min = 1, Int:D $max = 10) {
   ($min .. $max).map({left-factorial($_)}).join(', ').put;
   ($min .. $max).map({left-factorial-cached($_)}).join(', ').put;
}
```

The first takes advantage of the `multi` mechanism, separating lower
values from higher ones.

```raku
multi sub left-factorial (Int:D $n where 0 <= * <= 2) { $n }
multi sub left-factorial (Int:D $n where * >  2) {
   my $f = 1;
   1 + (1 ..^ $n).map({$f *= $^x}).sum;
}
```

These higher ones are always calculated over
and over, so in this case we're not reusing any previous calculation,
i.e. calculating `left-factorial` for 5 does not leverage our previous
calculation for 4.

This is a *totally* unacceptable loss of performance, of course. 🙄

In this case, it makes *total* sense to keep those previous values around,
because we're requested to print a sequence of consecutive values. This
leads us to the second solution, which keeps track of previous values in
a few `state` variables:

```
sub left-factorial-cached (Int:D $n where * >= 0) {
   state $factorial = 1;
   state $k = 1;
   state @left-factorials = 0, 1, 2;
   while $n > @left-factorials.end {
      $factorial *= ++$k;
      @left-factorials.push: @left-factorials[*-1] + $factorial;
   }
   return @left-factorials[$n];
}
```

This last solution might be readily translated into [Perl][], but we
take a lazy detour here and let [Perl][] manage caching for us. This
goes at the expense of *over-caching*, because values for the
`factorial` functions are all cached too, while this is not strictly
necessary:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Memoize;

my $min = shift // 1;
my $max = shift // 10;
say join ', ', map { left_factorial($_) } $min .. $max;

memoize('left_factorial');
sub left_factorial ($n) {
   return $n if $n <= 2;
   return factorial($n - 1) + left_factorial($n - 1);
}

memoize('factorial');
sub factorial ($n) {
   return 1 if $n < 2;
   return $n * factorial($n - 1);
}
```

Readability is probably better here, though. This solution makes it
clear the recursive nature of the approach, while at the same time
acknowledging that some dynamic programming can help speed things up as
inputs go high.

So... what do you prefer?

[The Weekly Challenge]: https://theweeklychallenge.org/
[#153]: https://theweeklychallenge.org/blog/perl-weekly-challenge-153/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-153/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[oeis]: http://oeis.org/A003422
