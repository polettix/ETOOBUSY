---
title: PWC118 - Binary Palindrome
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#118][]. Enjoy!

# The challenge

> You are given a positive integer `$N`.
>
> Write a script to find out if the binary representation of the given
> integer is Palindrome. Print 1 if it is otherwise 0.
>
> **Example**
>
>     Input: $N = 5
>     Output: 1 as binary representation of 5 is 101 which is Palindrome.
>
>     Input: $N = 4
>     Output: 0 as binary representation of 4 is 100 which is NOT Palindrome.

# The questions

One question is about the exact representation of the integer as a
decimal number. OK, *usually* any leading `0` is ignored, but in base-2
this means ruling out all even numbers in a single stroke! Whatever, the
example seems explicit to this regard.

# The solution

[Raku][] first, in the spirit of taking the challenge in the new
language and try to learn something:

```raku
#!/usr/bin/env raku
use v6;
sub binary-palindrome (Int:D $N where * > 0 --> Bool) {
   return False if $N %% 2;
   my ($M, $n) = (0, $N);
   ($M, $n) = (($M +< 1) +| ($n +& 1), $n +> 1) while $n > 0;
   return so $M == $N;
}
sub MAIN (*@args is copy) {
   @args = 1 .. 31;
   put $_, ' -> ', binary-palindrome($_) ?? 1 !! 0 for @args;
}
```

The approach chosen is to stick to bitwise operations instead of turning
the integers into a *string* representation and then check for
palindrome*ness*.

So what we're doing here is to *reverse* the input number `$N` and check
whether the result (which is `$M`, by the way) is the same as `$N`.

One tricky part here was using the *correct* operators. Coming from
[Perl][], binary operations are `|` and `&` and the bitshifts are `<<`
and `>>`.

The story in [Raku][] is different though, so we have respectively `+|`,
`+&`, `+<`, and `+>`. The error messages were great to this regard.

Porting the solution to [Perl][] is easy:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub binary_palindrome ($N) {
   die "invalid $N (positive integers are OK)\n"
      if $N !~ m{\A [1-9]\d* \z}mxs;
   return unless $N % 2;
   my ($M, $n) = (0, $N);
   ($M, $n) = (($M << 1) | ($n & 1), $n >> 1) while $n > 0;
   return $M == $N;
}

my @args = @ARGV ? @ARGV : 1 .. 31;
say $_, ' -> ', binary_palindrome($_) ? 1 : 0 for @args;
```

Well, that's on the brink of *plagiarism*!

I decided to put a validation for the input (which I usually avoid) just
to make the two solutions more aligned ([Raku][] signatures allow
setting validations so it's almost a sin to not put them).

Then, of course, there's no *is-divisible-by* operator `%%` in [Perl][],
so we have to resort to inverting the result of the *rest-by* operator
`%`:

```
# Raku: is $N divisible by 2?
return False if $N %% 2;

# Perl: does integer division of $N by 2 have no rest?
return unless $N % 2;
```

No big deal, but it's good to be able and be precise in [Raku][].

Well.. enough for today, have fun and stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#118]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-118/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-118/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
