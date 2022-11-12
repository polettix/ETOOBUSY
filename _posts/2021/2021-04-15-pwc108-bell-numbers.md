---
title: PWC108 - Bell Numbers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-15 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#108][].
> Enjoy!

# The challenge

> Write a script to display top 10 `Bell Numbers`. Please refer to
> [wikipedia page][] for more information.

# The questions

A fundamental question in this challenge is *what do you mean by
**display**?*

I mean, displaying a *number* is printing it, *right*? Or should we
actually *display all possible arrangements leading to that number?*.

# The solution

We'll take the easy route in this, but still keep the door open for
possible future wast**AHEM**improvements.

As it is so often, the [wikipedia page][] provides a neat way to
calculate the numbers iteratively. This implies a time complexity of
$O(n^2)$ and a space complexity of $O(n)$, which is not bad considering
that we're asked to address only a handful of numbers and that the time
complexity actually accounts for computing all $n$ numbers (so, on
average, the complexity of any single of them is $O(n)$, assuming we can
rely on the previous calculations).

Enough talking, let's get to the code:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub bell_number ($N) {
   state $cache = [1];
   state $line = [1];
   while ($cache->$#* < $N) {
      my @previous_line = $line->@*;
      $line->@* = $previous_line[-1];
      push $line->@*, $_ + $line->[-1] for @previous_line;
      push $cache->@*, $line->[0];
   }
   return $cache->[$N];
}

printf "B%d: %d\n", $_, bell_number($_) for 0 .. 9;
```

We keep two cache variables: one for the sequence itself (so that we can
reuse results if we need), one for the *previous line* in the triangle
to calculate the numbers. If you don't know what triangle I'm talking
about, look at the [Triangle scheme for calculations][triangle].

I guess this is all *for this post* 😅


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#108]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-108/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-108/#TASK2
[Perl]: https://www.perl.org/
[wikipedia page]: https://en.wikipedia.org/wiki/Bell_number
[triangle]: https://en.wikipedia.org/wiki/Bell_number#Triangle_scheme_for_calculations
