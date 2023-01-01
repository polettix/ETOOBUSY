---
title: PWC184 - Split Array
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-30 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#184][].
> Enjoy!

# The challenge

> You are given list of strings containing `0-9` and `a-z` separated by
> `space` only.
>
> Write a script to split the data into two arrays, one for integers and
> one for alphabets only.
>
> **Example 1**
>
>     Input: @list = ( 'a 1 2 b 0', '3 c 4 d')
>     Output: [[1,2,0], [3,4]] and [['a','b'], ['c','d']]
>
> **Example 2**
>
>     Input: @list = ( '1 2', 'p q r', 's 3', '4 5 t')
>     Output: [[1,2], [3], [4,5]] and [['p','q','r'], ['s'], ['t']]

# The questions

The second example helped. I initially thought that we were supposed to
include empty sub-arrays, but this does not seem to be the case.

I'll also assume that it's either digits or letters.

# The solution

This will be done just plainly. Iterate through all input strings, split
them on spaces and decide where to put the characters (digits or
letters).

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Data::Dumper;

my @l = ('1 2', 'p q r', 's 3', '4 5 t');
say Dumper([split_array(@l)]);

sub split_array (@list) {
   my (@digits, @letters);
   for my $item (@list) {
      my (@ds, @ls);
      for my $char (split m{\s+}mxs, $item) {
         if ($char =~ m{\d}mxs) { push @ds, $char }
         else                   { push @ls, $char }
      }
      push @digits,  \@ds if @ds;
      push @letters, \@ls if @ls;
   }
   return (\@digits, \@letters);
}
```

We're going for a straight translation in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @l = '1 2', 'p q r', 's 3', '4 5 t';
   my ($digits, $letters) = split-array(@l);
   say $digits;
   say $letters;
}

sub split-array (@list) {
   my (@digits, @letters);
   for @list -> $item {
      my (@ds, @ls);
      for $item.comb(/\S/) -> $char {
         if ($char ~~ /\d/) { @ds.push: $char }
         else               { @ls.push: $char }
      }
      @digits.push: @ds if @ds;
      @letters.push: @ls if @ls;
   }
   return (@digits, @letters);
}
```

Well... I guess this is everything, stay safe people!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#184]: https://theweeklychallenge.org/blog/perl-weekly-challenge-184/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-184/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
