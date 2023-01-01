---
title: PWC177 - Damm Algorithm
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-10 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#177][]. Enjoy!

# The challenge

> You are given a positive number, `$n`.
>
> Write a script to validate the given number against the included check
> digit.
>
> Please checkout the [wikipedia page][] for information.
>
> **Example 1**
>
>     Input: $n = 5724
>     Output: 1 as it is valid number
>
> **Example 2**
>
>     Input: $n = 5727
>     Output: 0 as it is invalid number

# The questions

If this were an interview question, I'd probably ask something about
what we're supposed to validate and what would go beyond these
boundaries.

# The solution

The [Damm Algorithm][wikipedia page] is a way to calculate a control
digit out of other digits. There are quite a few of these procedures,
and it seems that this particular one has its own advantages, except -
maybe - its reluctance on accepting leading `0`, i.e. treating `1` and
`0001` as if they're the same thing.

Which, honestly, they are - at least as long as we consider the input *a
positive number*. In this challenge, it is.

OK, this said, we have to play a treasure hunt onto a matrix. In
[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($input = 5724) { put damm-calculate($input) ?? 0 !! 1 }

sub damm-calculate ($input) {
   state @qs = <
      0  3  1  7  5  9  8  6  4  2
      7  0  9  2  1  5  4  8  6  3
      4  2  0  6  8  7  1  3  5  9
      1  7  5  0  9  8  3  4  2  6
      6  1  2  3  0  4  5  9  7  8
      3  6  7  4  2  0  9  5  8  1
      5  8  6  9  7  2  0  1  3  4
      8  9  4  5  3  6  2  0  1  7
      9  4  3  8  6  1  7  2  0  5
      2  5  8  1  4  3  6  7  9  0
   >;
   (0, $input.comb.Slip).reduce({@qs[10 * $^a + $^b]});
}
```

I love `reduce`, as it's perfect for this kind of chain reaction stuff.
We have to *inject* the equivalent of a *leading `0`* to get the ball
started properly and focus on the first row at the beginning, but apart
from this it's just the usual *take result and new item, rinse,
repeat*.

The matrix is represented as a linear array, as I like doing lately.
It's just for having some fun, I think some time ago I saw there is no
real benefit in doing this. It does not improve readability, anyway, but
might help keeping attention levels high with a little *what the hell*
moment.

I have to admit that I slapped the `Slip` without too much thinking. I
don't know if I'm finally getting the gist of it, but I've been biten by
the tightness of [Raku][] containers many times and it's a sort of
defensive attempt from my side. Punishment-based learning, if you will,
although I'd like to use `Slip` and `flat` *knowing* better what they
are for. I'll get there, one day.

The [Perl][] counterpart is pretty much a translation with functions
instead of methods. It kind of flows more naturally, although backwards,
because it does not *force* the construction of a container of digits to
ignite the process.

> This is such a subtle pet peeve that I have troubles understanding it,
> too.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'reduce';

my $input = shift // 5724;
say damm_calculate($input) ? 0 : 1;

sub damm_calculate ($input) {
   state $qs = [qw<
      0  3  1  7  5  9  8  6  4  2
      7  0  9  2  1  5  4  8  6  3
      4  2  0  6  8  7  1  3  5  9
      1  7  5  0  9  8  3  4  2  6
      6  1  2  3  0  4  5  9  7  8
      3  6  7  4  2  0  9  5  8  1
      5  8  6  9  7  2  0  1  3  4
      8  9  4  5  3  6  2  0  1  7
      9  4  3  8  6  1  7  2  0  5
      2  5  8  1  4  3  6  7  9  0
   >];
   reduce {$qs->[10 * $a + $b]} 0, split m{}mxs, $input;
}
```

And that's all, folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#177]: https://theweeklychallenge.org/blog/perl-weekly-challenge-177/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-177/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia page]: https://en.wikipedia.org/wiki/Damm_algorithm
