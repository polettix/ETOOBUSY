---
title: PWC223 - Count Primes
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-30 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#223][]. Enjoy!

# The challenge

*(Slightly redacted)*

> You are given a positive integer, `$n`.
>
> Write a script to find the total count of primes less than or equal to the given integer.
>
> **Example 1**
>
>     Input: $n = 10
>     Output: 4
>
>     Since there are 4 primes (2,3,5,7) less than or equal to 10.
>
> **Example 2**
>
>     Input: $n = 1
>     Output: 0
>
> **Example 3**
>
>     Input: $n = 20
>     Output: 8
>
>     Since there are 8 primes (2,3,5,7,11,13,17,19) less than or equal to 20.

# The questions

The challenge is clear, although in an interview I'd probably ask what
values of `$n` we should expect to see and whether there are constraints or
expectations about performance. This is because we might need to go for some
heavylifting with dedicated modules that can handle big numbers and naive
implementations of primality tests might not be ideal for larger numbers.

# The solution

In lack of additional hints about the input's range, we'll assume it's small
enough to not require any specific care and just solve the challenge for
small numbers.

[Raku][] first as usual for the first challenge. We do take advantage of the
included batteries here, by means of `.is-prime`:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int() $n where * > 0) { put count-primes($n) }
sub count-primes ($n) { (2 .. $n).grep({ .is-prime }).elems }
```

Moving on to [Perl][], we do assume small inputs and go for a quickly coded
primality test that is basically a toy:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
say count_primes(shift);
sub count_primes ($n) { return scalar grep { is_prime($_) } 2 .. $n }
sub is_prime ($n) { for (2 .. sqrt $n) { return unless $n % $_ } return 1 }
```

In a more serious setting, I'd probably go for [`prime_count`][pc] in
[Math::Prime::Util][] instead.

Cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#223]: https://theweeklychallenge.org/blog/perl-weekly-challenge-223/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-223/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[pc]: https://metacpan.org/pod/Math::Prime::Util#prime_count
[Math::Prime::Util]: https://metacpan.org/pod/Math::Prime::Util
