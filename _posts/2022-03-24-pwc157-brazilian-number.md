---
title: PWC157 - Brazilian Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#157][].
> Enjoy!

# The challenge

> You are given a number `$n > 3`.
>
> Write a script to find out if the given number is a `Brazilian
> Number`.
>
>> A positive integer number N has at least one natural number B where 1
>> < B < N-1 where the representation of N in base B has same digits.
>
> **Example 1:**
>
>     Input: $n = 7
>     Output: 1
>
>     Since 7 in base 2 is 111.
>
> **Example 2:**
>
>     Input: $n = 6
>     Output: 0
>
>     Since 6 in base 2 is 110,
>           6 in base 3 is 30 and
>           6 in base 4 is 12.
>
> **Example 3:**
>
>     Input: $n = 8
>     Output: 1
>
>     Since 8 in base 3 is 22.

# The questions

I guess the only question here would be about the limits in the input,
like the possibility to have a higher bound or so.

# The solution

I started with a pure brute force implementation, only to figure that
even numbers since 8 on are all Brazilian, only to find out that this
can be generalized... so I ended up with a hybrid solution in [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @candidates = @ARGV ? @ARGV : (7, 6, 8);
for my $candidate (@candidates) {
   my $bb = is_brazilian($candidate);
   say "$candidate -> ", ($bb ? 1 : 0), " # $bb";
}

sub is_brazilian ($n) {
   for my $p (2, 3, 5, 7, 11, 13, 17, 19) {
      next if $n % $p;
      my $b = $n / $p - 1;
      next if $b <= $p;
      return $b;
   }
   return is_brazilian_bf($n);
}

sub is_brazilian_bf ($n) {
   BASE:
   for my $b (reverse 2 .. $n - 2) {
      return $b if is_brazilian_with($n, $b);
   }
   return 0;
}

sub is_brazilian_with ($n, $b) {
   use integer;
   my $digit = $n % $b;
   while ($n > 0) {
      return 0 if $digit != $n % $b;
      $n /= $b;
   }
   return 1;
}
```

The reasoning goes along these lines: if the number $n$ is divisible by
some prime $p$, we can express it like this:

$$
n = k \cdot p = (k - 1) \cdot p + p = b \cdot p + p
$$

Now, if $p$ is strictly lower than $k - 1$, this is exactly how we would
express $n$ in base $b = k - 1$, i.e. $n$ is brazilian because it can be
expressed as $pp$ in base $k - 1$. As an example, let's take integer 35:

$$
35 = 7 \cdot 5 = 6 \cdot 5 + 5
$$

i.e. it can be expressed as $55$ in base 6.

We MUST check that $p < b = k - 1$, because of how base-$b$ numbers
work, i.e. the "digits" can only be in the integer range between 0 and
$b - 1$. Hence, for each prime $p$ this mechanism will work only for
bases that are greater than $p$, i.e. $b \geq p + 1$. This allows us
finding out the minimum value for which this trick applies:

$$
n_{min} = b \cdot p + p = (p + 1) p + p = (p + 2) p \approx p^2
$$

The last approximation is *increasingly true* as $p$ increases, because
the term 2 gets proportionally less significant. This tells us that for
any number $n$, it only makes sense to check this trick with primes up
to about $\sqrt{n}$, which is anyway what we would do anyway for testing
divisibility.

In the [Perl][] code, though, we try a few initial primes; if we have
success (which happens *a lot*) we exit early, otherwise... we go brute
force with `is_brazialian_bf`. To be honest, I need some more
requirements to get [ntheory][] into the lot and have a more proper
source of primes to use.

This was easy to transfom and generalize in [Raku][], thanks to the
`is-prime` built-in. The *brute force* part here is baked directly into
the `is-brazilian` that takes one single parameter.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @candidates = @args ?? @args !! (7, 6, 8);
   s{\,} = '' for @candidates;
   for @candidates -> $candidate {
      my $bb = is-brazilian($candidate);
      "$candidate -> {$bb ?? 1 !! 0} # $bb".put;
   }
}

multi sub is-brazilian (Int() $n where * > 3) {
   for 2 .. $n.sqrt -> $p {
      next unless $p.is-prime;
      next if $n % $p;
      my $d = ($n / $p - 1).Int;
      next if $d <= $p;
      return $d;
   }
   for (2 .. $n - 2).reverse -> $b {
      return $b if is-brazilian($n, $b);
   }
   return 0;
}

multi sub is-brazilian (Int:D $n is copy where * > 3, Int:D $b where * > 1) {
   my $digit = $n % $b;
   while $n > 0 {
      return 0 if $digit != $n % $b;
      $n = (($n - $digit) / $b).Int;
   }
   return 1;
}
```

I hope this is enough, because at this point I can only recommend that
you stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#157]: https://theweeklychallenge.org/blog/perl-weekly-challenge-157/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-157/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ntheory]: https://metacpan.org/pod/ntheory
