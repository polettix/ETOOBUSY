---
title: PWC085 - Power of two integers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-06 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#085][].
> Enjoy!

# The challenge

> You are given a positive integer `$N`. Write a script to find if it
> can be expressed as `a ^ b` where `a > 0` and `b > 1`. Print 1 if you
> succeed otherwise 0.

# The questions

Not many questions here, apart from the routine ones (is there a limit
to `$N`? Does it fit 32/64 bits? What to do with invalid inputs? Why
42?!?).

# The solution

This challenge is interesting because it can have some *twists*. For
example, we can factorize `$N` and check the result, but we will have to
be careful that $2^4 \cdot 5^2$ can be written as $4^2 \cdot 5^2$, so...
it's not *immediate*.

Well, it's not difficult either. If we get the *minimum* exponent in the
factorization, we can verify that:

- it is greater than `1` - because of the constraint that `b > 1`;
- every other exponent is a multiple of it (possibly equal to it).

So let's put this in code:

```
 1 sub power_of_two_integers ($N) {
 2    my $factors = factor($N);
 3    my ($min, @others) = sort {$a <=> $b} values $factors->%*;
 4    return 0 if $min == 1;
 5    for my $exponent (@others) {
 6       return 0 if $exponent % $min;
 7    }
 8    return 1;
 9 }
```

The call in line 2 assumes that there is a `factor` function that
returns the factorization of the input number. Looking at line 3, we can
see that we expect this function to give back a reference to a hash,
whose keys are the prime numbers in the factorization and the associated
values are the exponents.

As said, we are interested into the exponents only, so we sort them in
increasing numerical order and assign the lowest number to variable
`$min` and collect the rest in `@others` (line 3).

At this point, we first make sure that `$min` is greater than 1 (line
4), then check that all other exponents in `@others` are divisible by it
(lines 5 and 6).

Now we *just* have to implement the factorization into prime factors.
This is the complicated stuff to do, at lest for big numbers; we'll just
put a simple implementation to work:

```
 1 sub factor ($N) {
 2    my %retval;
 3    my @ps = (2, 3);
 4    my $k = 1;
 5    while ($N > 1) {
 6       if (! @ps) {
 7          push @ps, 6 * $k - 1, 6 * $k + 1;
 8          $k++;
 9       }
10       my $p = shift @ps;
11       while ($N % $p == 0) {
12          $retval{$p}++;
13          $N /= $p;
14       }
15    }
16    return \%retval;
17 }
```

We leverage the fact that, after $2$ and $3$, every prime number is of
the form $6 \cdot k \pm 1$. So we keep a small array of prime numbers
`@ps` that we pre-load with $2$ and $3$ (the outliers); afterwards, as
this reservoir of candidate primes empties (line 6), we put the next two
ones (line 7) and prepare for the next pair (line 8).

The astute reader might object that what we extract from `@ps` in line
10 is *not always* a prime. No worries: if it's not a prime, then its
factors have already been analyzed and the test in line 11 will fail
immediately. So there's no need to check it's a prime!

The loop in lines 11 through 14 takes care to *extract* as many `$p`
factors out of `$N` as possible, counting them as it goes. The count is
the same as the exponent for `$p` in the factorization.

> Separating the factorization process and the check process has its
> advantages (clean code, more readable and maintainable) but it also
> has its downsides. As an example, we already know that any factor
> appearing with exponent $1$ would invalidate our test, so in that case
> it might not be needed to have a full factorization.

As usual, if you're interested in the whole program...

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub factor ($N) {
   my %retval;
   my @ps = (2, 3);
   my $k = 1;
   while ($N > 1) {
      if (! @ps) {
         push @ps, 6 * $k - 1, 6 * $k + 1;
         $k++;
      }
      my $p = shift @ps;
      while ($N % $p == 0) {
         $retval{$p}++;
         $N /= $p;
      }
   }
   return \%retval;
}

sub power_of_two_integers ($N) {
   my $factors = factor($N);
   my ($min, @others) = sort {$a <=> $b} values $factors->%*;
   return 0 if $min == 1;
   for my $exponent (@others) {
      return 0 if $exponent % $min;
   }
   return 1;
}

my $N = shift // 8;
say power_of_two_integers($N);
```

See you soon!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#085]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-085/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-085/#TASK2
[Perl]: https://www.perl.org/
