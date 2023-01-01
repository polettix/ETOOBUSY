---
title: PWC191 - Twice Largest
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#191][]. Enjoy!

# The challenge

> You are given list of integers, `@list`.
>
> Write a script to find out whether the largest item in the list is at
> least twice as large as each of the other items.
>
> **Example 1**
>
>     Input: @list = (1,2,3,4)
>     Output: -1
>
>     The largest in the given list is 4. However 4 is not greater than 
>     twice of every remaining elements.
>
>     1 x 2 <= 4
>     2 x 2 <= 4
>     2 x 3 >  4
>
> **Example 2**
>
>     Input: @list = (1,2,0,5)
>     Output: 1
>
>     The largest in the given list is 5. Also 5 is greater than twice of 
>     every remaining elements.
>
>     1 x 2 <= 5
>     2 x 2 <= 5
>     0 x 2 <= 5
>
> **Example 3**
>
>     Input: @list = (2,6,3,1)
>     Output: 1
>
>     The largest in the given list is 6. Also 6 is greater than twice of 
>     every remaining elements.
>
>     2 x 2 <= 6
>     3 x 2 <= 6
>     1 x 2 <= 6
>
> **Example 4**
>
>     Input: @list = (4,5,2,3)
>     Output: -1
>
>     The largest in the given list is 5. Also 5 is not greater than twice 
>     of every remaining elements.
>
>     4 x 2 >  5
>     2 x 2 <= 5
>     3 x 2 >  5

# The questions

I guess we're gradually transitioning towards TDC - *Test Driven
Challenges*. This is not bad per-se, we would just need a few more
examples.

So...

- What should we return? Assuming `-1` for false and `1` for true.
- What should we return if we are provided an empty list? This is tough,
  I'll just assume that `-1` is good.
- What should we return if we only have one single entry in the list?
  This time... I'll assume that `1` is good.
- What should we do with repeated value? I'll assume that they can be
  ignored.

OK, let's move on to...

# The solution

The most efficient algorithm would need to look *at least* at all
elements and actually needs looking at each of them at most once. So we
have a good linear complexity, by doing this (assuming enough stuff in
the array):

```
# initialize from the first two elements
my ($v1, $v2) = @list[0] < @list[1] ? @list[1,0] : @list[0,1];

# sweep the rest of the list
my $i = 1;
while (++$i < @list) {
   ($v1, $v2) = (@list[$i], $v1) if @list[$i] > $v1;
}

# now we can check if $v1 >= 2 * $v2
```

I *hope* that the code above is valid in *both* [Raku][] and [Perl][]
(even though it's going to raise a few warnings with the latter).

Anyway.

On the other hand... the fastest (programmer-wise, mind you!) solution
can involve sorting the array in reverse order, and take the maximum
value (ending up in first position) and the second-to-maximum value
(ending up in second position) and compare them. Which is what we do in
[Raku][] here:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@list) { put twice-largest(@list) }

sub twice-largest (@list) {
   my ($top, $next) = @list.sort({ $^a <=> $^b }).reverse.flat;
   return -1 unless defined $top;
   return 1 unless defined $next;
   return ($top >= 2 * $next) ?? 1 !! -1;
}
```

With a little twist, in our [Perl][] translation we'll move the checks
*before* doing the sorting, but for anything less it's just the same
algorithm as above:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say twice_largest(@ARGV);

sub twice_largest (@list) {
   return -1 unless @list > 0;
   return 1 unless @list > 1;
   my ($top, $next) = reverse sort { $a <=> $b } @list;
   return ($top >= 2 * $next) ? 1 : -1;
}
```

Well, nothing more to add I daresay... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#191]: https://theweeklychallenge.org/blog/perl-weekly-challenge-191/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-191/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
