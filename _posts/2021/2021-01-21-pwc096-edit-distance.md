---
title: PWC096 - Edit Distance
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-21 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#096][].
> Enjoy!

# The challenge

> You are given two strings `$S1` and `$S2`.
>
> Write a script to find out the minimum operations required to convert
> `$S1` into `$S2`. The operations can be insert, remove or replace a
> character. Please check out [Wikipedia page][ed] for more information.

# The questions

To be honest, no questions here. The link to the [Wikipedia page][ed]
basically tells everything we need to know, so... we're ready.

Except that... is it fine to raise an exception if the input is
undefined? 🤓

# The solution

Oh, the joys of reuse! I knew that coding the algorithm in [Levenshtein
distance - Iterative with two matrix rows][ld] would pay off at some
time!

So I went to [cglib][], selected [Levenshtein.pm][] and *presto!* I had
a solution:

```perl
sub edit_distance ($S1, $S2) { return levenshtein($S1, $S2) }
```

Oh! You wanted to see the solution?!? Right...

```perl
# Wikipedia: .../Levenshtein_distance#Iterative_with_two_matrix_rows
sub levenshtein {
   my ($v, $s, $t) = ([0 .. length($_[0])], @_);
   for my $i (1 .. length($t)) {
      my $w = [$i];              # first "column" of full matrix
      for my $j (1 .. length($s)) {
         my ($D, $I, $S) = ($v->[$j] + 1, $w->[$j - 1] + 1, $v->[$j - 1]);
         $S++ if substr($s, $j - 1, 1) ne substr($t, $i - 1, 1);
         my $mDI = $I < $D ? $I : $D;    # min($D, $I);
         push @$w, ($S < $mDI ? $S : $mDI);    # min($S, min($D, $I))
      } ## end for my $j (1 .. length(...))
      $v = $w;    # "swap" and prepare for nest iteration
   } ## end for my $i (1 .. length(...))
   return $v->[-1];
} ## end sub levenshtein ($s, $t)
```

It's basically a direct implementation of the algorithm in the Wikipedia
page, so nothing to add to it.

If you're curious about the whole program, here it is:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

# Wikipedia: .../Levenshtein_distance#Iterative_with_two_matrix_rows
sub levenshtein {
   my ($v, $s, $t) = ([0 .. length($_[0])], @_);
   for my $i (1 .. length($t)) {
      my $w = [$i];              # first "column" of full matrix
      for my $j (1 .. length($s)) {
         my ($D, $I, $S) = ($v->[$j] + 1, $w->[$j - 1] + 1, $v->[$j - 1]);
         $S++ if substr($s, $j - 1, 1) ne substr($t, $i - 1, 1);
         my $mDI = $I < $D ? $I : $D;    # min($D, $I);
         push @$w, ($S < $mDI ? $S : $mDI);    # min($S, min($D, $I))
      } ## end for my $j (1 .. length(...))
      $v = $w;    # "swap" and prepare for nest iteration
   } ## end for my $i (1 .. length(...))
   return $v->[-1];
} ## end sub levenshtein ($s, $t)

sub edit_distance ($S1, $S2) { return levenshtein($S1, $S2) }

my $first = shift // 'kitten';
my $second = shift // 'sitting';
say edit_distance($first, $second);
```

Stay warm (if you're in the north emisphere, at least), keep your cool
and stay safe!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#096]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-096/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-096/#TASK2
[Perl]: https://www.perl.org/
[ed]: https://en.wikipedia.org/wiki/Edit_distance
[ld]: https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
[cglib]: https://github.com/polettix/cglib-perl
[Levenshtein.pm]: https://github.com/polettix/cglib-perl/blob/master/Levenshtein.pm
