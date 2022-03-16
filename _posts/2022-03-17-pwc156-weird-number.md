---
title: PWC156 - Weird Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-03-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#156][].
> Enjoy!

# The challenge

> You are given number, `$n > 0`.
>
> Write a script to find out if the given number is a `Weird Number`.
>
> According to [Wikipedia][], it is defined as:
>
>> The sum of the proper divisors (divisors including 1 but not itself)
>> of the number is greater than the number, but no subset of those
>> divisors sums to the number itself.
>
> **Example 1:**
>
>     Input: $n = 12
>     Output: 0
>
>     Since the proper divisors of 12 are 1, 2, 3, 4, and 6, which sum to 16;
>     but 2 + 4 + 6 = 12.
>
> **Example 2:**
>
>     Input: $n = 70
>     Output: 1
>
>     As the proper divisors of 70 are 1, 2, 5, 7, 10, 14, and 35; these sum to 74,
>     but no subset of these sums to 70.

# The questions

What's in the challenges this week? Is there anything that calls for
lazy, brutey force attacks, or is it just me?

# The solution

As anticipated, I'm very lazy this week. This totally reflects in the
[Perl][] solution, where I summon *three* different modules to get the
job done:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";

use Algorithm::Knapsack;
use ntheory 'divisors';
use List::Util 'sum';

say $_, ' ', is_weird($_) for (@ARGV ? @ARGV : (12, 70));

sub is_weird ($n) {
   my @divs = reverse divisors($n);
   shift @divs if @divs > 1;
   return 0 if $n >= sum @divs;
   my $ks = Algorithm::Knapsack->new(capacity => $n, weights => \@divs);
   $ks->compute;
   for my $solution ($ks->solutions) {
      my $sum = sum @divs[$solution->@*];
      return 0 if $sum == $n;
   }
   return 1;
}
```

Need the divisors? There you go, [ntheory][].

Need to arrange good approximations? There you go,
[Algorithm::Knapsack][].

Need to do sums? There you go, [List::Util][].

Need some glue? There you go, [Perl][].

The [Raku][] *translation* shows even more lazyness. While some stuff is
included just like the batteries, like a handy `sum` method, looking for
proper divisors and using the knapsack algorithm is harder because a
very lazy search did not make anything *stand out*. So I opted for
implementing stuff just to minimize the waste of time for *looking* a
pre-made solution. I'm ashamed.

Here it is:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (*@args) {
   my @inputs = @args ?? |@args !! (12, 70);
   @inputs.map({
      put $_, ' ', is-weird($_);
   });
}

sub proper-divisors (Int:D $n) { (1..($n/2)).grep: $n %% * }

sub is-weird (Int:D $n) {
   my @divs = proper-divisors($n);
   return 0 if @divs.sum <= $n;
   loop {
      my $sum = @divs.sum;
      return 0 if $sum == $n;
      return 1 if $sum < $n;
      my $ms = @divs.pop;
      my $target = $n - $ms;
      for (^(2 ** @divs.elems)).reverse -> $k is copy {
         my $sum = 0;
         my $i = 0;
         while $k > 0 {
            $sum += @divs[$i] if $k +& 1;
            return 0 if $target == $sum;
            ++$i;
            $k +>= 1;
         }
      }
   }
}
```

I guess the implementation if `is-weird` is closer to what I was
expected to do. I mean, what *I think* I *might have been expected* to
do, i.e. code a solution specific to the problem. Whatever, the [Perl][]
solution is a solution too.

Anyway, here I'm trying to find out if there's an arrangement that sums
up exactly to the input number, *except* that I'm trying to bail out
early if conditions don't apply any more. This is obtained by
considering the sums with the highest number(s) first, eliminating them
on the way. When we end up with a residual list whose sum is lower than
the target number, there's no way to select a subset that sums exactly
to that and we can safely return early. Not too much of an optimization
but still.

The `proper-divisors` function finally gave me the occasion to use the
*whatever* variable in a `grep`. So far I could not manage to get it
right, but as you can see I'm still trying.

> You might have observed that I'm using the first singular person a lot
> here, instead of a more inclusive first plural version. This is
> because I take full responsibility for not thinking too much about the
> solution to the challenge, and I don't want to make it appear like
> it's somebody else's fault too.

Let's hope the best for people in Ukraine, and the rest of the places
that are in a war!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#156]: https://theweeklychallenge.org/blog/perl-weekly-challenge-156/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-156/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Wikipedia]: https://en.wikipedia.org/wiki/Weird_number
[ntheory]: https://metacpan.org/pod/ntheory
[Algorithm::Knapsack]: https://metacpan.org/pod/Algorithm::Knapsack
[List::Util]: https://metacpan.org/pod/List::Util
