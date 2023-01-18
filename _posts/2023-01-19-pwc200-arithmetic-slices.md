---
title: PWC200 - Arithmetic Slices
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-01-19 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#200][]. Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find out all `Arithmetic Slices` for the given array
> of integers.
>
>> An integer array is called arithmetic if it has at least 3 elements
>> and the differences between any three consecutive elements are the
>> same.
>
> **Example 1**
>
>     Input: @array = (1,2,3,4)
>     Output: (1,2,3), (2,3,4), (1,2,3,4)
>
> **Example 2**
>
>     Input: @array = (2)
>     Output: () as no slice found.

# The questions

How does it feel to have arrived to 200 weeks?!? Congratulations
[manwar][], you made it!!!

# The solution

Each new item in a sequence triggers the generation of a group of
elements with all previous elements... So [Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@a) {
   put arithmetic-slices(@a ?? @a !! <1 2 3 4>)
      .map({ '(' ~ .join(',') ~ ')' }).join(', ');
}

sub arithmetic-slices (@array) {
   return if @array < 3;
   my $current-rate = @array[1] - @array[0]; # this keeps the growth rate
   my $run-length = 1; # this tracks whether we're emitting
   return [
      gather for 2 ..^ @array -> $i {
         my $delta = @array[$i] - @array[$i - 1];
         if $current-rate == $delta {
            ++$run-length;
            take [ @array[($i - $_) .. $i].Slip ] for 2 .. $run-length;
         }
         else {
            $current-rate = $delta;
            $run-length = 1;
         }
      }
   ];
}
```

[Perl][]'s version is pretty much the same:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say join ', ', map { '(' . join(',', $_->@*) . ')' }
   arithmetic_slices(@ARGV ? @ARGV : qw< 1 2 3 4 >);

sub arithmetic_slices (@array) {
   return if @array < 3;
   my @retval;
   my $current_rate = $array[1] - $array[0];
   my $run_length = 1;
   for my $i (2 .. $#array) {
      my $delta = $array[$i] - $array[$i - 1];
      if ($current_rate == $delta) {
         ++$run_length;
         push @retval, [ @array[($i - $_) .. $i] ] for 2 .. $run_length;
      }
      else {
         $current_rate = $delta;
         $run_length = 1;
      }
   }
   return @retval;
}
```

Cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#200]: https://theweeklychallenge.org/blog/perl-weekly-challenge-200/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-200/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
