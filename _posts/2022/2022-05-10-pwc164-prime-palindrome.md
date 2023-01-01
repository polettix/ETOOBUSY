---
title: PWC164 - Prime Palindrome
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-10 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#164][]. Enjoy!

# The challenge

> Write a script to find all prime numbers less than 1000, which are
> also palindromes in base 10. Palindromic numbers are numbers whose
> digits are the same in reverse. For example, `313` is a palindromic
> prime, but `337` is not, even though `733` (337 reversed) is also
> prime.

# The questions

Is 1000 a hard and fast limit? What else would it make sense to
consider?


# The solution

The question is not much about lazyness but about how to find out
candidate primes. With a limit of 1000, it makes sense to be brutal and
filter out primes *and* palindromes out of the first 1000 candidates -
well, 999 not considering 1, which might be shaved a bit more by
removing 1000 (even), 999 (multiple of 3), then pretty much down to 989
(not palindrome).

```raku
#!/usr/bin/env raku
use v6;

sub is-palindrome (Int $n) { $n.Str eq $n.Str.flip }

sub MAIN (Int $max = 989) {
   (2 .. $max).grep({.is-prime && is-palindrome($_)}).put;
}
```

The limited upper limit is even more interesting for the [Perl][]
alternative, because `is_prime` is not a built-in and we have to either
download and `use` it from [ntheory][], or code it ourselves. This
latter approach makes sense for this low upper limit.


```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $max = shift // 989;
say join ' ', grep {is_prime($_) && is_palindrome($_)} 2 .. $max;

sub is_palindrome ($n) { $n eq reverse $n }

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

Both programs give the same output, so I guess they're bugged in the
same way... or correct.

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#164]: https://theweeklychallenge.org/blog/perl-weekly-challenge-164/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-164/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ntheory]: https://metacpan.org/pod/ntheory
