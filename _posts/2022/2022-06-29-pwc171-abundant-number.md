---
title: PWC171 - Abundant Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-29 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#171][]. Enjoy!

# The challenge

> Write a script to generate first `20 Abundant Odd Numbers`.
>
> According to [wikipedia][],
>
>> A number n for which the sum of divisors σ(n) > 2n, or, equivalently,
>> the sum of proper divisors (or aliquot sum) s(n) > n.
>
> For example, `945` is the first `Abundant Odd Number`.
>
>     Sum of divisors:
>     1 + 3 + 5 + 7 + 9 + 15 + 21 + 27 + 35 + 45 + 63 + 105 + 135 + 189 + 315 = 975

# The questions

I'm always tempted to ask about what *first* means in these challenges.
In these number theory stuff, it usually means *least non-negative
ones*, but it's always stated as *first* and this probably leaves space
to... *is it good to read it as the first ones that I can find?*.

# The solution

The question is not pure nitpicking this time. As the [wikipedia][] page
explains, every (integer) multiple of an abundant number is itself an
abundant number, so multiplying `945` times `1`, `3`, ..., `39` (odds
numbers between `0` and `40`) will bot give us an odd number *and* an
abundant number. So easy to calculate and so light on the environment.

Alas, let's take the parsimonious path and find the lowest ones instead,
starting with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 0 = 20) {
   my @abundants;
   my $candidate = 945;
   while @abundants < $n {
      @abundants.push: $candidate if is-abundant($candidate);
      $candidate += 2;
   }
   put @abundants.join(', ');
}

sub is-abundant (Int:D $n) { $n < [+] proper-positive-divisors($n) }

sub proper-positive-divisors (Int:D $n is copy where * != 0) {
   $n = $n.abs;
   my (@lows, @highs) = 1,;
   my ($lo, $hi) = (2, $n);
   while $lo < $hi {
      if $n %% $lo {
         @lows.push: $lo;
         $hi = ($n / $lo).Int;
         @highs.unshift: $hi if $hi != $lo;
      }
      ++$lo;
   }
   return [@lows.Slip, @highs.Slip];
}
```

It's pure composition of bricks. Sub `proper-positive-divisors` takes
care to give us all... *proper, positive divisors*. This is used inside
the check function `is-abundant` to test the condition. An outer loop
(the `while` in the `MAIN` sub) takes care of finding out the lowest
*EHR* first 20.

The function for finding divisors is marginally interesting. As soon as
we find a divisor, we also find its complementary in the product to get
to the original number, so we can accumulate divisors from the bottom
*and* from the top. At this point, there's no reason to go beyond when
the lower candidate gets past its complementary.

It's interesting that this approach *might* not give us any edge at all
with respect to iterating more and not caring about the complementaries.
This is because - more or less! - there is a division check with the
`%%` operator *and* a real division. Assuming the two take the same
resources, we might just as well ignore the complementary ang move on.

The [Perl][] counterpart is a faithful translation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

my $n = shift // 20;
my @abundants;
my $candidate = 945;
while (@abundants < $n) {
   push @abundants, $candidate if is_abundant($candidate);
   $candidate += 2;
}
say join ', ', @abundants;

sub is_abundant ($n) { $n < sum(proper_positive_divisors($n)) }

sub proper_positive_divisors ($n) {
   return unless $n;
   $n = -$n if $n < 0;
   my (@lows, @highs) = (1);
   my ($lo, $hi) = (2, $n);
   while ($lo < $hi) {
      if ($n % $lo == 0) {
         push @lows, $lo;
         $hi = int($n / $lo);
         unshift @highs, $hi if $hi != $lo;
      }
      ++$lo;
   }
   return (@lows, @highs);
}
```

It feels less sophisticated but heck does this feel natural!

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#171]: https://theweeklychallenge.org/blog/perl-weekly-challenge-171/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-171/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia]: https://en.wikipedia.org/wiki/Abundant_number
