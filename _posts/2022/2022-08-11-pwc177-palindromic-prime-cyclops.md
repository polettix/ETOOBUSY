---
title: PWC177 - Palindromic Prime Cyclops
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-11 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#177][].
> Enjoy!

# The challenge

> Write a script to generate `first 20 Palindromic Prime Cyclops
> Numbers`.
>
>> A cyclops number is a number with an odd number of digits that has a
>> zero in the center only.
>
> **Output**
>
>     101, 16061, 31013, 35053, 38083, 73037, 74047, 91019, 94049,
>     1120211, 1150511, 1160611, 1180811, 1190911, 1250521, 1280821,
>     1360631, 1390931, 1490941, 1520251

# The questions

Why, oh why didn't I read *has a zero in the center **only*** in the
first place?!?

# The solution

This is a candidate for *brute forcing*, but also with choosing the
right amount of *brutality*.

In this case, we can leverage the structure of the valid solutions,
which is something like this:

$$
d_0 d_1 .. d_n 0 d_n .. d_1 d_0
$$

The part before the `0` is an integer, right? Let's call it `$n`. We
only need to try different values of `$n` to tell different valid
candidates.

We can do better, actually:

- There can be no `0`, so we can turn every `0` into a `1`;
- we can also skip all values of `$n` with a leading even digit $d_0$,
  as it's going to produce an even cyclop number (which cannot be
  prime).

So, let's summon this *gentle brute*:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use ntheory 'is_prime';

my $n = shift // 20;
my $it = cyclop_prime_factory();
say $it->() for 1 .. $n;

sub cyclop_prime_factory {
   my $n = 0;
   return sub {
      while ('necessary') {
         ++$n;
         $n =~ tr/0/1/;
         $n = ($1 + 1) . $2 if $n =~ m{\A ([2468]) (.*) }mxs;
         my $candidate = $n . '0' . reverse($n);
         return $candidate if is_prime($candidate);
      }
   };
}
```

I know, I know. Half of the times I bake a primality check in my
solutions, the other half I use [ntheory][]. Today it was the latter,
OK?!?

We're generating an iterator, so that we can get as many valid numbers
as we need, sorted in ascending order. The `tr/0/1/` removes the
unwanted `0` characters (as a matter of fact, we're kind of counting
base 9 here, using a rejection method); the following match allows us
skipping leading even digits. Then we generate the candidate as a cyclop
number.

The same can be translated into [Raku][], although we're using a `class`
here. I don't know why, this is my typical go-to solution in [Raku][].

```raku
#!/usr/bin/env raku
use v6;

class CyclopFactory { ... }

sub MAIN (Int $n = 20) {
   my $it = CyclopFactory.new();
   $it.get.put for 1 .. $n;
}

class CyclopFactory {
   has $!n is built = 0;
   method get {
      loop {
         $!n = ($!n + 1).Str;
         $!n ~~ tr/0/1/;
         $!n = ($0 + 1) ~ $1 if $!n ~~ /^ (<[ 2 4 6 8 ]>) (.*) /;
         my $candidate = $!n ~ '0' ~ $!n.flip;
         return $candidate if $candidate.is-prime;
      }
   }
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#177]: https://theweeklychallenge.org/blog/perl-weekly-challenge-177/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-177/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ntheory]: https://metacpan.org/pod/ntheory
