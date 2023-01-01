---
title: PWC174 - Disarium Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#174][]. Enjoy!

# The challenge

> Write a script to generate first `19 Disarium Numbers`.
>
>> A disarium number is an integer where the sum of each digit raised to
>> the power of its position in the number, is equal to the number.
>
> For example,
>
>     518 is a disarium number as (5 ** 1) + (1 ** 2) + (8 ** 3) => 5 + 1 + 512 => 518

# The questions

The only nitpicking would be about the base we should consider for doing
the calculation, but I *guess* base-10 is safe to assume nowadays.

Then, of course, there might be the *why 19*? Probably 18 is too little
of a challenge, and 20 is way too much.

# The solution

The nice thing about this challenge is that there is a *finite* number
of Disarium Numbers but we're not asked for *all of them*. Most of all:
19 out of 20. This is because the 20th element is... *quite big*.

It's not difficult to *see* that there must be a finite number of these
numbers: just think that every time we add a new digit, our number grows
a factor of 10 but the *Disarium Sum* (if you know what I mean) can
*only* grow with the sum of $9^k$, where $k$ is the number of digits.
It's a sum against a multiplication.

So we can calculate the *surely not beyond this* number that is allowed
with $k$ digits as:

$$
S(k) = \sum_{i = 1}^{k} 9^i
$$

This allows us to also calculate the number of digits of this *surely
not beyond this* number as:

$$
D(k) = \lceil log_{10}(S(k)) \rceil
$$

As long as $D(k)$ is equal to $k$, *theoretically* we can have a
solution. But when it drops below, we cannot possibly have a solution
any more and things will never get better:

$$
D(1) = 1 \\
D(2) = 2 \\
... \\
D(21) = 21 \\
D(22) = 22 \\
D(23) = 22 < 23
$$

So, Disarium Numbers cannot possibly have 23 digits or more. It turns
out that the biggest element of the family has 20 digits.

As I said, [Disarium Numbers: brute force won't cut it][]. Well, for my
definition of *brute force*, at least. I started coding in [Raku][] but
it was taking a bit too much time that I stopped it - it's all in the
other post.

It turns out that brute force *can* actually cut it in about 8/9 seconds
in my machine with [Perl][]:

```
my $n = shift // 19;
my @disariums = disariums($n, \&is_disarium_espresso);
say join ', ', @disariums;

my $n = shift // 19;
my @disariums = disariums($n, \&is_disarium_espresso);
say join ', ', @disariums;

sub disariums ($n, $tester) {
   my @disariums;
   my $candidate = 0;
   while (@disariums < $n) {
      push @disariums, $candidate if $tester->($candidate);
      ++$candidate;
   }
   return @disariums;
}
sub is_disarium_espresso ($n) {
   my $exp = 0;
   $n == sum map { $_ ** ++$exp } split m{}mxs, $n;
}
```

So well, OK, I was wrong*ish* for the challenge at stake (find 19
members and ignore the 20th), but way to go for finding them all.

Anyway, I did the [Raku][] solution first. adopting a partially
optimized algorithm that can solve the challenge in slightly more than
one second and can theoretically find the 20th member too in about... 3
months or so 🙄

BUT: the algorihtm is highly parallelizable, so with the right
adaptations and the right machine(s) it can be probably brought
down to hours/minutes even in [Raku][] (which is `-Ofun` as of today).

It's not for the faint of heart and involves starting from the last
digit and going leftwards, finding the maximum as above, the minimum in
a similar way and recurse if their difference is too big for iteration.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 0 = 19) {
   my @disarium-numbers;
   my $length = 0;
   my $last = time;
   while @disarium-numbers < $n {
      ++$length;
      put "checking length $length...";
      @disarium-numbers.push: disariums-long-suffix($length).Slip;
      my $now = time;
      put "   {$now - $last}s {@disarium-numbers.elems} found so far ({@disarium-numbers.join(', ')})";
      $last = $now;
   }
   say @disarium-numbers;
   exit 0;
}

sub disarium-calc ($n) { $n.comb.kv.map(-> $x, $y { $y ** ($x + 1) }).sum }

multi sub disariums-long-suffix (1) { return [0 .. 9] }

multi sub disariums-long-suffix ($length, $suffix = '') {
   my @suffix = $suffix.comb.reverse;
   my $slen = $suffix.chars;
   my $residual = $length - $slen;

   my $baseline = 0; # only from suffix
   my $exp = $length;
   for @suffix -> $base { $baseline += $base ** $exp-- }
   my $max_increment = 0;
   while $exp > 0 { $max_increment += 9 ** $exp-- } # optimize probably?

   my $min_baseline = $baseline + 1; # 1000...NNN
   $min_baseline = (('1' x $residual) ~ $suffix).Int
      if $min_baseline.chars < $length;
   my $min_baseline_prefix = $min_baseline.substr(0, $residual).Int;
   my $min_baseline_suffix = $min_baseline.substr(*-$slen, $slen).Int;
   ++$min_baseline_prefix if $suffix < $min_baseline_suffix;
   $min_baseline = ($min_baseline_prefix ~ $suffix).Int;

   my $max_baseline = $baseline + $max_increment;
   my $n_digits = $max_baseline.chars;
   return [] if $n_digits < $length;
   my $max_baseline_prefix = $max_baseline.substr(0, $residual).Int;
   my $max_baseline_suffix = $max_baseline.substr(*-$slen, $slen).Int;
   $max_baseline_prefix-- if $suffix > $max_baseline_suffix;
   $max_baseline = ($max_baseline_prefix ~ $suffix).Int;

   my @collected;
   my $delta = $max_baseline_prefix - $min_baseline_prefix;
   if $delta > 10 {
      for (0 .. 9).reverse -> $digit {
         my $new_suffix = $digit ~ $suffix;
         my @children = disariums-long-suffix($length, $new_suffix);
         @collected.push: |@children;
      }
   }
   elsif $delta >= 0 {
      for $min_baseline_prefix .. $max_baseline_prefix -> $prefix {
         my $candidate = ($prefix ~ $suffix).Int;
         my $check = $baseline + disarium-calc($prefix);
         @collected.push: $candidate if $candidate == $check;
      }
   }
   return @collected;
}
```

The trivial case for 1-digit numbers is taken care by the `multi`
mechanism. We then interate over the lenghts to find all elements of
that length, stopping when we have enough numbers. For the challenge,
this means stopping at 7 digits which is fair.

I know the implementation sucks and there's no comment to understand
what's going on, but I'll call this *a week* and move on.

On the [Perl][] side, I toyed with the idea of optimizing the check for
disarium numbers, pre-computing the exponentiation inside a AoA and
inside a linear array, so I ended up with this:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';
use Benchmark 'timethese';

$|++;
my $n = shift // 19;
my @disariums = disariums($n, \&is_disarium_espresso);
say join ', ', @disariums;

timethese(
   5,
   {
      espresso  => sub { disariums($n, \&is_disarium_espresso)  },
      precached => sub { disariums($n, \&is_disarium_precached) },
      llcached  => sub { disariums($n, \&is_disarium_llcached)  },
   },
);

sub disariums ($n, $tester) {
   my @disariums;
   my $candidate = 0;
   while (@disariums < $n) {
      push @disariums, $candidate if $tester->($candidate);
      ++$candidate;
   }
   return @disariums;
}

sub is_disarium_precached ($n) {
   state $pow = [];
   while ((my $k = $pow->@*) < length($n)) {
      ++$k;
      push $pow->@*, [ 0, 1, map { $_ ** $k } 2 .. 9 ];
   }
   my $exp = 0;
   $n == sum map { $pow->[$exp++][$_] } split m{}mxs, $n;
}

sub is_disarium_llcached ($n) {
   state $pow  = [];
   state $kpow = 0;
   while ($kpow < length($n)) {
      ++$kpow;
      push $pow->@*, 0, 1, map { $_ ** $kpow } 2 .. 9;
   }
   my $exp = 0;
   $n == sum map { $pow->[$_ + 10 * $exp++] } split m{}mxs, $n;
}

sub is_disarium_espresso ($n) {
   my $exp = 0;
   $n == sum map { $_ ** ++$exp } split m{}mxs, $n;
}
```

My gut feeling was that the linear cache (`llcached`) would score better
than the AoA cache (`precached`), which would be better than the basic
approach of doing all exponentiations all the times (`espresso`).

I got back yet another demonstration that benchmarks are a thing and my
gut feelings are *disastrously* not:

```
$ time perl perl/ch-1.pl 19
0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 89, 135, 175, 518, 598, 1306, 1676, 2427, 2646798
Benchmark: timing 5 iterations of espresso, llcached, precached...
  espresso: 42 wallclock secs (42.21 usr +  0.05 sys = 42.26 CPU) @  0.12/s (n=5)
  llcached: 48 wallclock secs (46.75 usr +  0.09 sys = 46.84 CPU) @  0.11/s (n=5)
 precached: 47 wallclock secs (47.10 usr +  0.06 sys = 47.16 CPU) @  0.11/s (n=5)
```

Go figure.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#174]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Disarium Numbers: brute force won't cut it]: {{ '/2022/07/20/disarium-brute-force/' | prepend: site.baseurl }}
