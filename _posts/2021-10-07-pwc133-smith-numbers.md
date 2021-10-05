---
title: PWC133 - Smith Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#133][].
> Enjoy!

# The challenge

> Write a script to generate first 10 `Smith Numbers` in base 10.
>
> According to [Wikipedia][]:
>
>> In number theory, a Smith number is a composite number for which,
>> in a given number base, the sum of its digits is equal to the sum
>> of the digits in its prime factorization in the given number base.

# The questions

Nothing much to ask in this case.

Well, at least because there's a clear expectation on the outputs,
**and** the [Wikipedia page][Wikipedia] provides the answer and much
more.

Why should I want to know the answer beforehand? Because I didn't know
beforehand how *hard* it would be to find the first 10 items, so I
didn't know whether I had to think with some optimization in mind or
not. It turns out that the first items are quite small and no
optimization is needed, whew!


# The solution

This time I'm starting with [Perl][] first. The test for *smith-iness*
is in its own sub `is_smith`, while `smith_first` takes care to find the
first items as requested.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';
sub is_smith ($x) {
   my $sum = sum split m{}mxs, $x;
   my $div = 2;
   my $ndiv = 0;
   while ($x > 1 && $sum > -1) {
      if ($x % $div == 0) {
         my $subsum = sum split m{}mxs, $div;
         while ($x % $div == 0) {
            $sum -= $subsum;
            $x /= $div;
            ++$ndiv;
         }
      }
      $div = $div % 2 ? $div + 2 : 3;
   }
   return $sum == 0 && $ndiv > 1;
}
sub smith_first ($n) {
   my @retval;
   my $candidate = 3; # one less of first composite number
   while ($n > @retval) {
      next unless is_smith(++$candidate);
      push @retval, $candidate;
   }
   return @retval;
}
say for smith_first(shift // 10);
```

The `is_smith` function tries 2 and then all odd numbers as candidate
divisors. To do the check, we first calculate the sum of all digits in
`$sum`; later, we will *subtract* the sum of the digits for all prime
factors as many times as they appear. If we're left with 0 and we
removed at least two divisors... we have a Smith number.

Thanks to repeated divisions, the check for a divisor will actually only
succeed with prime numbers. When one of them divides our input, we
calculate the sum of the digits in the divisor inside `$subsum`, then
iterate until we have removed all instances of that divisor.

The [Raku][] counterpart takes the same shape:

```raku
#!/usr/bin/env raku
use v6;
sub is-smith (Int:D() $x is copy where * > 0) {
   my $sum = $x.comb(/\d/).sum;
   my $div = 2;
   my $ndiv = 0;
   while $x > 1 && $sum > -1 {
      if $x %% $div {
         my $subsum = $div.comb(/\d/).sum;
         while $x %% $div {
            $sum -= $subsum;
            $x /= $div;
            ++$ndiv;
         }
      }
      $div += $div == 2 ?? 1 !! 2;
   }
   return $sum == 0 && $ndiv > 1;
}
sub smith-first (Int:D $n is copy where * > 0) {
   my $candidate = 3; # one less of first composite number
   gather while $n > 0 {
      next unless is-smith(++$candidate);
      take $candidate;
      --$n;
   }
}
sub MAIN ($n = 10) { .put for smith-first($n) }
```

Nothing much to add with respect to the [Perl][] counterpart, honestly.
I like a lot the presence of the *is-divisible-by* operator `%%`, as
well as using `comb` to do the splitting by the things I want and, of
course, be able to use my loved `gather`/`take` pair.

Have fun folks, and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#133]: https://theweeklychallenge.org/blog/perl-weekly-challenge-133/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-133/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Wikipedia]: https://en.wikipedia.org/wiki/Smith_number
