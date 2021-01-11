---
title: PWC095 - Palindrome Number
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-13 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#095][]. Enjoy!

# The challenge

> You are given a number `$N`. Write a script to figure out if the given
> number is Palindrome. Print `1` if true otherwise `0`.

# The questions

To be honest, the only questions that I have are about the input format
and what to do if something wrong is provided. I guess this might change
from language to language - e.g. in C there's no way you code a function
to accept an integer and then be provided something else.

Well, unless there's some casting, of course... but at that point I
doubt that the pointer's address as an integer would be the same as
e.g. a string.

Well, it might... but at that point that would still be a valid integer,
right?

Anyway, this question is actually about a *string*, in particular the
*string form of the decimal representation* of the number. At least,
that's how I am reading it! [Perl][] does this *conversion* by default,
and as an added bonus it works fine for integers and decimals as well...
we'll skip the validation of the input though.

# The solution

To check whether the input *string* is palindrome, we can start from the
two outer character and compare them. If they're different... we have
our answer: it's a no. Well, a `0`. Otherwise, we move on with the two
inner characters, until these two meet in the middle.

In a string with `4` characters we would have to do 2 comparisons, so
it's one half. In a string with `5` charaters, again, we would have to
do 2 comparisons because the middle character is surely the same as...
itself. So again it's one half, only that we take the integer part of
this half.

So, we end up with the following:

```perl
sub is_palindrome ($s) {
   for my $i (0 .. length($s) / 2 - 1) {
      return 0 if substr($s, $i, 1) ne substr($s, -1 - $i, 1);
   }
   return 1;
}
```

As anticipated, we iterate up to something that is tied to one half of
the string's lenght. Our iteration variable `$i` will be used as an
*index* to get characters out of string `$s` using the built-in function
[substr][], which starts at `0` - this is why we subtract 1 in the range
of the for loop.

The condition in the loop compares two characters taking them according
to the current value of the sweeping index `$i`. In the first iteration,
the left-wise [substr][] takes the character at the `0` index (that is,
the very first character in the string) and the right-wise the one at
`-1`. Here, we leverage the handy fact that [substr][] uses negative
indexes to get characters starting from *the end of the string*.

If we make it after the last characters' check... it's a `1`, yay!

The whole script, should you be interested into it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub is_palindrome ($s) {
   for my $i (0 .. length($s) / 2 - 1) {
      return 0 if substr($s, $i, 1) ne substr($s, -1 - $i, 1);
   }
   return 1;
}

sub palindrome_number ($N) { return is_palindrome($N) }

say palindrome_number(shift || 1221);
```

Stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#095]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-095/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-095/#TASK1
[Perl]: https://www.perl.org/
[substr]: https://perldoc.perl.org/functions/substr
