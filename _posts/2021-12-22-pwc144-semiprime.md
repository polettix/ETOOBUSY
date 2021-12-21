---
title: PWC144 - Semiprime
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-22 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#144][]. Enjoy!

# The challenge

> Write a script to generate all `Semiprime` number `<= 100`.
>
> For more information about `Semiprime`, please checkout the [wikipedia
> page][].
>
>> In mathematics, a semiprime is a natural number that is the product
>> of exactly two prime numbers. The two primes in the product may equal
>> each other, so the semiprimes include the squares of prime numbers.
>
> **Example**
>
>     10 is Semiprime as 10 = 2 x 5
>     15 is Semiprime as 15 = 3 x 5

# The questions

No questions asked. I wonder where we're going with all these divisors.
But I will not ask!

# The solution

We will see three different approaches in [Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $limit where * > 0 = 100) {
   semiprimes-upto-constructive-tight($limit).join(', ').put;
   semiprimes-upto-constructive-flow($limit).join(', ').put;
   semiprimes-upto-deconstruct($limit).join(', ').put;
}
```

The first one is a *constructive approach* where we multiply pairs of
primes and keep only the ones that fall within the limit.

```
sub semiprimes-upto-constructive-tight ($limit) {
   my @ps = (2 .. 1 + ($limit / 2).Int).grep: *.is-prime;
   my @retval;
   for ^@ps -> $li {
      my $n-start = @retval.elems;
      for $li ..^ @ps -> $hi {
         my $prod = @ps[$li] * @ps[$hi];
         last if $prod > $limit;
         @retval.push: $prod;
      }
      last if @retval.elems == $n-start;
   }
   return @retval.sort;
}
```

The maximum of these primes will be not greater than half the limit,
because the minimum other prime we can multiply it with is... 2. These
primes are collected in `@ps` at the beginning.

We then iterate in two nested loops; the inner one starts from where the
outer one is, to take squares of prime numbers into account but avoid
taking duplicates. The check for the limit is within the inner loop,
just before taking a value.

The second approach is still constructive, but tries to appear smarter.
There's nothing really fancy, apart maybe the construction of the pairs
of candidates via the `X` operator.


```raku
sub semiprimes-upto-constructive-flow ($limit) {
   my @ps = (2 .. 1 + ($limit / 2).Int).grep: *.is-prime;
   (@ps X @ps) # consider all pairs of those primes
      .grep({$_[0] <= $_[1]}) # DRY
      .map({[*] @$_})         # multiply them
      .grep({$_ <= $limit})   # stay within the limit
      .sort;                  # format and cook
}
```

Last, the third approach is *destructive*: we consider every natural
number up to the limit a *candidate* semiprime, and check if it really
is. To this regard, we try to divide it by a prime and, if successful,
check that the quotient is a prime as well.

```raku
sub semiprimes-upto-deconstruct ($limit) {
   my @ps;
   gather for 2 .. $limit -> $candidate {
      if $candidate.is-prime { @ps.push: $candidate }
      else {
         for @ps -> $prime {
            next unless $candidate %% $prime;
            my $other = ($candidate / $prime).Int;
            take $candidate if ($other >= $prime) && $other.is-prime;
         }
      }
   };
}
```

For the [Perl][] counterpart we will translate only the first one - I
know, it's the most boring one but I suspect it's also the most
efficient. I have no proof though.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $limit = shift // 100;
say join ', ', semiprimes_upto_constructive_tight($limit);

sub semiprimes_upto_constructive_tight ($limit) {
   my @ps = primes_upto(1 + $limit / 2);
   my @retval;
   for my $li (0 .. $#ps) {
      my $n_start = @retval;
      for my $hi ($li .. $#ps) {
         my $prod = $ps[$li] * $ps[$hi];
         last if $prod > $limit;
         push @retval, $prod;
      }
      last if @retval == $n_start;
   }
   return sort { $a <=> $b } @retval;
}

sub primes_upto ($n) {
   return if $n < 2;
   my @ps = 2;
   my $candidate = 3;
   CANDIDATE:
   while ($candidate <= $n) {
      for my $p (@ps) { next CANDIDATE unless $candidate % $p }
      push @ps, $candidate;
   }
   continue { $candidate += 2 }
   return @ps;
}
```

Well... I hope you enjoyed it, stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#144]: https://theweeklychallenge.org/blog/perl-weekly-challenge-144/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-144/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia page]: https://en.wikipedia.org/wiki/Semiprime
