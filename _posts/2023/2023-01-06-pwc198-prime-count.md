---
title: PWC198 - Prime Count
type: post
tags: [ the weekly challenge ]
comment: true
date: 2023-01-06 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#198][].
> Enjoy!

# The challenge

> You are given an integer `$n > 0`.
>
> Write a script to print the count of primes less than `$n`.
>
> **Example 1**
>
>     Input: $n = 10
>     Output: 4 as in there are 4 primes less than 10 are 2, 3, 5 ,7.
>
> **Example 2**
>
>     Input: $n = 15
>     Output: 6
>
> **Example 3**
>
>     Input: $n = 1
>     Output: 0
>
> **Example 4**
>
>     Input: $n = 25
>     Output: 9

# The questions

... are we allowed to use *modules*?

# The solution

The question, just for a change, is not to nag our fine host [Mohammad
S. Anwar][manwar]. It's just that the good old [Math::Prime::Util][] by
[Dana Jacobsen][DANAJ] contains function `prime_count`, which needs
*just* a little interface adaptation (i.e. subtracting 1):

```perl
#!/usr/bin/env perl
use ntheory 'prime_count';
print prime_count(($ARGV[0] // 10) - 1), "\n";
```

It's so compact that this time I decided to get rid of all the [Perl][]
programs boilerplate, including the `use v5.24` (so I had to revert back
to `print`, as `say` is not available by default) and `use warnings`.

To compare and contrast, the [Raku][] alternative is equivalently short.
I'm not aware of an implementation of `prime_count`, *but* there's a
primality test out of the box and it's easy to put it at work:

```raku
#!/usr/bin/env raku
sub prime-count ($n) { (2 ... $n).grep({.is-prime}).elems }
put prime-count((@*ARGS[0] // 10) - 1);
```

I decided to keep the same interface as its [Perl][] counterpart
(including the need to subtract 1 before calling it in our case), for
consistency.

I'm not sure how *efficient* this `prime-count` function is, to be
honest. I tried to sneak a `...` for lazy list generation, but I'm not
sure that using `grep` and *then* counting the objects is the right
approach memory-wise. Maybe something like this is a bit less idiomatic
but also less resource taxing:

```raku
sub prime-count ($n) {
   my $count = 0;
   for 2 ... $n -> $k { ++$count if $k.is-prime }
   return $count;
}
```

Anyway, the first implementation is OK for little test inputs, so I'm
sticking with it.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#198]: https://theweeklychallenge.org/blog/perl-weekly-challenge-198/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-198/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Math::Prime::Util]: https://metacpan.org/pod/Math::Prime::Util
[DANAJ]: https://metacpan.org/author/DANAJ
