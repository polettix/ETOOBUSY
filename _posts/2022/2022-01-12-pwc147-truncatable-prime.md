---
title: PWC147 - Truncatable Prime
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-01-12 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#147][]. Enjoy!

# The challenge

> Write a script to generate first 20 left-truncatable prime numbers in
> base 10.
>
>> In number theory, a left-truncatable prime is a prime number which,
>> in a given base, contains no 0, and if the leading `left` digit is
>> successively removed, then all resulting numbers are primes.
>
> **Example**
>
>     9137 is one such left-truncatable prime since 9137, 137, 37 and 7
>     are all prime numbers.

# The questions

I have two questions:

1. are single-digit prime numbers considered left-truncatable? I would
   say *no*, because there is no "resulting" number after chopping off
   the first digit. Anyway, my first intuition about what $0!$ should be
   failed me, so who knows? This will be my working assumption, though.

2. why stop *so low* at 20? We're not even reaching the example!

While we're at it, a small personal reflection too.

I enjoy these challenges, in their unique shape of being sometimes quite
vague and relying heavily on examples. I think our fine host is a fox
disguised as a lamb, throwing us puzzles that sometimes give us that
distinct *wtf?!?* moment that often arises when we're dealing with
customers. It's a stimulus to go beyond, ask questions, gather more
requirements, try to see things from different perspectives, make
assumptions... in summary, architecting a solution.

Thanks [manwar][].

# The solution

OK, let's get this started. I initially thought about a *constructive*
approach, which ended up with a good amount of code and being
sufficiently complicated to leave me with a question... *is it even
correct*?

I mean, I *know* that the constructive approach (more on this in a
minute, promised!), but is my implementation right? No clue.

So I also implemented a dumber, brute-force *exclusive* approach based
on iterating over all odd values and filtering stuff out if the required
condition does not apply. As a comparison. As a test. As a reference.

You know what? In the end, the original constructive approach was
correct since the beginning, while the "simpler" exclusive approach had
a bug!

Anyway, I thought of baking the choice between them in the code:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Int:D $n = 20, :$exclusive = False) {
   $exclusive ?? exclusive($n) !! constructive($n);
}
```

Let's start with the constructive approach. We're aiming for a
`nth-left-truncatable($n)` function that will give us the *n-th* number
that applies, so we just have to print all values from the first to the
twentieth:

```raku
sub constructive ($n) { put nth-left-truncatable($_) for 1 .. $n }
```

As a matter of fact, it's the underlying function that is
*constructive*. The main insight here is that, for a number to be
left-truncatable, the left truncation must either be a single-digit
prime number, or it must be left-truncatable itself.

Hence, it's easy to find new *candidates* for left-truncatable numbers:
just start from the ones you have and try adding all possible digits
from 1 to 9 in front of them. If we end up with a prime... it's also
left-truncatable.

```raku
sub nth-left-truncatable ($nth) {
   state @cache = (10..99).grep({ .is-prime && .substr(1, 1).is-prime });
   state $prefix = 1;
   state $first-id = 0;
   state $next-first-id = @cache.elems;
   state $id = $first-id;
   while @cache < $nth { # find moar!
      my $candidate = ($prefix ~ @cache[$id++]).Int;
      @cache.push($candidate) if $candidate.is-prime;
      if $candidate.chars == @cache[$id].chars { # toppled over!
         if $prefix < 9 {
            ++$prefix;
         }
         else {
            $prefix = 1;
            ($first-id, $next-first-id) = ($next-first-id, $id);
         }
         $id = $first-id; # just reset the cursor
      }
   }
   return @cache[$nth - 1];
}
```

The implementation aims at giving something similar to a lazy thing. If
we already have what we need in the `@cache`... well, it's a good day!
Let's return it and go take an ice cream. Well, if you're in Australia,
anyway, otherwise a hot chocolate will do for me, thanks.

Otherwise, we go looking for more lef-truncatable numbers until we have
enough to cover the request. To do so, then, we keep some `state`
variables so that we remember where we stopped in our previous search
and we can restart from there.

The `@cache` is pre-warmed with all the two-digits left-truncatable
numbers. This is necessary because we're excluding single-digit primes
from the lot, so we use the two-digits ones as a starting point.

OK, time for the *exclusive* approach. Here we have a
`is-left-truncatable($n)` test function, which tells us whether a given
input `$n` is indeed left-truncatable or just something else. This is
used to print values as we find them, until we hit the limit:

```raku
sub exclusive (Int:D $n is copy = 20) {
   my $i = 9;
   while $n > 0 {
      next unless is-left-truncatable($i = $i + 2);
      $i.put;
      --$n;
   }
}
```

The implementation actually uses the same insight as before: the
characteristic of being left-truncatable is inherently recursive, so why
not?

```raku
sub is-left-truncatable ($n) {
   return False if $n < 10 || $n ~~ /0/;
   return False unless $n.is-prime;
   state %cache;
   if %cache{$n}:!exists {
      my $truncated = $n.substr(1);
      return $truncated.is-prime if $truncated < 10;
      %cache{$n} = is-left-truncatable($truncated);
   }
   return %cache{$n};
}
```

Just as we're at it, I decided to throw some `%cache` just because
*memoization* is so cool. Totally overkill and unneeded in this case,
isn't overengineering so funny?!?

For the [Perl][] counterpart I decided to go only with the constructive
alternative. At the end of the day, it's the one I personally like more,
and I already had plenty of references to compare to.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say nth_left_truncatable($_) for 1 .. shift // 20;

sub nth_left_truncatable ($nth) {
   state $cache = [ grep { is_prime($_) && is_prime(substr $_, 1) } 10 .. 99 ];
   state $prefix = 1;
   state $first_id = 0;
   state $next_first_id = $cache->@*;
   state $id = $first_id;
   while ($cache->@* < $nth) {
      my $candidate = $prefix . $cache->[$id++];
      push $cache->@*, $candidate if is_prime($candidate);
      if (length($candidate) == length($cache->[$id])) { # toppled over!
         if ($prefix < 9) {
            ++$prefix;
         }
         else {
            $prefix = 1;
            ($first_id, $next_first_id) = ($next_first_id, $id);
         }
         $id = $first_id; # just reset the cursor
      }
   }
   return $cache->[$nth - 1];
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

Alas, we lack a primality test in the language here, so we have to code
one. This is [taken from Wikipedia][], there's probably better stuff
around but this does the job in decent time for our purposes.

OK, enough for this post... stay safe everybody!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#147]: https://theweeklychallenge.org/blog/perl-weekly-challenge-147/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-147/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[taken from Wikipedia]: https://en.wikipedia.org/wiki/Primality_test
