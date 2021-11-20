---
title: PWC139 - Long Primes
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-11-18 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#139][].
> Enjoy!

# The challenge

> Write a script to generate first 5 Long Primes.
>
>> A prime number (p) is called Long Prime if (1/p) has an infinite
>> decimal expansion repeating every (p-1) digits.
>
> **Example**
>
>     7 is a long prime since 1/7 = 0.142857142857...
>     The repeating part (142857) size is 6 i.e. one less than the prime number 7.
>
>     Also 17 is a long prime since 1/17 = 0.05882352941176470588235294117647...
>     The repeating part (0588235294117647) size is 16 i.e. one less than the prime number 17.
>
>     Another example, 2 is not a long prime as 1/2 = 0.5.
>     There is no repeating part in this case.

# The questions

This is the second challenge with a "license to search", which I daresay
is an interesting twist to the usual linking in past challenges. I mean,
we're growing up and we can do our searches, right?

Our host is nice though, so it's easy to find the right hint around.
Hoping, of course, that we're talking about [full reptend primes][].

# The solution

There's a few ways to check for the required property, but I'll stick to
the one hinted in the challenge text and look for the *period* of the
division of 1 by the candidate prime.

We'll start with [Perl][], where we need to implement a primality test.
We're talking about low numbers here, so there's no need to optimize
anything 🙄

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
my $N = shift || 5;
my $p = 2;
while ($N > 0) {
   if (is_long_prime($p)) {
      say $p;
      --$N;
   }
   $p++;
}
sub is_prime ($n) {
   for (2 .. sqrt $n) { return unless $n % $_ }
   return 1;
}
sub is_long_prime ($n) {
   return unless (10 % $n) && is_prime($n);
   my $num = 1 . '0' x length($n);
   my %seen;
   $num = 10 * ($num % $n) while ! $seen{$num}++;
   return $n - 1 == scalar keys %seen;
}
```

The `%seen` hash keeps track of the starting numbers to divide. As soon
as we get back to one number to be divided again... we've hit the period
and we can get out. The number of elements in the hash represents the
period length, so we can compare it against the prime value less 1 and
call it a day.

[Raku][] now, where we already have `is-prime` for free:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int $N is copy = 5) {
   my $p = 2;
   while ($N > 0) {
      if (is-long-prime($p)) {
         $p.put;
         --$N;
      }
      $p++;
   }
}
sub is-long-prime (Int:D $n where * > 0) {
   return False unless (10 % $n) && $n.is-prime;
   my $num = 1 ~ 0 x $n.chars;
   my %seen;
   $num = 10 * ($num % $n) while ! %seen{$num}++;
   return $n - 1 == %seen.elems;
}
```

For everything else we're reusing the [Perl][] implementation, with just
some adjustement.

Have fun and stay safe folks!!!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#139]: https://theweeklychallenge.org/blog/perl-weekly-challenge-139/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-139/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[full reptend primes]: https://en.wikipedia.org/wiki/Full_reptend_prime
