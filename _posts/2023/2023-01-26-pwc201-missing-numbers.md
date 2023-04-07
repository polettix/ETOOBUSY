---
title: PWC201 - Missing Numbers
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-01-26 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#201][]. Enjoy!

# The challenge

> You are given an array of unique numbers.
>
> Write a script to find out all missing numbers in the range `0..$n`
> where `$n` is the array size.
>
> **Example 1**
>
>     Input: @array = (0,1,3)
>     Output: 2
>
>     The array size i.e. total element count is 3, so the range is 0..3.
>     The missing number is 2 in the given array.
>     
> **Example 2**
>
>     Input: @array = (0,1)
>     Output: 2
>
>     The array size is 2, therefore the range is 0..2.
>     The missing number is 2.

# The questions

Is there a range of allowed values for the numbers in the array? Are
they integers?

# The solution

We're turning the array into a set to make checking the numbers in the
range efficient:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { .put for missing-numbers(@args) }

sub missing-numbers (@array) {
   my $present = @array».Str.Set;
   return [(0 .. @array.elems).grep({ $_.Str ∉ $present })];
}
```

I struggled a bit before realizing that I had to turn everything to
strings, just to be on the safe side.

The [Perl][] version is just a little at a lower level:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say for missing_numbers(@ARGV);

sub missing_numbers (@array) {
   my %set = map { $_ => 1 } @array;
   grep { ! exists($set{$_}) } 0 .. @array;
}
```

That's all folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#201]: https://theweeklychallenge.org/blog/perl-weekly-challenge-201/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-201/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
