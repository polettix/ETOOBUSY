---
title: PWC135 - Middle 3-digits
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#135][]. Enjoy!

# The challenge

> You are given an integer.
>
> Write a script find out the middle 3-digits of the given integer, if
> possible otherwise throw sensible error.
>
> **Example 1**
>
>     Input: $n = 1234567
>     Output: 345
>
> **Example 2**
>
>     Input: $n = -123
>     Output: 123
>
> **Example 3**
>
>     Input: $n = 1
>     Output: too short
>
> **Example 4**
>
>     Input: $n = 10
>     Output: even number of digits

# The questions

The specification is terse but also reasonably complete: the input
specification is clear (an integer) and the expected *correct* output
too (the three digits in the middle).

Examples help though:

- the sign has to be ignored;
- integers whose representation has an even number of digits have to be
  disregarded.

I honestly can't think of other corner cases than those in the
examples... so I guess it's a fantastic [TDD][] challenge!

# The solution

There are some checks to be done, and we will do them the boring way,
starting with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub middle-three-digits (Int:D $x is copy) {
   $x = -$x if $x < 0;
   my $l = $x.chars;
   die "too short\n" if $l < 3;
   die "even number of digits\n" if $l %% 2;
   $x.substr(($l - 3) / 2, 3);
}
put middle-three-digits((@*ARGS[0] || 1234567).Int);
```

Ignoring the sign means flipping it if the input is negative. Then, we
consider the number of digits and do our checks.

If everything is OK, we take the middle digits. The length `$l` is
decreased by 3 because:

- 1 takes into account that function `substr` deals with 0-based indexes
- other 2 takes into account that we have to take 3 characters overall,
  so we want to move one character ahead (there's a division by 2, so
  that 2 will become 1 after the division).

The same, in [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
sub middle_three_digits ($x) {
   die "not an integer\n" unless $x =~ m{\A(?: 0 | -? [1-9]\d* )\z}mxs;
   $x = -$x if $x < 0;
   my $l = length $x;
   die "too short\n" if $l < 3;
   die "even number of digits\n" unless $l % 2;
   return substr $x, ($l - 3) / 2, 3;
}
say middle_three_digits(shift // 1234567);
```

There is some additional check at the beginning to validate the input,
but apart from this it's a direct translation (in some cases, copy) of
the [Raku][] counterpart.

This is all, I guess!

[TDD]: https://it.wikipedia.org/wiki/Test_driven_development
[The Weekly Challenge]: https://theweeklychallenge.org/
[#135]: https://theweeklychallenge.org/blog/perl-weekly-challenge-135/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-135/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
