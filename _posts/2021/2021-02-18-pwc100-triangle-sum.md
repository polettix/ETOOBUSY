---
title: PWC100 - Triangle Sum
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-02-18 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#100][].
> Enjoy!

# The challenge

> You are given triangle array. Write a script to find the minimum path
> sum from top to bottom. When you are on index `i` on the current row
> then you may move to either index `i` or index `i + 1` on the next
> row.

# The questions

I can definitely hear [Mohammad S Anwar][] muttering to himself about
that objectively annoying [polettix][] insisting on having a more
specific example for the input of this challenge. Because... it's nice
to see this:

```
Input: Triangle = [ [1], [2,4], [6,4,9], [5,1,7,2] ]
```

A-ha! I will assume that there's no parsing involved then, and that the
representation is already in easy-to-use [Perl][] arrays of arrays.
Thanks!

Reading through the [Perl Weekly Review #097][] by Colin Crain I got to
understand how much stuff I give for granted when I read these
challenges. For example, the fact that the the minimum number of changes
in the binary substrings might land on none of the actual sub-sequences
was an epiphany!

So I wonder... *what might I be missing here?!?*.

I hope nothing.

# The solution

I know, I know.

I said: *no parsing, yay!*

Alas, I like to have programs around the functions that solve these
challenges, which usually means messing up with the command line. So
let's take this away first:

```perl
sub triangularize (@list) {
   my @retval;
   my $n = 1;
   while (@list) {
      die "invalid number of elements\n" unless @list >= $n;
      push @retval, [splice @list, 0, $n];
      ++$n;
   }
   return \@retval;
}
```

This takes a flat list of items and groups them in the right way for the
puzzle, producing an array of arrays as output.

OK, back on the main track, let's see my solution to this challenge:

```perl
sub triangle_sum ($tri) {
   my @s = $tri->[0][0];
   my $i = 1;
   while ($i <= $tri->$#*) {
      my $l = $tri->[$i];
      my @ns = $s[0] + $l->[0];
      push @ns, $l->[$_] + ($s[$_ - 1] < $s[$_] ? $s[$_ - 1] : $s[$_])
         for 1 .. $l->$#* - 1;
      push @ns, $s[-1] + $l->[-1];
      @s = @ns;
      ++$i;
   }
   return min(@s);
}
```

We keep an array `@s` of the *best sums so far* that landed us on a
specific spot. This starts with the very first line in our triangle,
which contains only one single item (`$tri->[0][0]`).

For each following line, we calculate the *next sums* in `@ns`. There
are three cases:

- the left-most item can *only* come from the left-most item in the
  previous line;
- the right-most item can *only* come from the right-most item in the
  previous line;
- all other items (if any) can come from two possible previous line's
  items.

For this reason, calculating the two external elements in `@ns` is
straightforward, while for the middle ones we have to understand what is
the best *previous* item, which in this case means which of these
previous items is the lower one.

When we're done calculating the *next sums* in `@ns`, we can update `@s`
and move on.

When we're done with the last line, we just have to calculate the
minimum of all the possible sums up to the last line and we're done!

Here is the whole program, for the masochists:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'min';

sub triangle_sum ($tri) {
   my @s = $tri->[0][0];
   my $i = 1;
   while ($i <= $tri->$#*) {
      my $l = $tri->[$i];
      my @ns = $s[0] + $l->[0];
      push @ns, $l->[$_] + ($s[$_ - 1] < $s[$_] ? $s[$_ - 1] : $s[$_])
         for 1 .. $l->$#* - 1;
      push @ns, $s[-1] + $l->[-1];
      @s = @ns;
      ++$i;
   }
   return min(@s);
}

sub triangularize (@list) {
   my @retval;
   my $n = 1;
   while (@list) {
      die "invalid number of elements\n" unless @list >= $n;
      push @retval, [splice @list, 0, $n];
      ++$n;
   }
   return \@retval;
}

my @list = @ARGV ? @ARGV : qw< 1 2 4 6 4 9 5 1 7 2 >;
say triangle_sum(triangularize(@list));
```

Stay safe folks!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#100]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-100/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-100/#TASK2
[Perl]: https://www.perl.org/
[Mohammad S Anwar]: https://github.polettix.it/ETOOBUSY/2020/12/08/manwar-is-amazing/
[polettix]: {{ '/' | prepend: site.baseurl }}
[Perl Weekly Review #097]: https://perlweeklychallenge.org/blog/review-challenge-097/
