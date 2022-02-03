---
title: PWC150 - Square-free Integer
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#150][].
> Enjoy!

# The challenge

> Write a script to generate all square-free integers <= 500.
>
>> In mathematics, a square-free integer (or squarefree integer) is an
>> integer which is divisible by no perfect square other than 1. That
>> is, its prime factorization has exactly one factor for each prime
>> that appears in it. For example, 10 = 2 ⋅ 5 is square-free, but 18 =
>> 2 ⋅ 3 ⋅ 3 is not, because 18 is divisible by 9 = 3**2.
>
> **Example**
>
>     The smallest positive square-free integers are
>         1, 2, 3, 5, 6, 7, 10, 11, 13, 14, 15, 17, 19, 21, 22, 23, 26, 29, 30, ...

# The questions

As it often happens, I'm nitpicking on the details about the domain of
our investigation: should we consider negative values? I guess not by
the examples...


# The solution

We will start with [Perl][] first:

```perl
sub is_square_free ($N) {
   return unless $N % 4;
   my $divisor = 3;
   while ($N > $divisor) {
      if ($N % $divisor == 0) {
         $N /= $divisor;
         return unless $N % $divisor;
      }
      $divisor += 2; # go through odd candidates only
   }
   return 1;
}
```

The goal is not to find all divisors, so... we don't find them and we
take every possible chance to bail out with a *false* value. It can
happen in two cases:

- if the number is a multiple of 4 because... 4 is a square, you know;
- otherwise, if the number happens to have the same divisor twice.

Why the explicit check on 4? Well, in this way we can get the prime
number 2 out of the way, and iterate only through odd divisors, starting
at 3. Actually, we might start at 7 because the first positive integer
that is neither a multiple of 4 nor square-free is 9. Whatever.

I like the [Raku][] translation better because it allows us to use the
*is-divisible-by* operator `%%`, instead of its "contrary" (sort of)
*remainder-in-the-division-by* `%`:

```raku
sub is-square-free ($N is copy) {
   return False if $N %% 4;
   my $divisor = 3;
   while $N > $divisor {
      if $N %% $divisor == 0 {
         $N = ($N / $divisor).Int;
         return False if $N %% $divisor;
      }
      $divisor += 2; # go through odd candidates only
   }
   return True;
}
```

This makes the whole thing more readable, but at the end of the day it
was pretty readable also to begin with. I have a little itch in the fact
that the division between the two integers gives out a rational even
when the result is an integer... but whatever.

I also like the availability of proper boolean constants, again I think
it adds to the readability.

The [Raku][] version also allowed me to play a bit with `multi`
subroutines, in the `MAIN`:

```raku
multi sub MAIN (Int $limit = 500) {
   my @list = (1 .. $limit).grep({is-square-free($_)});
   while @list {
      @list.splice(0, 20).join(', ').print;
      put @list ?? ',' !! '';
   }
}

multi sub MAIN (*@args) {
   put $_, ' ', (is-square-free($_) ?? 'is' !! 'is not'), ' square free'
      for @args;
}
```

I'm providing three different ways to call the program:

- with no parameter, the limit is set to 500 like the challenge asks;
- with one single parameter, the limit is set by the parameter itself;
- with multiple parameters, each is checked for being square-free or
  not.

The `multi` helps distinguishing the first two cases from the last,
which is *functional*ly nifty.

OK, I didn't include the full programs for both languages... but [you
know where to find them][pwc-repo] should you be curious.

Stay safe and have fun!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#150]: https://theweeklychallenge.org/blog/perl-weekly-challenge-150/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-150/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[pwc-repo]: https://github.com/manwar/perlweeklychallenge-club
