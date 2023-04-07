---
title: PWC202 - Widest Valley
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-02-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#202][].
> Enjoy!

# The challenge

> Given a profile as a list of altitudes, return the leftmost **widest
> valley**. A valley is defined as a subarray of the profile consisting
> of two parts: the first part is non-increasing and the second part is
> non-decreasing. Either part can be empty.
>
> **Example 1**
>
>     Input: 1, 5, 5, 2, 8
>     Output: 5, 5, 2, 8
>
> **Example 2**
>
>     Input: 2, 6, 8, 5
>     Output: 2, 6, 8
>
> **Example 3**
>
>     Input: 9, 8, 13, 13, 2, 2, 15, 17
>     Output: 13, 13, 2, 2, 15, 17
>
> **Example 4**
>
>     Input: 2, 1, 2, 1, 3
>     Output: 2, 1, 2
>
> **Example 5**
>
>     Input: 1, 3, 3, 2, 1, 2, 3, 3, 2
>     Output: 3, 3, 2, 1, 2, 3, 3


# The questions

I thing that in some *serious* setting I'd ask whether the inputs are
supposed to be integers, if they can go negative or not, how many of
them we are supposed to receive... etc.

Also, I'd ask if an array should be returned, or just the indexes of the
widest valley within the provided array.

# The solution

The following solution, in [Perl][], has been built *by subtraction*. I
was initially expecting to track the latest *going down*, the latest
*going up*, the best, the levels, etc. just to eventually figure that we
don't need all that tracking.

We only need to track:

- the index of the latest *going down begin* (`$db`)
- the index of the latest *going level begin* (`$lb`)
- whether we're going up or not
- the best valley found so far

and iterate over the array. The code provides enough comments to fill
the missing parts.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @valley =
  widest_valley(grep { defined } map { split m{\D+}mxs, } @ARGV);
say join ', ', @valley;

sub widest_valley (@altitudes) {
   return @altitudes if @altitudes < 2;    # trivial cases

   my $db       = 0;                       # start of a valley
   my $lb       = 0;                       # start of a level
   my $going_up = 0;                       # start going down
   my ($vb, $vl) = (0, 1);                 # best valley so far

   my $previous = $altitudes[0];
   for my $i (1 .. $#altitudes) {
      my $current = $altitudes[$i];

      if ($previous < $current) {          # going up
         $lb       = $i;                   # reset the level begin
         $going_up = 1;                    # record the direction
      }

      # do nothing if $previous == $current

      elsif ($previous > $current) {       # going down
         if ($going_up) {    # leaving the top, "close" a valley
            my $length = $i - $db;
            ($vb, $vl) = ($db, $length) if $length > $vl;

            $db       = $lb;    # record the start of the new valley
            $going_up = 0;      # record the direction
         } ## end if ($going_up)
         $lb = $i;              # reset the level begin
      } ## end elsif ($previous > $current)

      $previous = $current;     # prepare for the next iteration
   } ## end for my $i (1 .. $#altitudes)

   # anyway, close the last segment
   my $length = @altitudes - $db;
   ($vb, $vl) = ($db, $length) if $length > $vl;

   return @altitudes[$vb .. ($vb + $vl - 1)];
} ## end sub widest_valley
```

The [Raku][] version is more or less a rip-off, including comments:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @valley = widest-valley([@args.map({.comb(/\d+/)}).flat».Int]);
   put @valley.join(', ');
}


sub widest-valley (@altitudes) {
   return @altitudes if @altitudes < 2;    # trivial cases

   my $db       = 0;                       # start of a valley
   my $lb       = 0;                       # start of a level
   my $going_up = 0;                       # start going down
   my ($vb, $vl) = 0, 1;                   # best valley so far

   my $previous = @altitudes[0];
   for 1 ..^ @altitudes -> $i {
      my $current = @altitudes[$i];

      if $previous < $current {            # going up
         $lb       = $i;                   # reset the level begin
         $going_up = 1;                    # record the direction
      }

      # do nothing if $previous == $current

      elsif $previous > $current {         # going down
         if ($going_up) {    # leaving the top, "close" a valley
            my $length = $i - $db;
            ($vb, $vl) = $db, $length if $length > $vl;

            $db       = $lb;    # record the start of the new valley
            $going_up = 0;      # record the direction
         } ## end if ($going_up)
         $lb = $i;              # reset the level begin
      } ## end elsif ($previous > $current)

      $previous = $current;     # prepare for the next iteration
   } ## end for my $i (1 .. $#altitudes)

   # anyway, close the last segment
   my $length = @altitudes - $db;
   ($vb, $vl) = $db, $length if $length > $vl;

   return @altitudes[$vb .. ($vb + $vl - 1)];
} ## end sub widest_valley
```

It seems to work on the test inputs so I'll call this a day, stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#202]: https://theweeklychallenge.org/blog/perl-weekly-challenge-202/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-202/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
