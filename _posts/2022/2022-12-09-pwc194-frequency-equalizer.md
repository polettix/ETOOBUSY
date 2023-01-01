---
title: PWC194 - Frequency Equalizer
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#194][].
> Enjoy!

# The challenge

> You are given a string made of alphabetic characters only, a-z.
>
> Write a script to determine whether removing only one character can
> make the frequency of the remaining characters the same.
>
> **Example 1:**
>
>     Input: $s = 'abbc'
>     Output: 1 since removing one alphabet 'b' will give us 'abc' where
>     each alphabet frequency is the same.
>
> **Example 2:**
>
>     Input: $s = 'xyzyyxz'
>     Output: 1 since removing 'y' will give us 'xzyyxz'.
>
> **Example 3:**
>
>     Input: $s = 'xzxz'
>     Output: 0 since removing any one alphabet would not give us string
>     with same frequency alphabet.

# The questions

I guess that *frequency* is the amount of times that each character
appears in the string.


# The solution

This is an interesting challenge, because it fooled me into thinking
it's utterly simple in the beginning.

I mean, it's simple, but not *that* simple.

The requested condition is only true if all characters have the same
exact number of occurrences, except exactly one single character which
occurs one time more than the others. All in all, it's a matter of
counting things.

So we're doing things in two passes:

- in the first pass, we count the occurrences of each character;
- in the second pass, we count how many times each occurrence *occurs*.

At the end of the second pass, our *true* condition is that:

- there are only two different values for occurrences;
- the two occurrences value differ by 1;
- the higher value is counted only once (corresponding to one single
  character occurring that amount of times)

OK, this is probably best expressed in [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

@ARGV = qw< abbc xyzyyxz xzxz > unless @ARGV;
say frequency_equalizer($_) . " -> $_" for @ARGV;

sub frequency_equalizer ($string) {
   my (%first_counter, %second_counter);
   ++$first_counter{substr($string, $_, 1)} for 0 .. length($string) - 1;
   ++$second_counter{$_} for values %first_counter;
   return 0 if scalar(keys %second_counter) != 2;
   my ($k1, $v1, $k2, $v2) = %second_counter;
   ($k1, $v1, $k2, $v2) = ($k2, $v2, $k1, $v1) if $k1 > $k2;
   return 1 if $v2 == 1 && $k2 - $k1 == 1;
   return 0;
}
```

I mean, it's better than pseudocode.

I cheated a bit and did the minimum amount of tweaks to adapt it to
[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@ARGV) {
   @ARGV = < abbc xyzyyxz xzxz > unless @ARGV;
   put "{frequency-equalizer($_)} -> $_" for @ARGV;
}

sub frequency-equalizer ($string) {
   my (%first_counter, %second_counter);
   ++%first_counter{$string.substr($_, 1)} for ^$string.chars;
   ++%second_counter{$_} for %first_counter.values;
   return 0 if %second_counter.elems != 2;
   my ($k1, $v1, $k2, $v2) = %second_counter.kv;
   ($k1, $v1, $k2, $v2) = $k2, $v2, $k1, $v1 if $k1 > $k2;
   return 1 if $v2 == 1 && $k2 - $k1 == 1;
   return 0;
}
```

I guess this is it, [STRIKE THE EARTH!][df]

[The Weekly Challenge]: https://theweeklychallenge.org/
[#194]: https://theweeklychallenge.org/blog/perl-weekly-challenge-194/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-194/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[df]: https://www.bay12games.com/dwarves/
