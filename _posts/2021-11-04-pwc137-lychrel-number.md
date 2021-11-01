---
title: PWC137 - Lychrel Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-11-04 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#137][].
> Enjoy!

# The challenge

> You are given a number, 10 <= `$n` <= 1000.
>
> Write a script to find out if the given number is Lychrel number. To
> keep the task simple, we impose the following rules:
>
>     a. Stop if the number of iterations reached 500.
>     b. Stop if you end up with number >= 10_000_000.
>
> According to [wikipedia][]:
>
>>  A Lychrel number is a natural number that cannot form a palindrome
>>  through the iterative process of repeatedly reversing its digits and
>>  adding the resulting numbers.
>
> **Example 1**
>
>     Input: $n = 56
>     Output: 0
>     
>     After 1 iteration, we found palindrome number.
>     56 + 65 = 121
>
> **Example 2**
>
>     Input: $n = 57
>     Output: 0
>     
>     After 2 iterations, we found palindrome number.
>      57 +  75 = 132
>     132 + 231 = 363
>
> **Example 3**
>
>     Input: $n = 59
>     Output: 0
>     
>     After 3 iterations, we found palindrome number.
>      59 +  95 =  154
>     154 + 451 =  605
>     605 + 506 = 1111

# The questions

The only real question is... *what should we return if the number is
suspected to be a Lycherel*? I'll return 1.

It's interesting the limit at 500 iterations - I guess that with the
*other* limit at 10 millions, it will never be hit.

# The solution

We'll start with [Perl][] here. The [reverse][] function flips a string,
and an integer in [Perl][] has a dual-life as a string, so it basically
works:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say maybe_lychrel(shift || 196);

sub maybe_lychrel ($n) {
   while ($n < 10_000_000) {
      my $r = reverse $n;
      return 0 if $n eq $r;
      $n += $r;
   }
   return 1;
}
```

In [Raku][] it's basically the same. We can have more input checks for
free, of course:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Int:D $x where 10 <= * <= 1000 = 196) { maybe-lychrel($x).put }

sub maybe-lychrel (Int:D $n is copy where * > 0) {
   while $n < 10000000 {
      my $r = $n.flip;
      return 0 if $n eq $r;
      $n += $r;
   }
   return 1;
}
```

This time the right sub/method is [flip][], because [reverse][rrev] is
for *listy* stuff. Apart from this... it's a copy.

Stay safe everybody!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#137]: https://theweeklychallenge.org/blog/perl-weekly-challenge-137/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-137/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia]: https://en.wikipedia.org/wiki/Lychrel_number
[reverse]: https://perldoc.perl.org/functions/reverse
[flip]: https://docs.raku.org/routine/flip
[rrev]: https://docs.raku.org/routine/reverse
