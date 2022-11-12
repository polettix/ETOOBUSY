---
title: PWC136 - Fibonacci Sequence
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-28 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #2][] from [The Weekly Challenge][]
> [#136][]. Enjoy!

# The challenge

> You are given a positive number `$n`.
> 
> Write a script to find how many different sequences you can create
> using Fibonacci numbers where the sum of unique numbers in each
> sequence are the same as the given number.
> 
>> Fibonacci Numbers: 1,2,3,5,8,13,21,34,55,89, …
> 
> **Example 1**
>
>     Input:  $n = 16
>     Output: 4
>
>     Reason: There are 4 possible sequences that can be created using Fibonacci numbers
>     i.e. (3 + 13), (1 + 2 + 13), (3 + 5 + 8) and (1 + 2 + 5 + 8).
>
> **Example 2**
>
>     Input:  $n = 9
>     Output: 2
>
>     Reason: There are 2 possible sequences that can be created using Fibonacci numbers
>     i.e. (1 + 3 + 5) and (1 + 8).
>
> **Example 3**
>
>     Input:  $n = 15
>     Output: 2
>
>     Reason: There are 2 possible sequences that can be created using Fibonacci numbers
>     i.e. (2 + 5 + 8) and (2 + 13).

# The questions

I have to admit that I sometimes don't understand the challenge test
*immediately*, and I thank the author for providing interesting
examples.

So in this case my question is: can we reuse whatever we conjured up for
[task 1 in PWC077][] and move on? Let's assume... yes!

# The solution

So... let's get our solution back from [Fibonacci Sum part 2][] and
adapt it a tiny bit to just *count* how many different alternatives we
have:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use English qw< -no_match_vars >;
use autodie;

main(shift || 1);

sub main {
   my ($n) = @_;

   # compute the "basic" Zeckendorf decomposition of $n
   my $lk = lekkerkerker($n);

   # compute a "reasonable" decomposition into possible non-overlapping
   # components
   my @components;
   for my $i (reverse 0 .. $#{$lk->{indexes}}) {
      my $index = $lk->{indexes}[$i];
      my $low_index = $i ? $lk->{indexes}[$i - 1] : 0;
      my $alts = alternatives($index, $low_index);
      push @components, $alts;
   }

   # compute all possible arrangements, reject those with overlaps and
   # print the others
   my $count = 0;
   nested_loops_recursive(
      \@components,
      sub {
         my %seen;
         my $sum = 0;
         for my $constituent (@_) {
            for my $i (@$constituent) {
               return if $seen{$i}++;
               my $fi = $lk->{fibo}[$i];
               $sum += $fi;
            }
         }
         die "sum mismatch ($sum vs $n)\n" unless $n == $sum;
         ++$count;
      }
   );

   say $count;
}

sub lekkerkerker {
   my ($n) = @_;
   my @fibo = (1, 2);
   push @fibo, $fibo[-2] + $fibo[-1] while $fibo[-1] < $n;
   my $i = $#fibo;
   my @indexes;
   while ($n > 0) {
      --$i while $fibo[$i] > $n;
      unshift @indexes, $i;
      $n -= $fibo[$i];
   }
   return {
      fibo => \@fibo,
      indexes => \@indexes,
   };
}

# split an input index into the Fibonacci array into possible alternative
# index sets representing the same Fibonacci number in alternative ways,
# down to a lower index $il
sub alternatives {
   my ($i, $il) = @_;
   my @item = ($i);
   my @retval = ([$i]);
   while ($i > $il + 1) {
      pop @item;
      push @item, $i - 1, $i - 2;
      push @retval, [@item];
      $i -= 2;
   }
   return \@retval;
}

# simplified from
# https://github.polettix.it/ETOOBUSY/2020/07/28/nested-loops-recursive/
sub nested_loops_recursive {
   my ($dims, $cb, $accumulator) = @_;
   $accumulator = [] unless defined $accumulator;
   my $level = @{$accumulator};
   if ($level == @{$dims}) { # fire callback!
      $cb->(@{$accumulator});
      return;
   }
   for my $item (@{$dims->[$level]}) {
      push @{$accumulator}, $item;
      nested_loops_recursive($dims, $cb, $accumulator);
      pop @{$accumulator};
   }
   return;
}
```

This is what I call reuse!

Going [Raku][] requires some translation and making sure to *listify*
arrays when needed, but nothing that we cannot address:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Int:D $n where * > 0 = 1) {
   # compute the "basic" Zeckendorf decomposition of $n
   my %lk = lekkerkerker($n);

   # compute a "reasonable" decomposition into possible non-overlapping
   # components
   my @components;
   for (0 .. %lk<indexes>.end).reverse -> $i {
      my $index = %lk<indexes>[$i];
      my $low_index = $i ?? %lk<indexes>[$i - 1] !! 0;
      my @alts = alternatives($index, $low_index);
      @components.push: @alts;
   }

   # compute all possible arrangements, reject those with overlaps and
   # print the others
   my $count = 0;
   nested_loops_recursive(
      @components,
      sub (*@stuff) {
         my %seen;
         my $sum = 0;
         for @stuff -> $constituent {
            for @$constituent -> $i {
               return if %seen{$i}++;
               my $fi = %lk<fibo>[$i];
               $sum += $fi;
            }
         }
         die "sum mismatch ($sum vs $n)\n" unless $n == $sum;
         ++$count;
      }
   );
   $count.put;
}

sub lekkerkerker (Int:D $n is copy) {
   my @fibo = 1, 2;
   push @fibo, @fibo[*-2] + @fibo[*-1] while @fibo[*-1] < $n;
   my $i = @fibo.end;
   my @indexes;
   while $n > 0 {
      --$i while @fibo[$i] > $n;
      @indexes.unshift: $i;
      $n -= @fibo[$i];
   }
   return (
      fibo => @fibo,
      indexes => @indexes,
   ).hash;
}

sub alternatives (Int:D $i is copy where * >= 0, Int:D $il where * >= 0) {
   my @item = $i;
   my @retval = [$i],;
   while $i > $il + 1 {
      @item.pop;
      @item.push: $i - 1;
      @item.push: $i - 2;
      @retval.push: [@item.List];
      $i -= 2;
   }
   return @retval;
}

sub nested_loops_recursive (@dims, &cb, @accumulator = []) {
   my $level = @accumulator.elems;
   if $level == @dims.elems { # fire callback!
      &cb(@accumulator);
      return;
   }
   for @dims[$level].List -> $item {
      @accumulator.push: $item;
      nested_loops_recursive(@dims, &cb, @accumulator);
      @accumulator.pop;
   }
   return;
}
```

As anticipated, it's mostly a translation, with due differences.

Stay safe everybody!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#136]: https://theweeklychallenge.org/blog/perl-weekly-challenge-136/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-136/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[task 1 in PWC077]: https://theweeklychallenge.org/blog/perl-weekly-challenge-077/#TASK1
[Fibonacci Sum part 2]: {{ '/2020/09/17/pwc077-fibonacci-sum-2/' | prepend: site.baseurl }}
