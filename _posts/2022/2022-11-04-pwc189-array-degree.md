---
title: PWC189 - Array Degree
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-04 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#189][].
> Enjoy!

# The challenge

> You are given an array of 2 or more non-negative integers.
>
> Write a script to find out the smallest slice, i.e. contiguous
> subarray of the original array, having the degree of the given array.
>
>> The degree of an array is the maximum frequency of an element in the
>> array.
>
> **Example 1**
>
>     Input: @array = (1, 3, 3, 2)
>     Output: (3, 3)
>
>     The degree of the given array is 2.
>     The possible subarrays having the degree 2 are as below:
>     (3, 3)
>     (1, 3, 3)
>     (3, 3, 2)
>     (1, 3, 3, 2)
>
>     And the smallest of all is (3, 3).
>
> **Example 2**
>
>     Input: @array = (1, 2, 1, 3)
>     Output: (1, 2, 1)
>
> **Example 3**
>
>     Input: @array = (1, 3, 2, 1, 2)
>     Output: (2, 1, 2)
>
> **Example 4**
>
>     Input: @array = (1, 1, 2, 3, 2)
>     Output: (1, 1)
>
> **Example 5**
>
>     Input: @array = (2, 1, 2, 1, 1)
>     Output: (1, 2, 1, 1)

# The questions

What to do in case there are two slices of the same minimal size? Like
`1 2`? I guess either one is fine.

# The solution

This was a challenging challenge. Kudos to [manwar][] for it!

Initially I thought about calculating the so-called *degree* and then
chopping the array from both ends until this degree drops down.

Alas, this requires taking care of a lot of possible corner cases. E.g.
consider the following example:

```
1 2 1 3 3 4 5 4
```

The degree is 2, held by `1`, `3`, and `4`. The shortest sequence is `3
3`, which appears in the middle, so it's "difficult" to reach if we just
apply the chopping algorithm describe above.

So I thought that it was time to get something *heavier* out, i.e. full
analysis parameters as we sweep throuth the whole array, keeping track
of all possible sub-arrays for each value appearing in the input array,
then choosing the best at the end.

Hence, we'll do this:

- keep track of statistics in a data structure for each distinct value
  we find data structure, with the following data inside:
    - first index where the item appears (`start`)
    - last index where the item appears (`stop`)
    - sub-array length (`length`, i.e. from `start` to `stop` included)
    - count of occurrences (`count`)
- keep track of a ladder of structures by the count of their items
  (which is a running total of the array degree as we go through the
  input array)
- for each pair of index/value:
    - create the structure and initialize its `start` and `count` if it
      does not exist yet
    - increase the `count` and move the structure up on the ladder
    - record the `stop` position and update the `length`

At the end of the iteration, we can look at the top of the ladder and
order them by increasing `length`, taking the first one. Its `start` and
`stop` indexes will allow us extracting the right slice from the input
array.

OK, enough talking, shut the mouth up and show us the code! This time
[Perl][] goes first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @array = @ARGV ? @ARGV : qw< 2 1 2 1 1 > ;
my $ad = array_degree(\@array);
{local $" = ', '; say "($ad->@*)"}

sub array_degree ($array) {
   my %data_for;
   my @letter_for = ({});
   for my $i (0 .. $array->$#*) {
      my $item = $array->[$i];
      my $data = $data_for{$item} //= { start => $i, count => 0 };
      $data->{stop} = $i;
      $data->{length} = 1 + $i - $data->{start};
      delete $letter_for[$data->{count}++]{$item};
      $letter_for[$data->{count}]{$item} = $data;
   }
   my ($best) = sort { $a->{length} <=> $b->{length} }
      values $letter_for[-1]->%*;
   return [$array->@[$best->{start} .. $best->{stop}]];
}
```

Translating this into [Raku][] was very pleasing as it keeps that
*perlish* sensation that I love in the two languages.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@array) {
   @array = 2, 1, 2, 1, 1 unless @array;
   my @ad = array-degree(@array);
   put '(', @ad.join(', '), ')';
}

sub array-degree (@array) {
   my %data-for;
   my @letter-for = {},;
   for @array.kv -> $i, $item {
      my $data = %data-for{$item} //= { start => $i, count => 0 };
      $data<stop> = $i;
      $data<length> = 1 + $i - $data<start>;
      @letter-for[$data<count>++]{$item}:delete;
      @letter-for[$data<count>]{$item} = $data;
   }
   my $best = @letter-for[*-1].values.sort({$^a<length> <=> $^b<length>})[0];
   return [@array[$best<start> .. $best<stop>]];
}
```

It helped that I did not have to *slip* or *flat* anything!

If you're curious about the `@letter_for`/`@letter-for` variables, it
comes from the fact that the items in the array might just as well be...
*items*, like letters or stuff. As long as they can be compared for
string equality (which happens implicitly when we use them as keys in a
hash), we're good to go with this solution.

Stay safe folks, cheers!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#189]: https://theweeklychallenge.org/blog/perl-weekly-challenge-189/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-189/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
