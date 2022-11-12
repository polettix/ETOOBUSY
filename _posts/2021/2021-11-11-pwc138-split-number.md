---
title: PWC138 - Split Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-11-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#138][].
> Enjoy!

# The challenge

> You are given a perfect square.
>
> Write a script to figure out if the square root the given number is
> same as sum of 2 or more splits of the given number.
>
> **Example 1**
>
>     Input: $n = 81
>     Output: 1
>
>     Since, sqrt(81) = 8 + 1
>
> **Example 2**
>
>     Input: $n = 9801
>     Output: 1
>
>     Since, sqrt(9801) = 98 + 0 + 1
>
> **Example 3**
>
>     Input: $n = 36
>     Output: 0
>
>     Since, sqrt(36) != 3 + 6

# The questions

I'd ask what a *split* is exactly, although the examples allow to make
an educated guess about considering the decimal representation of the
number as a string, and splitting it into parts (two or more, as the
requirement goes).

# The solution

As it often happens, 1 is left out not because it's not a perfect square
(it is), nor because it can't be expressed in terms of sum of a split of
its square (it can), but because the split does not include at least two
parts. I guess this is fair for a *split*, less for the 1.

Life sucks, yes, but I'd like to remember that 1 is the first. Unless
you start counting from 0, of course.

Assuming that 1's shoulders are strong enough to be left out of this
lot, the splitting problem is a "solved" one, and I suspect in some past
weekly challenge too. Alas, my memory fails me in this, so I just
remember *how* to do it, without the possibility to tell *why* I know
it.

Let's assume that we have a string representation of a number and that
we split it digit by digit, e.g. integer 1296:

    1 | 2 | 9 | 6

To get all possible splits, it's sufficient to manipulate the different
"separator" characters above. As an example, if we remove the middle
one, we end up with:

    1 | 2   9 | 6

We then join together all sequences without a separator, obtaining
partition $(1, 29, 6)$ whose sum is 36. Which, by the way, makes 1296 a
match for our test, because $\sqrt{1296} = 36$, yay!

Now, how to generate all possible arrangements of separator characters?
The key here is to represent each position where a separator can appear
with its own bit: 0 means open, 1 means closed.

At this point, a starting string with $n$ characters will have $n - 1$
possible separators, represented as a sequence of $n - 1$ bits. Now...
it's sufficient to count from 1 (because there must be *at least* one
separator, by requirements) up to $2^n - 1$ and we will get all possible
arrangements. Neat!

Let's go [Perl][] first this time:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

sub split_number ($square) {
   my $root = int sqrt $square;
   die "invalid input <$square>: not a square"
     unless $root * $root == $square;
   return 1 if $root =~ m{\A 9+ \z}mxs;
   my ($first, @digits) = split m{}mxs, $square;
   my $n_separators = @digits;
   for my $i (1 .. 2**$n_separators - 1) {
      my @split = $first;
      my @separators = split m{}mxs, sprintf "%0${n_separators}b", $i;
      for my $j (0 .. $#separators) {
         if ($separators[$j]) { push @split, $digits[$j] }
         else                 { $split[-1] .= $digits[$j] }
      }
      return 1 if sum(@split) == $root;
   } ## end for my $i (1 .. 2**$n_separators...)
   return 0;
} ## end sub split_number ($square)

if (@ARGV) { say split_number($ARGV[0]) }
else {
   split_number($_ * $_) && say $_*$_ for 1 .. 1000;
}
```

I knew it. You noticed this line:

```perl
   return 1 if $root =~ m{\A 9+ \z}mxs;
```

Why is that? It turns out that squares of sequences of 9 will *always*
match the requirements, so why bother doing the splits? If you want a
concise proof, just read on.

> Let's define our sequence of 9s as $9_k$:
> 
> $$
> 9_k \mathrel{\vcenter{:}}= \underbrace{9..9}_k \equiv 9 \sum_{i=0}^{k-1}10^i \equiv10^k-1
> $$
> 
> Now, let's square it and see what we obtain:
> 
> $$
> \begin{align}
> (9_k)^2 &= (10^k-1)^2\\
> &=10^{2k}-2 \cdot 10^k+1 \\
> &= (10^k-2) \cdot 10^k+1 \\
> &=\underbrace{9..9}_{k-1}8 \cdot 10^k+1 \\
> &= \underbrace{9..9}_{k-1}8\underbrace{0..0}_k + 1 \\
> &= \underbrace{9..9}_{k-1}8\underbrace{0..0}_{k-1}1
> \end{align}
> $$
> 
> Now let's consider the following split where each 0 is taken
> individually:
> 
> $$
> \begin{align}
> \underbrace{9..9}_{k-1}8 + \underbrace{0 + 0 + ... + 0}_{k-1} +1 &= \underbrace{9..9}_{k-1}8+1 \\
> &= \underbrace{9..9}_k \\
> &= 9_k
> \end{align}
> $$
>
> So, $(9_k)^2$ is indeed a square with a split of 2 or more parts whose
> sum amounts to its root $9_k$.

[Raku][] time now:

```raku
#!/usr/bin/env raku
use v6;

sub split-number (Int:D $square) {
   my $root = $square.sqrt.Int;
   die "invalid input <$square>: not a square"
     unless $root * $root == $square;
   return 1 if $root ~~ /^ 9+ $/;
   my ($first, @digits) = $square.comb: /./;
   my $n-separators = @digits.elems;
   for 1 ..^ 2**$n-separators -> $i {
      my @split = $first,;
      my @separators = $i.base(2).comb: /./;
      @separators.unshift: 0 while @separators.elems < $n-separators;
      for 0 .. @separators.end -> $j {
         if @separators[$j] > 0 { @split.push: @digits[$j]   }
         else                   { @split[*-1] ~= @digits[$j] }
      }
      return 1 if @split.sum == $root;
   } ## end for my $i (1 .. 2**$n_separators...)
   return 0;
}

sub MAIN (*@args) {
   if @args { split-number(@args[0]).put }
   else {
      my @sequence = (1...Inf).map({$_**2}).grep({split-number($_) > 0});
      @sequence[0..^10].join(', ').put;
   }
}
```

This translation from [Perl][] proved to be trickier than expected.
Evaluating an array in "scalar context" does not do what I'm used to in
[Perl][], which hit me a couple of times. Additionally, the whole
`sprintf` stuff in [Perl][] was not working and I had to use a
combination of base change, `comb`ing and putting enough leading 0
characters in the result to match the needed amount of bits. Whew!

I guess this is it for this entry... thanks and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#138]: https://theweeklychallenge.org/blog/perl-weekly-challenge-138/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-138/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
