---
title: PWC158 - First Series Cuban Primes
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-30 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#158][].
> Enjoy!

# The challenge

> Write a script to compute first series `Cuban Primes <= 1000`. Please
> refer [wikipedia page][wp] for more informations.
>
> **Output**
>
>     7, 19, 37, 61, 127, 271, 331, 397, 547, 631, 919.


# The questions

Where's the trick? I feel I'm missing something important here.


# The solution

I could think of two ways to address this challenge:

- go through prime numbers up to 1000 and find out those that are also
  of the form $3y^2 + 3y + 1$, **OR**
- generate all numbers of the form $3y^2 + 3y + 1$ up to 1000, and find
  out those that are also primes.

Eventually I settled for the latter, because generating the numbers is
easier than finding the integer solutions to the quadratic eqution, and
the test for primality is readily available in [ntheory][].

So let's start with [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";
use ntheory 'is_prime';

my $M = shift // 1000;
my @cubans;
my $y = 1;
while ((my $p = 3 * $y * ($y + 1) + 1) <= $M) {
   push @cubans, $p if is_prime($p);
   ++$y;
}
say join(', ', @cubans), '.';
```

I'm not entirely happy with this solution, it feels... *clunky*. Like
collecting the stuff in array `@cubans`, I don't know.

The [Raku][] counterpart allows me to use one of my favorite constructs,
i.e. `gather`/`take`:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $M = 1000) {
   put gather {
      my $y = 1;
      while (my $p = 3 * $y * ($y + 1) + 1) <= $M {
         take $p if $p.is-prime;
         ++$y;
      }
   }.join(', '), '.';
}
```

I don't know why I'm so fond of `gather`/`take`, it just feels so
natural. Before you get spoiled too, though, keep in mind that I'be been
advised *against* it because of performance issues. This is one reson
why I like these challenges, I can play with the language without being
hit by it! 😅

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#158]: https://theweeklychallenge.org/blog/perl-weekly-challenge-158/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-158/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wp]: https://en.wikipedia.org/wiki/Cuban_prime
[ntheory]: https://metacpan.org/pod/Math::Prime::Util
