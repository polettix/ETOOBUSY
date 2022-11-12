---
title: PWC131 - Consecutive Arrays
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#131][]. Enjoy!

# The challenge


> You are given a sorted list of unique positive integers.
> 
> Write a script to return list of arrays where the arrays are
> consecutive integers.
>
> **Example 1:**
>
>     Input:  (1, 2, 3, 6, 7, 8, 9)
>     Output: ([1, 2, 3], [6, 7, 8, 9])
>
> **Example 2:**
>
>     Input:  (11, 12, 14, 17, 18, 19)
>     Output: ([11, 12], [14], [17, 18, 19])
>
> **Example 3:**
>
>     Input:  (2, 4, 6, 8)
>     Output: ([2], [4], [6], [8])
>
> **Example 4:**
>
>     Input:  (1, 2, 3, 4, 5)
>     Output: ([1, 2, 3, 4, 5])

# The questions

It seems that all examples confirm that it's indeed 

# The solution

This challenge is not particularly *challenging*, except that it is.

I mean, it's clear that there **must** be some clever, instant solution
to this, because the challenge author `Mark Anderson` is quite fluent
with [Raku][] and surely there is an idiom to do this!

Alas, nothing comes to *my* mind, so here's the [Raku][] solution:

```raku
#!/usr/bin/env raku
use v6;
sub consecutive-arrays (*@args) {
   return unless @args;
   my $previous = @args[0];
   my @retval;
   for @args -> $n {
      @retval.push: [] if $n != $previous + 1;
      @retval[*-1].push: $n;
      $previous = $n;
   }
   return @retval.List;
}
sub MAIN (*@args) {
   @args = 1, 2, 3, 6, 7, 8, 9 unless @args;
   consecutive-arrays(@args).say;
}
```

[Perl][] solution, written *after* the [Raku][] one:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
sub consecutive_arrays (@args) {
   return unless @args;
   my $previous = $args[0];
   my @retval;
   for my $n (@args) {
      push @retval, [] if $n != $previous + 1;
      push $retval[-1]->@*, $n;
      $previous = $n;
   }
   return @retval;
}
my @input = @ARGV ? @ARGV : qw< 1 2 3 6 7 8 9 >;
my @output = consecutive_arrays(@input);
say '(', join(', ', map { local $" = ', '; "[$_->@*]" } @output), ')';
```

It's not only mostly the same, but it's actually how I would have coded
it in the first place were I to start with [Perl][] directly. Which, I
think, is mostly due to the fact that I internally *think in [Perl][]*
and then apply that thinking in [Raku][], instead of finding out what
[Raku][] can do to help in the specific situation.

[The Weekly Challenge]: https://theweeklychallenge.org/
[#131]: https://theweeklychallenge.org/blog/perl-weekly-challenge-131/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-131/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
