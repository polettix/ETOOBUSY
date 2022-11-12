---
title: PWC119 - Sequence without 1 on 1
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-01 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#119][].
> Enjoy!

# The challenge


> Write a script to generate sequence starting at 1. Consider the
> increasing sequence of integers which contain only 1’s, 2’s and 3’s,
> and do not have any doublets of 1’s like below. Please accept a
> positive integer `$N` and print the `$Nth` term in the generated
> sequence.
>
>> 1, 2, 3, 12, 13, 21, 22, 23, 31, 32, 33, 121, 122, 123, 131, …
>
> **Example**
>
>     Input: $N = 5
>     Output: 13
>     
>     Input: $N = 10
>     Output: 32
>     
>     Input: $N = 60
>     Output: 2223

# The questions

As a meta-question, I wonder if there's a hidden scheme in pairing this
challenge with the one on nibbles (i.e. "different aggregations of
consecutive bits"). Anyway.

The description of the sequence and how to build it seems fine: we're
assuming that we will consider any positional representation of
integers, in a base that contains *at least* symbols `1`, `2`, and `3`;
this provides an ordering for any two candidates and we're fine. We're
also told to start counting from `1`, which is the value corresponding
to an input `$N` equal to `1`.

The definition of *doublet* is a bit fuzzy to me, but English is
definitely **not** my mother language. Anyway, seeing that `121` and
`131` are in the list but `11`, `111`, and `112` are not, I guess we're
dealing with *two consecutive `1` digits*.

# The solution

This is my first stab at the problem, coded in [Raku][]. I'm sticking to
a representation of the "numbers" that is completely held as strings.
It's basically a way of counting in base 3, but not really:

```raku
#!/usr/bin/env raku
use v6;

sub sequence-without-one-on-one (Int:D $N is copy where 0 < *) {
   my $candidate = '1';
   while ($N > 1) {
      $candidate = succ-of($candidate);
      --$N if $candidate !~~ /11/;
   }
   return $candidate;
}

sub succ-of (Str:D $x) {
   my ($carry, @succ) = (True, $x.comb.reverse>>.Int.Slip);
   for @succ -> $item is rw {
      ($item, $carry) = ($item + 1, False) if $carry;
      ($item, $carry) = (1        , True)  if $item > 3;
      last unless $carry;
   }
   @succ.push: 1 if $carry;
   @succ.reverse.join: '';
}

my @inputs = @*ARGS ?? @*ARGS !! qw< 5 10 60 >;
sequence-without-one-on-one(+$_).put for @inputs;
```

The `succ-of` function takes an input and computes its successor in the
`1`/`2`/`3` restricted world. It does not care about the *doublets*,
they are filtered out in `sequence-without-...`, that also does the
counting. Choices.

As I was saying, it's *almost* like counting in base 3, but not really.
We might map `1` to `0`, then `2` to `1`, then `3` to `1` and have a
valid base-3 representation for each valid sequence, including those
with *doublets*. But that would make it hard to generate `23` and `123`
by simple counting, because they would map to `12` and `012`
respectively, which are the same number in base 3. Ouch.

But this does not mean that we cannot use a counting approach that
relies on native integers, instead of rolling our own like in the
example above.

In particular, any base from 4 on contains all the symbols that we need;
needless to say, base 4 is the one that leads to the *least waste*
because it only has one additional digit `0` that we cannot admit, so in
general there will be less skipping in this base. This brings us to
this alternative implementation of `succ-for`:

```raku
sub succ-of (Str:D $x) {
   my $X = $x.parse-base(4);
   loop {
      my $candidate = (++$X).base(4);
      return $candidate if $candidate !~~ /0/;
   }
}
```

I don't know if it's more efficient but I think it makes it easier to
see what's going on (the initial `parse-base(4)` is just there for
efficiency, having `my $X = +$x` would work as well, although in this
case I would need to change the regular expression test in the loop).

Let's now turn to [Perl][]. We can code pretty much the same solution,
only we need to provide an implementation for the change of base between
4 and 10:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub sequence_without_1_on_1 ($N) {
   my $candidate = 1;
   while ($N > 1) {
      $candidate = succ_of($candidate);
      --$N if $candidate !~ m{11}mxs;
   }
   return $candidate;
}

sub succ_of ($x) {
   $x = base_4_to_10($x);
   while ('necessary') {
      my $candidate = base_10_to_4(++$x);
      return $candidate if $candidate !~ m{0}mxs;
   }
}

sub base_4_to_10 ($x) {
   my $X = 0;
   for my $digit (split m{}mxs, $x) {
      $X = ($X << 2) + $digit;
   }
   return $X;
}

sub base_10_to_4 ($x) {
   my @digits;
   while ($x) {
      push @digits, $x & 0b11;
      $x >>= 2;
   }
   return join '', @digits ? reverse @digits : 0;
}

my @inputs = @ARGV ? @ARGV : qw< 5 10 60 >;
say sequence_without_1_on_1($_) for @inputs;
```

I'm taking advantage of [Perl][]'s laxer approach to variables, e.g. by
reusing variable `$x` in `succ_of` instead of taking a new one. No big
deal, actually; this goes at the expense of readability, so I'm not sure
it's a win overall.

The conversion functions take advantage of the fact that 4 is a multiple
of 2, hence it's easy to use bit fiddling to do the conversions. This is
also why I have the *meta*-question in the previous section - both
solutions rely on bit fiddling in the end!

Well... I guess it's everything at this point! Stay safe and have fun!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#119]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-119/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-119/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
