---
title: PWC189 - Greater Character
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-11-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#189][]. Enjoy!

# The challenge

> You are given an array of characters (a..z) and a target character.
>
> Write a script to find out the smallest character in the given array
> lexicographically greater than the target character.
>
> **Example 1**
>
>     Input: @array = qw/e m u g/, $target = 'b'
>     Output: e
>
> **Example 2**
>
>     Input: @array = qw/d c e f/, $target = 'a'
>     Output: c
>
> **Example 3**
>
>     Input: @array = qw/j a r/, $target = 'o'
>     Output: r
>
> **Example 4**
>
>     Input: @array = qw/d c a f/, $target = 'a'
>     Output: c
>
> **Example 5**
>
>     Input: @array = qw/t g a l/, $target = 'v'
>     Output: v

# The questions

Can we assume that the target character is one of the ones inside the
a..z range?

# The solution

We will sweep the whole array in search for the character that is both
greater than the target and *minimum*.

Well, not necessarily the whole array, because if we hit the character
*immediately following* the character, we're not going to find anything
lower, so we can just stop looking for something different.

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($target, *@array) { put greater-character(@array, $target) }

sub greater-character (@array, $target) {
   (my $after-target = $target)++;
   my $retval = Nil;
   for @array -> $char {
      next unless $char gt $target;
      $retval = $char if !defined($retval) || $char le $retval;
      last if $retval eq $after-target;
   }
   return $retval;
}
```

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $target = shift;
say greater_character([@ARGV], $target);

sub greater_character ($array, $target) {
   (my $after_target = $target)++;
   my $retval = undef;
   for my $char ($array->@*) {
      next unless $char gt $target;
      $retval //= $char;
      $retval = $char if !defined($retval) || $char le $retval;
      last if $retval eq $after_target;
   }
   return $retval;
}
```

We might also return `Nil`/`undef` if the target character is `z`,
right?

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#189]: https://theweeklychallenge.org/blog/perl-weekly-challenge-189/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-189/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
