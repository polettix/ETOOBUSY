---
title: PWC224 - Additive Number
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-07-07 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#224][].
> Enjoy!

# The challenge

> You are given a string containing digits 0-9 only.
>
> Write a script to find out if the given string is additive number. An
> additive number is a string whose digits can form an additive sequence.
>
>     A valid additive sequence should contain at least 3 numbers. Except
>     the first 2 numbers, each subsequent number in the sequence must be
>     the sum of the preceding two.
>
> **Example 1:**
>
>     Input: $string = "112358"
>     Output: true
>
>     The additive sequence can be created using the given string digits: 1,1,2,3,5,8
>     1 + 1 => 2
>     1 + 2 => 3
>     2 + 3 => 5
>     3 + 5 => 8
>
> **Example 2:**
>
>     Input: $string = "12345"
>     Output: false
>
>     No additive sequence can be created using the given string digits.
>
> **Example 3:**
>
>     Input: $string = "199100199"
>     Output: true
>
>     The additive sequence can be created using the given string digits: 1,99,100,199
>      1 +  99 => 100
>     99 + 100 => 199

# The questions

What's a *number* exactly? I mean, '000` is a perfectly valid string of
allowed digits, but can it be considered a *number*? I'll assume that the
behaviour of the solution is *undefined* when leading zeros are involved.

Anyway, I'd lean to say that `000` should not fit.

# The solution

In lack of any clever idea, we'll just go *brute force*. There are actually
only two parameters that we can play with, namely the widths of the two
starting numbers; everything goes from there afterwards.

So here we go with [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say is_additive_number(shift) ? 'true' : 'false';

sub is_additive_number ($string) {
   my $len = length($string);
   return unless $len > 2;
   for my $l1 (1 .. ($len - 2)) {
      for my $l2 (1 .. ($len - $l1 - 1)) {
         return 1 if is_additive_number_arrangement($string, $l1, $l2);
      }
   }
   return;
}

sub is_additive_number_arrangement ($string, $l1, $l2) {
   my $ls = length($string);
   my @v = (substr($string, 0, $l1), substr($string, $l1, $l2));
   my $i = $l1 + $l2;
   while ($i < $ls) {
      my $v = shift @v;
      $v += $v[0];
      my $lv = length($v);
      return if $lv > $ls - $i;
      return if substr($string, $i, $lv) ne $v;
      push @v, $v;
      $i += $lv;
   }
   return 1;
}
```

The `is_additive_number()` function contains the *search* algorithm,
iterating through all possible arrangements of the two initial numbers
lengths, until one is good for our purposes or no more are available.

The actual check is encapsulated into `is_additive_number_arrangement()`,
which just does the check for a fixed size of the first two numbers. The
implementation is not particularly exciting.

The [Raku][] alternative is as lazy as it can be a straight translation from
the [Perl][] original:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($string) { put is-additive-number($string) }

multi sub is-additive-number ($string --> Bool) {
   my $len = $string.chars;
   return False unless $len > 2;
   for 1 .. ($len - 2) -> $l1 {
      for 1 .. ($len - $l1 - 1) -> $l2 {
         return True if is-additive-number($string, $l1, $l2);
      }
   }
   return False;
}

multi sub is-additive-number ($string, $l1, $l2 --> Bool) {
   my $ls = $string.chars;
   my @v = $string.substr(0, $l1), $string.substr($l1, $l2);
   my $i = $l1 + $l2;
   while $i < $ls {
      my $v = @v.shift.Int;
      $v += @v[0].Int;
      $v = $v.Str;
      my $lv = $v.chars;
      return False if $lv > $ls - $i;
      return False if $string.substr($i, $lv) ne $v;
      @v.push: $v;
      $i += $lv;
   }
   return True;
}
```

I know that I'm supposed to print out *lowercase* `true` or `false`, but I
admit that I don't care too much!

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#224]: https://theweeklychallenge.org/blog/perl-weekly-challenge-224/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-224/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
