---
title: PWC169 - Brilliant Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-15 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#169][]. Enjoy!

# The challenge

> Write a script to generate first `20 Brilliant Numbers`.
>
>> Brilliant numbers are numbers with two prime factors of the same
>> length.
>
> The number should have exactly two prime factors, i.e. it’s the
> product of two primes of the same length.
>
> For example,
>
>     24287 = 149 x 163
>     24289 = 107 x 227
>
>     Therefore 24287 and 24289 are 2-brilliant numbers.
>     These two brilliant numbers happen to be consecutive as there are no even brilliant numbers greater than 14.
>
>
> **Output**
>
>     4, 6, 9, 10, 14, 15, 21, 25, 35, 49, 121, 143, 169, 187, 209, 221, 247, 253, 289, 299

# The questions

I was surprised to see squares in the example output, but I guess that
nowhere it's said that the two prime factors should be different and
surely a prime has the same length as itself.

# The solution

Super quick, I have a train to catch!

Very lazy approach, I compute every brilliant number in the 1/2/... tier
and then only use the ones that I need. This has the potential to waste
*a lot* of resources, but works quite fine for the 20 items limit set in
the challenge.

[Raku][] first, which gives us some *meta* excitement:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $limit where * > 0 = 20) {
   my $length = 1;
   my @brilliants;
   while @brilliants < $limit {
      @brilliants.push: pairs-products(primes-of-length($length++)).Slip;
   }
   put @brilliants[0 ..^ $limit].join(', ');
}

sub pairs-products (@ns) {
   (@ns X @ns).grep({[<=] $_}).map({[*] $_}).sort;
}

sub primes-of-length (Int:D $n where * > 0) {
   my $lo = [*] 10 xx ($n - 1);
   ($lo .. $lo * 10).grep({.is-prime}).Array;
}
```

[Perl][] is the same algorithm, more or less, I just chose an iterator
approach to take all primes of a specific tier:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use ntheory qw< next_prime >;

my $limit = shift // 20;
my $it = primes_by_length_it();
my @brilliants;
while (@brilliants < $limit) {
   push @brilliants, pairs_products($it->());
}
say join ', ', @brilliants[0 .. ($limit - 1)];

sub pairs_products (@ns) {
   my @products;
   for my $i (0 .. $#ns) {
      for my $j ($i .. $#ns) {
         push @products, $ns[$i] * $ns[$j];
      }
   }
   return sort { $a <=> $b } @products;
}

sub primes_by_length_it {
   my $carry = 2;
   my $length = 1;
   return sub {
      my @retval;
      while (length($carry) == $length) {
         push @retval, $carry;
         $carry = next_prime($carry);
      }
      ++$length;
      return @retval;
   };
}
```

That's all folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#169]: https://theweeklychallenge.org/blog/perl-weekly-challenge-169/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-169/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
