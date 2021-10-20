---
title: PWC135 - Validate SEDOL
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#135][].
> Enjoy!

# The challenge

> You are given 7-characters alphanumeric SEDOL.
>
> Write a script to validate the given SEDOL. Print 1 if it is a valid
> SEDOL otherwise 0.
>
> For more information about **SEDOL**, please checkout the
> [wikipedia][wpedia] page.
>
> **Example 1**
>
>     Input: $SEDOL = '2936921'
>     Output: 1
>
> **Example 2**
>
>     Input: $SEDOL = '1234567'
>     Output: 0
>
> **Example 3**
>
>     Input: $SEDOL = 'B0YBKL9'
>     Output: 1

# The questions

Every little detail about this challenge is actually addressed by the
[wikipedia page][wpedia] as a first stop, and the thorough
[documentation][] as the ultimate, authoritative source.

I have to admit that I had a residual question after reading the
explanation in wikipedia, namely to understand which letters would be
considered *vowels* (because they have to be ignored). It turns out
that's the same as we have in Italian - namely `AEIOU` - and that `Y` is
*not* considered a vowel. Fair enough.

The interface is sufficiently specified: we're expecting a `0` or a `1`
back, and I'm assuming it's OK to use whatever [Perl][] deems sufficient
for it. Our mileage may vary depending on the language - e.g. C might
insist that we specify if we're getting back a char, an int, or a string
for example.

# The solution

This is basically a validation function... so on to do the validation.

[Perl][] comes first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';
sub validate_SEDOL ($s) {
   state $weights = [1, 3, 1, 7, 3, 9, 1];
   return 0 if $s !~ m{\A [0-9B-DF-HJ-NP-TV-Z]{6} [0-9] \z}mxs;
   my @s = split m{}mxs, $s;
   my $sum = sum map {
      my $n = $s[$_] le '9' ? $s[$_] + 0 : ord($s[$_]) - ord('A') + 10;
      $weights->[$_] * $n;
   } 0 .. 6;
   return $sum % 10 ? 0 : 1;
}
say validate_SEDOL(shift // 'B0YBKL9');
```

The list of weights is kept in a `state` variable because they don't
change and it does not make sense to re-define the variable over and
over. It's not needed in this challenge, of course; consider this as
part of my *diet* to try and use the right thing depending on its goal,
especially if this does not imply any complication on the code. Well,
I'm just assuming that nobody will be puzzled by that `state` variable
anyway, and I'm sure *future me* will recognize the pattern.

The initial validation is against having the right amount of characters
of the right type. As it is, the initial 6 characters can be digits of
non-vowels, while the last character can only be a digit to make the
checksum be exactly divisible by 10 (so it's a more restricted set of
characters).

If this *syntax* validation is fine, we proceed to apply the
SEDOL-specific validation step, calculating the weighted sum and
checking its value for divisibility by 10 (actually, we compute the rest
in the division by 10, and make sure it's 0).

Let's move on to [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub validate-SEDOL (Str() $s) {
   state @weights = 1, 3, 1, 7, 3, 9, 1;
   return 0 if $s !~~ /^ <[0..9 B..D F..H J..N P..T V..Z]> ** 6 <[ 0..9 ]> $/;
   my $sum = (0 .. 6).map({
      my $c = $s.substr($_, 1);
      my $n = $c le '9' ?? $c + 0 !! $c.ord - 'A'.ord + 10;
      @weights[$_] * $n;
   }).sum;
   return $sum % 10 ?? 0 !! 1;
}
put validate-SEDOL(@*ARGS[0] || 2936921);
```

The translation is almost... the same, with the big difference with
respect to the regular expression. I have to say that the [Raku][] way
is interesting... but I still would like to have had [Perl][]'s instead!

Enough for this post... stay safe!

[wpedia]: https://en.wikipedia.org/wiki/SEDOL
[documentation]: https://www2.lseg.com/SEDOL-masterfile-service-tech-guide-v8.6
[The Weekly Challenge]: https://theweeklychallenge.org/
[#135]: https://theweeklychallenge.org/blog/perl-weekly-challenge-135/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-135/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
