---
title: PWC205 - Maximum XOR
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#205][].
> Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to find the highest value obtained by XORing any two
> distinct members of the array.
>
> **Example 1**
>
>     Input: @array = (1,2,3,4,5,6,7)
>     Output: 7
>
>     The maximum result of 1 xor 6 = 7.
>
> **Example 2**
>
>     Input: @array = (2,4,1,3)
>     Output: 7
>
>     The maximum result of 4 xor 3 = 7.
>
> **Example 3**
>
>     Input: @array = (10,5,7,12,8)
>     Output: 15
>
>     The maximum result of 10 xor 5 = 15.

# The questions

Anything particular we should know about the input values, e.g.:

- maximum value (to account for big integers, in case)?
- negative values and their binary representation?

# The solution

We'll go for non-negative integers that fit whatever the language is
capable of supporting.

The idea is to build all possible pairs out of the input values,
calculate the XOR and take the maximum. This algorithm is $O(n^2)$ on
the size of the input array, which is kind of *meh* and I *suspect*
there must be a better way, but it's out of my reach at the moment.

In [Perl][], we iterate over the array in two nested loops, getting one
element from each loop's index:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental qw< bitwise signatures >;

say maximum_xor(@ARGV);

sub maximum_xor (@array) {
   my $max = 0;
   for my $i (0 .. $#array - 1) {
      for my $j ($i + 1 .. $#array) {
         my $xor = $array[$i] ^ $array[$j];
         $max = $xor if $xor > $max;
      }
   }
   return $max;
}
```

[Raku][] comes with a bit more batteries included, like a `combinations`
method for arrays that allows taking all possible pairs in a single
call; this allows us to pack everything in a single line.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put maximum-xor(@args) }

sub maximum-xor (@array) { @array .combinations(2) .map({[+^] $_}) .max }
```

The calculation of the XOR function is done at the risk of getting the
*line noise* mark that haunted [Perl][] for too long, but whatever. The
`map` takes each pair as input, available as `$_`; as it is a sequence,
it suffices to apply the hyperoperation to do the XOR over its two
elements.

Maybe this would be more readable:

```raku
sub maximum-xor (@a) { @a.combinations(2).map(->($x,$y){$x +^ $y}).max }
```

So there you go... if you find my code *hermetic*, it's because I wanted
it to be like that!

Stay safe and maximized!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#205]: https://theweeklychallenge.org/blog/perl-weekly-challenge-205/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-205/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
