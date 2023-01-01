---
title: PWC154 - Padovan Prime
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#154][].
> Enjoy!

# The challenge

> A `Padovan Prime` is a `Padovan Number` that’s also prime.
>
> In number theory, the Padovan sequence is the sequence of integers
> P(n) defined by the initial values.
>
>     P(0) = P(1) = P(2) = 1
>
> and then followed by
>
>     P(n) = P(n-2) + P(n-3)
>
> First few `Padovan Numbers` are as below:
>
>     1, 1, 1, 2, 2, 3, 4, 5, 7, 9, 12, 16, 21, 28, 37, ...
>
> Write a script to compute first `10 distinct Padovan Primes`.
>
> **Expected Output**
>
>     2, 3, 5, 7, 37, 151, 3329, 23833, 13091204281, 3093215881333057

# The questions

Well, I have none.

Actually, as an Italian I was wondering if *Padovan* had anything to do
with [Padova][], because its inhabitants are called... *Padovani*. But
no, it's after [Richard Padovan][Padovan], whose surname *might* be
connected to [Padova][] anyway.

# The solution

This is the perfect challenge to address with iterators, so why not?

Here we chain a few:

- the starting iterator gives out the [Padovan sequence][];
- then we filter out duplicates, in `uniq` style (i.e. assuming that
  they are sorted, which is the case for Padovan numbers);
- then we filter out non-primes, with a `grep` variant that is good for
  iterators.

I hope I did a good use of my [Higher Order Perl][] memory!

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $n = shift || 10;
my $it = grep_it(\&is_prime, uniq(padovan_number_iterator()));
say join ', ', map { $it->() } 1 .. $n;

sub padovan_number_iterator {
   my ($Pa, $Pb, $Pc) = (1) x 3;
   return sub {
      (my $retval, $Pa, $Pb, $Pc) = ($Pa, $Pb, $Pc, $Pa + $Pb);
      return $retval;
   };
}

sub uniq ($it) {
   my $previous = $it->();
   return sub {
      while ('necessary') {
         my $current = $it->();
         next if $current == $previous;
         (my $retval, $previous) = ($previous, $current);
         return $retval;
      }
   }
}

sub grep_it ($condition, $it) {
   return sub {
      while ('necessary') {
         my $x = $it->();
         return $x if $condition->($x);
      }
   }
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

The test for primality is basic and recycled from a past challenge,
although it's actually a rip-off of what's described in the wikipedia
page credited in the comment. I also suspect it's the Achille's heel for
making this program a bit on the slow side.

The translation into [Raku][] was particularly simple, with just a few
syntactic changes and using the built-in `is-prime` instad of a custom
implementation.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n = 10) {
   my &it = grep_it(&is-prime, uniq(padovan-number-iterator()));
   (^$n).map({&it()}).join(', ').put;
}

sub padovan-number-iterator () {
   my ($Pa, $Pb, $Pc) = 1 xx 3;
   return sub {
      (my $retval, $Pa, $Pb, $Pc) = $Pa, $Pb, $Pc, $Pa + $Pb;
      return $retval;
   };
}

sub uniq (&it) {
   my $previous = &it();
   return sub {
      loop {
         my $current = &it();
         next if $current == $previous;
         (my $retval, $previous) = ($previous, $current);
         return $retval;
      }
   }
}

sub grep_it (&condition, &it) {
   return sub {
      loop {
         my $x = &it();
         return $x if &condition($x);
      }
   }
}
```

I initially considered going the object oriented way, but as I said
earlier this seems the perfect fit for iterators and [Raku][] supports
this style just as well.

This [Raku][] implementation is faster than the [Perl][] one, I *guess*
because of the primality test:

```
$ time perl perl/ch-2.pl 
2, 3, 5, 7, 37, 151, 3329, 23833, 13091204281, 3093215881333057

real	0m2.058s
user	0m2.028s
sys	0m0.012s

$ time raku raku/ch-2.raku
2, 3, 5, 7, 37, 151, 3329, 23833, 13091204281, 3093215881333057

real	0m0.512s
user	0m0.660s
sys	0m0.116s
```

This will be left as a gut feeling though, I'm too lazy to setup
profiling for the two programs and compare them 😅

OK, OK.

No need to profile anything.

Let's summon [Math::Prime::Util][]'s [is_prime][] as a drop-in
replacement:

```
$ time perl ch-2-alt.pl 
2, 3, 5, 7, 37, 151, 3329, 23833, 13091204281, 3093215881333057

real	0m0.061s
user	0m0.040s
sys	0m0.016s
```

Thanks [Dana Jacobsen][DANAJ] for letting me be more... *scientific*
while still being *lazy* 😅 

Stay safe everyone!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#154]: https://theweeklychallenge.org/blog/perl-weekly-challenge-154/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-154/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Padova]: https://en.wikipedia.org/wiki/Padua
[Padovan]: https://en.wikipedia.org/wiki/Richard_Padovan
[Higher Order Perl]: https://hop.perl.plover.com/
[Padovan sequence]: https://en.wikipedia.org/wiki/Padovan_sequence
[Math::Prime::Util]: https://metacpan.org/pod/Math::Prime::Util
[is_prime]: https://metacpan.org/pod/Math::Prime::Util#is_prime
[DANAJ]: https://metacpan.org/author/DANAJ
