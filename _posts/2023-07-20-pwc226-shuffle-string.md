---
title: PWC226 - Shuffle String
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-07-20 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#226][]. Enjoy!

# The challenge

> You are given a string and an array of indices of same length as string.
>
> Write a script to return the string after re-arranging the indices in the
> correct order.
>
> **Example 1**
>
>     Input: $string = 'lacelengh', @indices = (3,2,0,5,4,8,6,7,1)
>     Output: 'challenge'
>
> **Example 2**
>
>     Input: $string = 'rulepark', @indices = (4,7,3,1,0,5,2,6)
>     Output: 'perlraku'

# The questions

We could argue about what re-arranging the indices means, but it would just
be petty and annoying. So the only assumption, supported by the example, is
that indices are 0-based.

# The solution

This is something that is already baked in our beloved languages: array
slicing ([in Raku][], [in Perl][]).

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($s, *@i) { put $s.comb[@i].join('') }
```

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
say join '', (split //, $ARGV[0])[@ARGV[1 .. $#ARGV]];
```

Stay safe and cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#226]: https://theweeklychallenge.org/blog/perl-weekly-challenge-226/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-226/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[in Perl]: https://perldoc.perl.org/perldata#Slices
[in Raku]: https://docs.raku.org/language/list#Slice_indexing_context
