---
title: PWC153 - Factorions
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#153][].
> Enjoy!

# The challenge

> You are given an integer, `$n`.
>
> Write a script to figure out if the given integer is factorion.
>
>> A factorion is a natural number that equals the sum of the factorials of its digits.
>
> **Example 1:**
>
>     Input: $n = 145
>     Output: 1
>
>         Since 1! + 4! + 5! => 1 + 24 + 120 = 145
>
> **Example 2:**
>
>     Input: $n = 123
>     Output: 0
>
>         Since 1! + 2! + 3! => 1 + 2 + 6 <> 123

# The questions

... does the challenge puzzle say anything about the *base* we are
supposed to consider for figuring out the *digits*? Is base 10 fair
enough?

# The solution

OK, let's start with a blunt implementation of the test in [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

say is_factorion(shift // 145) ? 1 : 0;

sub is_factorion ($n) {
   state $f = [ 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880 ];
   $n == sum map { $f->[$_] } split m{}mxs, $n;
}
```

We only need factorials up to $9$ here, so it makes sense to avoid
implementing the factorial function altogether and use a `state`
variable to keep them.

Now, let's switch the brain on.

It's intuitive that there can be only a finite amount of factorions,
whatever the base. As an example, in base 10 the maximum contribution to
the sum is from digit $9$, which provides a whopping $362880$. Not bad,
but it's still a finite and limited contribution to be compared against
exponentially growing numbers as we add more digits.

So, for example, the sequence of $9999999$ (seven $9$) yields a sum of
all factorials of the digits that is a mere $2540160$ (seven digits, but
clearly less than the original). As a matter of fact, it's *impossible*
to go beyond $2540160$ with seven digits, and eight digits or more
numbers are of course out of reach.

So... it makes sense to look for *all* factorions in base 10:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

# find out the limit. With a given amount of 9 we can only go "some"
# far, so there's no point going beyond that maximum point.
my $s = '';
while ('necessary') {
   $s .= '9';
   last if $s > sumfact($s);
}

# find out all factorions (up to that limit)
for my $n (0 .. sumfact($s)) {
   say $n if $n == sumfact($n);
}

sub sumfact ($n) {
   state $f = [ 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880 ];
   sum map { $f->[$_] } split m{}mxs, $n;
}
```

It seems that there are *not that many*:

```
1
2
145
40585
```

This leads us to our [Raku][] solution:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n = 145) { put is-factorion($n) ?? 1 !! 0 }

sub is-factorion (Int:D $n where $n >= 0) {
   state %factorions = set(1, 2, 145, 40585);
   return $n ∈ %factorions;
}
```

So cool!



[The Weekly Challenge]: https://theweeklychallenge.org/
[#153]: https://theweeklychallenge.org/blog/perl-weekly-challenge-153/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-153/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
