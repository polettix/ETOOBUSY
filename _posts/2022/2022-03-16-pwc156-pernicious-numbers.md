---
title: PWC156 - Pernicious Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-16 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#156][]. Enjoy!

# The challenge


> Write a script to permute first `10 Pernicious Numbers`.
>
>> A pernicious number is a positive integer which has prime number of
>> ones in its binary representation.
>
> The first pernicious number is 3 since binary representation of 3 =
> (11) and 1 + 1 = 2, which is a prime.
>
> **Expected Output**
>
>     3, 5, 6, 7, 9, 10, 11, 12, 13, 14

# The questions

I'm not sure what we mean by *permute* the first 10 pernicious numbers,
because the expected output only lists them in order. That's probably a
typo for *compute*.

The count to evaluate is precise, as it usually is, so no more
questions. Were it not so specific, I'd at least ask for a ballpark.

# The solution

There are so few pernicious numbers to calculate that it might be done
by hand. The first three prime numbers are 2, 3, and 5, which
respectively yield minimal pernicious numbers of 3 (`11`), 7 (`111`),
and 31 (`11111`).

Before hitting 31, every number that has exactly either two or three
bits is good for us, so e.g. 5 (`101`), 6 (`110`) and so on;

```
     0  N (0 "1")
     1  N (1 "1")
    10  N (1)
    11  Y (2 "1")
   100  N (1)
   101  Y (2)
   110  Y (2)
   111  Y (3 "1")
  1000  N (1)
  1001  Y (2)
  1010  Y (2)
  1011  Y (3)
  1100  Y (2)
  1101  Y (3)
  1110  Y (3)
  1111  N (4 "1")
```

This list alone already contains enough pernicious numbers to answer the
challenge.

I'm usually tempted to generalize these challenges to account for an
unspecified number of outputs, possibly in an efficient incremental way.
This time, though, I decided to be *very lazy*. I mean **very** lazy. So
it's basically a matter of programming the most brutey thing I can come
up with.

[Raku][] allows us to be **very** brutey:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Int:D $N = 10) {
   my @pernicious;
   my $k = 0;
   while @pernicious < $N {
      @pernicious.push: $k if is-pernicious($k);
      ++$k;
   }
   @pernicious.join(', ').put;
}

sub is-pernicious (Int:D $n where * >= 0) { $n.base(2).comb.sum.is-prime }
```

I mean, what could I ask more? Turning to base 2? Check. Counting the
ones with a few keystrokes? Check. Testing for primality? Check.
Checking the inputs? Check.

This probably does not scale *exceptionally* but who knows? And, more
importantly, in this week I feel very much like *who cares?*

[Perl][] needs gathering some batteries externally, but it's OK anyway.
Here we are really being **very, very** brutey, by summoning [ntheory][]
just to use `is_prime` to check primality of integers *up to 3* (we will
stop afterwards). This is what brute force is like.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";
use ntheory 'is_prime';

my $N = shift // 10;
my @pernicious;
my $k = 0;
while (@pernicious < $N) {
   push @pernicious, $k if is_pernicious($k);
   ++$k;
}
say join ', ', @pernicious;

sub is_pernicious ($n) {
   my $count = 0;
   while ($n) {
      ++$count if $n & 1;
      $n >>= 1;
   }
   return is_prime($count);
}
```

Counting the bits that are set is done differently here, in a good old
*mask & shift* fashion. At every round, we increment `$count` if the
last bit is a `1`, then shift the whole input number by one position to
the right. Rinse and repeat until there's no more bits left (i.e. `$n`
drops to 0).

I'm still in awe to have called upon [ntheory][] in this challenge. I'm
proud and ashamed at the same time.

I encourage everyone to stay safe, even more so people who are suffering
from the war. I really do hope this is going to end soon 😢 For everyone
else, though, it seems that media is mostly focused on Ukraine these
days, for good reasons, but please consider carefully your interactions
and their consequences - I hear about a lot of people getting Covid-19.

[The Weekly Challenge]: https://theweeklychallenge.org/
[#156]: https://theweeklychallenge.org/blog/perl-weekly-challenge-156/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-156/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ntheory]: https://metacpan.org/pod/ntheory
