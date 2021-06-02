---
title: PWC115 - Largest Multiple
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-03 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#115][].
> Enjoy!

# The challenge

> You are given a list of positive integers (0-9), single digit.
>
> Write a script to find the largest multiple of 2 that can be formed from the list.
>
> **Examples**
>
>     Input: @N = (1, 0, 2, 6)
>     Output: 6210
>
>     Input: @N = (1, 4, 2, 8)
>     Output: 8412
>
>     Input: @N = (4, 1, 7, 6)
>     Output: 7614

# The questions

Well... there are a few nitpicks:

- let's say we're focusing on single-digit inputs, not necessarily
  *positive* (or `0` would be out of the game)
- let's also assume that there will *always* be an even element in the
  list!

# The solution

This is the solution in [Perl][]:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub largest_multiple (@N) {
   @N = sort { $a <=> $b } @N;
   for my $i (0 .. $#N) {
      if ($N[$i] % 2 == 0) {
         my ($last) = splice @N, $i, 1;
         return join '', reverse(@N), $last;
      }
   }
   return;
}

my @inputs = @ARGV ? @ARGV : qw< 1 0 2 6 >;
say largest_multiple(@inputs);
```

We first sort the list bottom to top, then extract the first even item
we find. What is left will have to be reversed (so that we can find the
*largest*) and that even item put at the end. Yay!

This is the [Raku][] version:

```raku
#!/usr/bin/env raku
use v6;

sub largest-multiple (@N is copy) {
   @N = @N.sort: {$^a leg $^b};
   for 0 ..^ @N.elems -> $i {
      next if @N[$i] % 2;
      @N.unshift(@N.splice($i, 1).Slip);
      return @N.reverse.join('');
   }
   return;
}

sub MAIN (*@inputs is copy) {
   @inputs = < 1 0 2 6 > unless @inputs.elems;
   say largest-multiple(@inputs);
}
```

That's all folks!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#115]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-115/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-115/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
