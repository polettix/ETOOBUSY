---
title: PWC196 - Range List
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-23 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#196][].
> Enjoy!

# The challenge

> You are given a sorted unique integer array, `@array`.
>
> Write a script to find all possible [Number Range` i.e [x, y]
> represent range all integers from `x` and `y` (both inclusive).
>
>> Each subsequence of two or more contiguous integers
>
> **Example 1**
>
>     Input: @array = (1,3,4,5,7)
>     Output: [3,5]
>
> **Example 2**
>
>     Input: @array = (1,2,3,6,7,9)
>     Output: [1,3], [6,7]
>
> **Example 3**
>
>     Input: @array = (0,1,2,4,5,6,8,9)
>     Output: [0,2], [4,6], [8,9]

# The questions

I guess either everything is clear, or I'm softening in my nitpicking.
I'd only ask if it's *necessary* to print out exactly as in the
example... I'll assume *not*.

# The solution

For me, the tricky part was filtering out ranges where the begin and the
end are equal. This makes my code... *inelegant*.

Anyway.

The approach is this: iterate through the list, keeping track of the
*latest* range. If a value is out of the previous range (or there's no
previous range), we add another one.

Here's [Perl][], which I hope makes the algorithm above more readable:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say join ', ',
  map { '[' . join(',', $_->@*) . ']'}
  range_list(@ARGV ? @ARGV : (1, 3, 4, 5, 7));

sub range_list (@array) {
   my @retval;
   for my $v (@array) {
      if (@retval && $retval[-1][1] == $v - 1) {
         $retval[-1][1] = $v;
      }
      else {
         pop @retval if @retval && $retval[-1][0] == $retval[-1][1];
         push @retval, [$v, $v];
      }
   }
   pop @retval if @retval && $retval[-1][0] == $retval[-1][1];
   return @retval;
}
```

The [Raku][] rendition is almost the same, only with slightly different
machinery. I liked the idea to use `gather`/`take`. Still, there's the
need to take the last range into account, which bothers me a bit because
of the code repetition.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { say range-list(@args) }

sub range-list (@array) {
   gather {
      my ($begin, $end);
      for @array -> $v {
         if defined($end) && $end == $v - 1 {
            $end = $v;
         }
         else {
            take [$begin, $end] if defined($begin) && $begin < $end;
            $begin = $end = $v;
         }
      }
      take [$begin, $end] if defined($begin) && $begin < $end;
   }
}
```

So well, this makes it for this week's challenges... Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#196]: https://theweeklychallenge.org/blog/perl-weekly-challenge-196/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-196/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
