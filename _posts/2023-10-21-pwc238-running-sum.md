---
title: PWC238 - Running Sum
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-21 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#238][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to return the running sum of the given array. The
> running sum can be calculated as sum[i] = num[0] + num[1] + …. +
> num[i].
>
> **Example 1**
>
>     Input: @int = (1, 2, 3, 4, 5)
>     Output: (1, 3, 6, 10, 15)
>
> **Example 2**
>
>     Input: @int = (1, 1, 1, 1, 1)
>     Output: (1, 2, 3, 4, 5)
>
> **Example 3**
>
>     Input: @int = (0, -1, 1, 2)
>     Output: (0, -1, 0, 2)

# The questions

I'd probably just ask:

- the domain of the inputs (i.e. should we prepare for big integers?)
- the length of the input/output arrays.

# The solution

We can iterate over the input array and collect stuff along the way,
using an accumulator variable. Here's how to do it in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { say running-sum(@args) }

sub running-sum (@int) {
   my $accumulator = 0;
   return [ @int.map({$accumulator += $_}) ];
}
```

I didn't really like the accumulator variable, so I tried to implement
an alternative solution with `gather`/`take`:

```raku
sub running-sum-alternative (@int) {
   return [ gather { take @int[0]; @int.reduce({ take $^a + $^b }) } ]
}
```

Still not that satisfactory, though. Surely [Raku][] has something *to
the point*, right? Right, let's [produce][]!

```raku
sub running-sum-alternative2 (@int) { @int.produce(&[+]) }
```

Surely [Perl][] has something too, right? Right, let's use `reductions`!

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use List::Util 'reductions';

say '(', join(', ', running_sum(@ARGV)), ')';

sub running_sum { reductions { $a + $b } @_ }
```

That's all for this challenge, folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#238]: https://theweeklychallenge.org/blog/perl-weekly-challenge-238/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-238/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[produce]: https://docs.raku.org/type/List#routine_produce
