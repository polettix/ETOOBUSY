---
title: PWC168 - Home Prime
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-09 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#168][].
> Enjoy!

# The challenge

> You are given an integer greater than 1.
>
> Write a script to find the home prime of the given number.
>
> In number theory, the home prime HP(n) of an integer n greater than 1
> is the prime number obtained by repeatedly factoring the increasing
> concatenation of prime factors including repetitions.
>
> Further information can be found on [Wikipedia][] and [OEIS][].
>
> *Example*
>
> As given in the Wikipedia page,
>
>     HP(10) = 773, as
>     10 factors as 2×5 yielding HP10(1) = 25,
>     25 factors as 5×5 yielding HP10(2) = HP25(1) = 55,
>     55 = 5×11 implies HP10(3) = HP25(2) = HP55(1) = 511, and
>     511 = 7×73 gives HP10(4) = HP25(3) = HP55(2) = HP511(1) = 773,
>     a prime number.

# The questions

What's with all these primes? I tell you, our fine host is on to
something!

# The solution

This week I decided to go for the unusual path and somehow let [Perl][]
show off its muscles. So we're going *fully functional* with this
otherwise barely readable solution. 

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use ntheory qw< factor >;

my $n = shift // 10;
say home_prime($n);

sub home_prime {
   my $next = join '', factor($_[0]);
   return $next if $next eq $_[0];
   $_[0] = $next;
   goto &home_prime;
}
```

By the examples themselves, we know that a recursive function must work
fine. BUT we don't want to clutter our call stack, right? We need *tail
call optimization*, right? Well, I don't know if [Perl][] has it, in any
version, but I do know how to *simulate* it:

- arrange `@_` properly
- use `goto` (in one of its good incarnations inside the language).

So there you go, functional loops!

> Kudos to [DANAJ][] for saving our coordinate axes with the excpetional
> [ntheory][].

ON THE OTHER HAND, [Raku][] might one day have tail call optimization,
but we're not there yet apparently. So we'll go... fully iterative this
time, thanks to a `loop` function that expresses perfectly the fact that
we might go on and on for ages:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 1 = 10) { put home-prime($n) }

sub home-prime ($n is copy) {
   loop {
      my $m = factors($n).join('').Int;
      return $n if $n == $m;
      $n = $m;
   }
}

sub factors (Int $remainder is copy) {
   return 1 if $remainder <= 1;
   state @primes = 2, 3, 5, -> $n is copy {
      repeat { $n += 2 } until $n %% none @primes ... { $_ * $_ >= $n }
      $n;
   } ... *;
   gather for @primes -> $factor {
      if $factor * $factor > $remainder {
         take $remainder if $remainder > 1;
         last;
      }

      # How many times can we divide by this prime?
      while $remainder %% $factor {
         take $factor;
         last if ($remainder div= $factor) === 1;
      }
   }
}
```

The [`factors` function][factors] is by none other than [Tim Toady][]
himself! What a honor to linger on the shoulders of the giants!

Well, thanks everybody for making this challenge such effortless and a
pleasure to code!

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#168]: https://theweeklychallenge.org/blog/perl-weekly-challenge-168/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-168/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Wikipedia]: https://en.wikipedia.org/wiki/Home_prime
[OEIS]: https://oeis.org/A037274
[DANAJ]: https://metacpan.org/author/DANAJ
[ntheory]: https://metacpan.org/pod/ntheory
[factors]: https://examples.raku.org/categories/best-of-rosettacode/prime-decomposition.html
[Tim Toady]: http://www.wall.org/~larry/
