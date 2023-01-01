---
title: PWC195 - Most Frequent Even
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-16 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#195][].
> Enjoy!

# The challenge

> You are given a list of numbers, `@list`.
>
> Write a script to find most frequent even numbers in the list. In case
> you get more than one even numbers then return the `smallest even
> integer`. For all other case, return `-1`.
>
> **Example 1**
>
>     Input: @list = (1,1,2,6,2)
>     Output: 2 as there are only 2 even numbers 2 and 6 and of those 2 
>     appears the most.
>
> **Example 2**
>
>     Input: @list = (1,3,5,7)
>     Output: -1 since no even numbers found in the list
>
> **Example 3**
>
>     Input: @list = (6,4,4,6,1)
>     Output: 4 since there are only two even numbers 4 and 6. They both
>     appears the equal number of times, so pick the smallest.

# The questions

Should we only consider positive integers? By the way, are integers the
only suitable numbers?


# The solution

The algorithm in this case will be very basic: iterate through the
provided list, keeping track of the best candidate as the list goes on.

We can track the amount of each even number with a slot in a hash, so
that we can land on the most frequent.

[Perl][] goes first this time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @list = @ARGV ? @ARGV : qw< 1 1 2 6 2 >;

my $result = -1;
my $result_count = 0;
my %count_for = (-1 => 0);
for my $item (@list) {
   next if $item % 2;
   my $current = $count_for{$item}++;
   ($result, $result_count) = ($item, $current)
      if $current > $result_count
      || ($current == $result_count && $item < $result);
}
say $result;
```

The translation into [Raku][] is pretty straightforward:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @list = @args ?? @args !! < 1 1 2 6 2 >».Int;
   my $result = -1;
   my $result_count = 0;
   my %count_for = -1 => 0;
   for @list -> $item {
      next if $item % 2;
      my $current = %count_for{$item}++;
      ($result, $result_count) = $item, $current
         if $current > $result_count
         || ($current == $result_count && $item < $result);
   }
   put $result;
}
```

Enough for today... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#195]: https://theweeklychallenge.org/blog/perl-weekly-challenge-195/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-195/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
