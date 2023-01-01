---
title: PWC151 - Rob The House
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#151][].
> Enjoy!

# The challenge

> You are planning to rob a row of houses, always starting with the
> first and moving in the same direction. However, you can’t rob two
> adjacent houses.
>
> Write a script to find the highest possible gain that can be achieved.
>
> **Example 1:**
>
>     Input: @valuables = (2, 4, 5);
>     Output: 7
>
>     If we rob house (index=0) we get 2 and then the only house we can rob is house (index=2) where we have 5.
>     So the total valuables in this case is (2 + 5) = 7.
>
>
> **Example 2:**
>
>     Input: @valuables = (4, 2, 3, 6, 5, 3);
>     Output: 13
>
>     The best choice would be to first rob house (index=0) then rob house (index=3) then finally house (index=5).
>     This would give us 4 + 6 + 3 =13.

# The questions

Well... *why the theme*?!?

# The solution

This is a fantastic opportunity to use a dynamic programming approach,
which in my head means: cache values so that you don't repeat
calculating them over and over. Which can be addressed egregiously by
the [Memoize][] module, by the way.

In this case, it's worth observing that when we are in a position, we
MUST take the value at that position and then move to the second or
third house down the line. Anything more would just be... missing some
robbing opportunity, for no gain. It's just a matter of deciding which
move is best between the two, which is easily solves with taking the max
between the two.

To make things very simple, we're going to use recursion, passing the
`$start` index along the way and setting the recursion stop condition to
when `$start` points beyond the end of the input list.

OK, time for some code:


```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Memoize 'memoize';
use List::Util 'max';

memoize('rob_the_house');
sub rob_the_house ($list, $start = 0) {
   return 0 if $start > $list->$#*;
   return $list->[$start]
      + max(rob_the_house($list, $start + 2),
            rob_the_house($list, $start + 3));
}

say rob_the_house([@ARGV]);
```

I would even say that using memoization is overkill here, because we're
not told how big is the input list but I doubt it's going to grow very
large 🙄.

Anyway.

The [Raku][] implementation gives us some space for a couple of twists.
On the one hand, the memoization is not available out of the box, and
installing a module seems overkill for a little cache. So the
implementation decision here is to close over the input `@list`, as
well as a `@cache` for intermediate values.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put rob-the-house(@args) }

sub rob-the-house (@list) {
   multi sub rth ($index where * > @list.end) { return 0 }
   my @cache;
   multi sub rth ($index) {
      @cache[$index] //= @list[$index] + (2, 3).map({rth($index + $_)}).max;
   }
   return rth(0);
}
```

We're using `multi` to tell the recursion end condition apart from the
"middle" case, as well as restricting the two `multi sub` within the
externally-visible function. I'm not *that* sure that `rth` works as
expected if called onto multiple, different inputs but I *hope* it does.

Well, also this week came to an end for the challenge... stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#151]: https://theweeklychallenge.org/blog/perl-weekly-challenge-151/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-151/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Memoize]: https://metacpan.org/pod/Memoize
