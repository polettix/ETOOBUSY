---
title: PWC155 - Fortunate Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#155][]. Enjoy!

# The challenge


> Write a script to produce first `8 Fortunate Numbers` (unique and
> sorted).
>
> According to [Wikipedia][]
>
>>  A Fortunate number, named after Reo Fortune, is the smallest integer
>>  m > 1 such that, for a given positive integer n, pn# + m is a prime
>>  number, where the primorial pn# is the product of the first n prime
>>  numbers.
>
> **Expected Output**
>
>     3, 5, 7, 13, 17, 19, 23, 37


# The questions

None. From a generalization point of view, it would be interesting to
know what a limit would be instead of 8.

# The solution

The most tricky part for me was that the challenge is about finding the
*first* Fortunate numbers, *unique and sorted*.

So it's not simply about finding the Fortunate numbers associated to the
first $n$ primes, but to sort them and take the first $n$ out of all
possible.

Luckily, it's possible to state that there is a lower limit for values
of Fortunate numbers and this limit strictly grows with $n$. Hence, it's
possible to draw a line beyond which the first $m$ Fortunate numbers
(sorted) are also the *right* ones, so to say.

In particular, this lower limit for the $n$th Fortunate number is the
$n$th prime number. Easy huh?

Let's start with [Raku][]:

```raku
#!/usr/bin/env raku

sub MAIN (Int:D $n = 8) {
   first-fortunate-numbers($n).join(', ').put;
   return 0;
}

sub first-fortunate-numbers($n) {
   my &it = fortunate-numbers-it();
   my @cleared;
   my @seen;
   while @cleared < $n {
      my ($prime, $fn) = &it();
      @seen = (@seen.Slip, $fn).sort.unique;
      @cleared.push: @seen.shift while @seen && @seen[0] < $prime;
   }
   return @cleared[^$n];
}

sub fortunate-numbers-it() {
   my $primorial = 1;
   my &pit = primes-it();
   return sub {
      my $prime = &pit();    # get next prime
      $primorial *= $prime;  # update the primorial
      return 2, 3 if $prime == 2;
      my $n = $prime;
      loop {
         $n += 2;
         return $prime, $n if ($primorial + $n).is-prime;
      }
   }
}

sub primes-it() {
   my @cache = 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47;
   my $last;
   return sub {
      return $last = @cache.shift if @cache;
      loop {
         $last += 2;
         return $last if $last.is-prime;
      }
   }
}
```

We build an iterator for prime numbers `primes-it()` *and* an iterator
for Fortunate numbers `fortunate-numbers-it()`. This latter one returns
two items for each call, namely the $n$th prime number and its
associated Fortunate number.

This allows us apply a filtering algorithm in
`first-fortunate-numbers()` where we keep new entries in array `@seen`,
moving items into array `@cleared` as we move on the lower limit and
thus *clear* the lower found values (i.e. there will not be any new
Fortunate number below them). We iterate until we have enough *cleared*
elements, then return the needed amount.

The [Perl][] translation leverages [List::MoreUtils][] and the venerable
[ntheory][], to implement what's basically a blunt translation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";
use ntheory qw< is_prime next_prime >;
use List::MoreUtils 'uniq';
use bigint;

say join ', ', first_fortunate_numbers(shift || 8);

sub first_fortunate_numbers ($n) {
   my $it = fortunate_numbers_it();
   my (@cleared, @seen);
   while (@cleared < $n) {
      my ($prime, $fn) = $it->();
      @seen = uniq sort { $a <=> $b } (@seen, $fn);
      push @cleared, shift @seen while @seen && $seen[0] < $prime;
   }
   return @cleared[0 .. $n - 1];
}

sub fortunate_numbers_it {
   my $primorial = 1;
   my $prime = 1; # bear with me please...
   return sub {
      $prime = next_prime($prime);
      $primorial *= $prime;
      return (2, 3) if $prime == 2;
      my $n = $prime;
      while ('necessary') {
         $n += 2;
         return ($prime, $n) if is_prime($primorial + $n);
      }
   };
}
```

I hope I didn't miss any corner case... stay safe anyway!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#155]: https://theweeklychallenge.org/blog/perl-weekly-challenge-155/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-155/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Wikipedia]: https://en.wikipedia.org/wiki/Fortunate_number
[List::MoreUtils]: https://metacpan.org/pod/List::MoreUtils
[ntheory]: https://metacpan.org/pod/ntheory
