---
title: PWC167 - Circular Prime
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-31 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#167][]. Enjoy!

# The challenge


> Write a script to find out first `10 circular primes` having at least 3
> digits (base 10).
>
> Please checkout [wikipedia][] for more information.
>
>> A circular prime is a prime number with the property that the number
>> generated at each intermediate step when cyclically permuting its
>> (base 10) digits will also be prime.
>
> **Output**
>
>     113, 197, 199, 337, 1193, 3779, 11939, 19937, 193939, 199933

# The questions

Something that is *not* specified is that only the lowest value in a set
of rotations should be considered. Right? I mean, 131 is a circular
prime too, but if we print out 113 then we skip it.

# The solution

It's bare bones string manipulation and tests for primality all the way
down:

```raku
#!/usr/bin/env raku
use v6;
subset PosInt where * > 0;
sub MAIN (PosInt:D $n is copy = 10) {
   my $x = 99;
   my @result = gather while $n > 0 {
      if is-circular-prime($x) {
         take $x;
         --$n;
      }
      $x += 2;
   }
   @result.join(', ').put;
}

sub is-circular-prime ($x is copy) {
   my $initial = $x;
   for 1 ..^ $x.chars {
      return False unless $x.is-prime;
      $x = $x.substr(*-1, 1) ~ $x.substr(0, *-1);
      return False if $x < $initial;
   }
   return $x.is-prime;
}
```

And, of course, the [Perl][] version. Here we're taking advantage of
[ntheory][] to iterate through primes only *natively*:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use File::Basename 'dirname';
use lib dirname(__FILE__) . '/local/lib/perl5';

use ntheory qw< next_prime is_prime >;

my $n = shift // 10;
my @retval;
my $candidate = 100;
while ($n > 0) {
   $candidate = next_prime($candidate);
   next unless is_circular_prime($candidate);
   push @retval, $candidate;
   --$n;
}

say join ', ', @retval;

sub is_circular_prime ($x) {
   my $initial = $x;
   for (2 .. length $x) {
      return !!0 unless is_prime($x);
      $x = substr($x, 1) . substr($x, 0, 1);
      return !!0 if $x < $initial;
   }
   return is_prime($x);
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#167]: https://theweeklychallenge.org/blog/perl-weekly-challenge-167/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-167/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ntheory]: https://metacpan.org/pod/Math::Prime::Util
[wikipedia]: https://en.wikipedia.org/wiki/Circular_prime
