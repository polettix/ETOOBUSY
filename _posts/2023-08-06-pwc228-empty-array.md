---
title: PWC228 - Empty Array
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-08-06 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#228][].
> Enjoy!

# The challenge

> You are given an array of integers in which all elements are unique.
>
> Write a script to perform the following operations until the array is
> empty and return the total count of operations.
>
> If the first element is the smallest then remove it otherwise move it
> to the end.
>
> **Example 1**
>
>     Input: @int = (3, 4, 2)
>     Ouput: 5
>
>     Operation 1: move 3 to the end: (4, 2, 3)
>     Operation 2: move 4 to the end: (2, 3, 4)
>     Operation 3: remove element 2: (3, 4)
>     Operation 4: remove element 3: (4)
>     Operation 5: remove element 4: ()
>
> **Example 2**
>
>     Input: @int = (1, 2, 3)
>     Ouput: 3
>
>     Operation 1: remove element 1: (2, 3)
>     Operation 2: remove element 2: (3)
>     Operation 3: remove element 3: ()

# The questions

Alas, this time no question, apart from lazyness: how big do we expect
this array to be? Let's assume that it's not too big...

# The solution

This challenge has all the looks of something with a clever solution,
but it didn't dawn on me so here we are with the laziest solution
possible.

We first sort the array, so that we have a reference of when an item can
get out of the main one. As soon as we find the right element, we just
ditch it from both arrays; otherwise we do the cycling trick on the main
one and move on.

[Perl][] goes first:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say empty_array(@ARGV);

sub empty_array (@ints) {
   my @sorted = sort { $a <=> $b } @ints;
   my $n = 0;
   while (@ints) {
      my $item = shift @ints;
      if ($item == $sorted[0]) { shift @sorted     }
      else                     { push @ints, $item }
      ++$n;
   }
   return $n;
}
```

[Raku][] is pretty much the translation:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put empty-array(@args».Int) }

sub empty-array (@ints is copy) {
   my @sorted = @ints.sort;
   my $n = 0;
   while @ints {
      my $item = @ints.shift;
      if $item == @sorted[0] { @sorted.shift     }
      else                   { @ints.push: $item }
      ++$n;
   }
   return $n;
}
```

Stay safe and cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#228]: https://theweeklychallenge.org/blog/perl-weekly-challenge-228/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-228/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
