---
title: PWC190 - Capital Detection
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#190][]. Enjoy!

# The challenge

> You are given a string with alphabetic characters only: `A..Z` and
> `a..z`.
>
> Write a script to find out if the usage of Capital is appropriate if
> it satisfies at least one of the following rules:
>
>     1) Only first letter is capital and all others are small.
>     2) Every letter is small.
>     3) Every letter is capital.
>
> **Example 1**
>
>     Input: $s = 'Perl'
>     Output: 1
>
> **Example 2**
>
>     Input: $s = 'TPF'
>     Output: 1
>
> **Example 3**
>
>     Input: $s = 'PyThon'
>     Output: 0
>
> **Example 4**
>
>     Input: $s = 'raku'
>     Output: 1

# The questions

The specification is a little... lacking, e.g.:

- is the empty string valid?
- does it qualify?
- what should we print exactly? (This is left for induction from the
  examples).


# The solution

Well, this is the perfect challenge for some regular expression.

This is where [Perl][] spoiled me. I feel --no, *I know*-- that there
are better ways to express this in [Raku][], but it worked in the first
place and I'll call it a day.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($s) { put capital-detection($s) }

sub capital-detection ($string) {
   ($string ~~ /
         ^<[a..z]>*$                # lc
      |  ^<[a..z A..Z]><[a..z]>*$   # ucfirst
      |  ^<[A..Z]>*$/               # uc
   ) ?? 1 !! 0;
}
```

In [Perl][] I'm setting the *start of string* and *end of string* once,
then using non-capturing parentheses for the three alternatives.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say capital_detection(shift // 'whatever');

sub capital_detection ($string) {
   0 + $string =~ m{\A(?:[a-z]*|[a-zA-Z][a-z]*|[A-Z]*)\z}mxs;
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#190]: https://theweeklychallenge.org/blog/perl-weekly-challenge-190/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-190/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
