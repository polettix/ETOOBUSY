---
title: PWC172 - Prime Partition
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-06 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#172][]. Enjoy!

# The challenge

> You are given two positive integers, `$m` and `$n`.
>
> Write a script to find out the `Prime Partition` of the given number.
> No duplicates allowed.
>
> For example,
>
>     Input: $m = 18, $n = 2
>     Output: 5, 13 or 7, 11
>
>     Input: $m = 19, $n = 3
>     Output: 3, 5, 11

# The questions

No questions asked.

I mean, there would be *so many questions* that they don't make sense. I
read this challenge as *OK folks, here's something to play with, have
fun and don't annoy the neighbors!*

Sooooo...

- I'll assume that $n$ is a target positive integer that we have to
  partition into the sum of distinct primes;
- I'll assume that $m$ represents the number of primes that we have to
  use for this partition (the examples seem to support this);
- I'll return a list (or an array) of $m$ primes or the empty list, in
  case the partition is not feasible;
- I'll assume that no optimization is necessary and that the most simple
  solution is OK.

# The solution

The plan is to brush out the corner cases and use this:

- find all primes between $2$ and $n - 2$ and put them in an array;
- try out combinations of $m$ elements from the array:
    - return the combination if its sum equals $n$;
    - continue otherwise.

[Raku][] goes first and provides batteries [for][multi] [most][is-prime]
[moving][combinations] [parts][sum], leading to a very compact solution:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($n = 18, $m = 2) { say prime-partition($n, $m) }

multi sub prime-partition ($n where *.is-prime, 1) { [ $n ] }
multi sub prime-partition ($n, 1) { [] }
multi sub prime-partition ($n, $m) {
   for (2 .. $n - 2).grep({.is-prime}).combinations($m) -> $c {
      return $c.Array if $c.sum == $n;
   }
   return [];
}
```

The [multi][] subroutine allow us to cope with the case where $m = 1$,
which boils down to checking whether $n$ is prime or not. Otherwise we
apply the algorithm laid out at the beginning of this section.

On the [Perl][] side there's less out of the box, but with a little help
here and there (e.g. from [Combinations iterator][]) we get up to speed
in little time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

my $n = shift // 18;
my $m = shift // 2;
say simple_stringify_array(prime_partition($n, $m));

sub simple_stringify_array (@a) { return '(' . join(', ', @a), ')' }

sub prime_partition ($n, $m) {
   if ($m == 1) { return is_prime($n) ? $n : () }
   my $cit = combinations_iterator($m, primes_within(2, $n - 2));
   while (my ($c) = $cit->()) {
      return $c->@* if $n == sum $c->@*;
   }
   return;
}

sub combinations_iterator ($k, @items) {
   my @indexes = (0 .. ($k - 1));
   my $n = @items;
   return sub {
      return unless @indexes;
      my (@combination, @remaining);
      my $j = 0;
      for my $i (0 .. ($n - 1)) {
         if ($j < $k && $i == $indexes[$j]) {
            push @combination, $items[$i];
            ++$j;
         }
         else {
            push @remaining, $items[$i];
         }
      }
      for my $incc (reverse(-1, 0 .. ($k - 1))) {
         if ($incc < 0) {
            @indexes = (); # finished!
         }
         elsif ((my $v = $indexes[$incc]) < $incc - $k + $n) {
            $indexes[$_] = ++$v for $incc .. ($k - 1);
            last;
         }
      }
      return (\@combination, \@remaining);
   }
}

sub primes_within ($min, $max) {
   my @retval = $min < 3 ? 2 : ();
   $min++ unless $min % 2;
   while ($min <= $max) {
      push @retval, $min if is_prime($min);
      $min += 2;
   }
   return @retval;
}

sub is_prime { # https://en.wikipedia.org/wiki/Primality_test
   return if $_[0] < 2;
   return 1 if $_[0] <= 3;
   return unless ($_[0] % 2) && ($_[0] % 3);
   for (my $i = 6 - 1; $i * $i <= $_[0]; $i += 6) {
      return unless ($_[0] % $i) && ($_[0] % ($i + 2));
   }
   return 1;
}
```

Well... stay safe people!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#172]: https://theweeklychallenge.org/blog/perl-weekly-challenge-172/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-172/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Combinations iterator]: {{ '/2021/04/24/combinations-iterator/' | prepend: site.baseurl }}
[multi]: https://docs.raku.org/language/functions#index-entry-declarator_multi-Multi-dispatch
[is-prime]: https://docs.raku.org/routine/is-prime
[combinations]: https://docs.raku.org/routine/combinations
[sum]: https://docs.raku.org/routine/sum
