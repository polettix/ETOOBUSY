---
title: PWC143 - Stealthy Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-16 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#143][].
> Enjoy!

# The challenge

> You are given a positive number, `$n`.
>
> Write a script to find out if the given number is `Stealthy Number`.
>
>> A positive integer N is stealthy, if there exist positive integers
>> a, b, c, d such that a * b = c * d = N and a + b = c + d + 1.
>
> **Example 1**
>
>     Input: $n = 36
>     Output: 1
>     
>     Since 36 = 4 (a) * 9 (b) = 6 (c) * 6 (d) and 4 (a) + 9 (b) = 6 (c) + 6 (d) + 1.
>
> **Example 2**
>
>     Input: $n = 12
>     Output: 1
>     
>     Since 2 * 6 = 3 * 4 and 2 + 6 = 3 + 4 + 1
>
> **Example 3**
>
>     Input: $n = 6
>     Output: 0
>     
>     Since 2 * 3 = 1 * 6 but 2 + 3 != 1 + 6 + 1


# The questions

I only have one meta-questions about this challenge: *what's the matter
with all the divisors of integer numbers*?

I suspect [manwar][] is manipulating us like pupputs to help solving the
[Riemann hypothesis][]. Whatever, happy to help!

# The solution

The key insights here were:

- all pairs of divisors come in pairs... by definition. Jokes apart, as
  soon as we find a divisor, we also have its counterpart to make the
  pair.
- We'll have to compare all pairs against each other, possibly in an
  efficient way. This rings like *hash*, *set*, ... anything that can
  check for *being there* efficiently.
- for each pair of pairs we will have to do two checks, or check an
  absolute value. In our case, using a hash-like data structure will
  mean either tracking the sums themselves, or their `+1` or `-1`
  versions.

I'll start with [Perl][] this time.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub is_stealthy ($n) {
   my %match;
   for my $k (1 .. sqrt($n)) {
      next if $n % $k;
      my $sum = $k + $n / $k;
      return 1 if $match{$sum - 1} || $match{$sum + 1};
      $match{$sum} = 1;
   }
   return 0;
}

my @inputs = @ARGV ? @ARGV : qw< 36 12 6 >;
say "$_ -> " . is_stealthy($_) for @inputs;
```

We're using a plain ol' hash here. At each iteration, we check if `$sum + 1`
or `$sum - 1` are in, because this is how we can do the required
check! This also allows us saving only `$sum` for future attempts.

> I surprised myself in writing this:
>
>     return 1 if %match{...
>
> Wow, [Raku][] is getting on me.

So, let's move to [Raku][] then:

```raku
#!/usr/bin/env raku
use v6;
subset PosInt of Int where * > 0;

sub is-stealthy (PosInt:D $n) {
   my $match = SetHash.new;
   for 1 .. $n.sqrt.Int -> $k {
      next unless $n %% $k;
      my Int() $sum = $k + $n / $k;
      return 1 if $match (&) ($sum - 1, $sum + 1);
      $match.set: $sum;
   }
   return 0;
}

sub MAIN (*@args) {
   @args = 36, 12, 6 unless @args.elems;
   "$_ -> {is-stealthy($_)}".put for @args;
}
```

It's pretty much the same thing, using a [SetHash][] this time for
showing off a bit and also try to be a bit more *readable* (or, maybe,
*expressive*).

I guess this is it for this challenge... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#143]: https://theweeklychallenge.org/blog/perl-weekly-challenge-143/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-143/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Riemann hypothesis]: https://en.wikipedia.org/wiki/Riemann_hypothesis
[manwar]: http://www.manwar.org/
[SetHash]: https://docs.raku.org/type/SetHash
