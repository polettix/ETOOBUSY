---
title: PWC101 - Pack a Spiral
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-02-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#101][]. Enjoy!

# The challenge

> You are given an array `@A` of items (integers say, but they can be
> anything). Your task is to pack that array into an `MxN` matrix
> spirally counterclockwise, as tightly as possible. 
>> ‘Tightly’ means the absolute value |M-N| of the difference has to be
>> as small as possible.

# The questions

Folks how I hate this kind of challenges. It's all an intricate
calculation of indexes etc. which becomes unnerving very quickly for me,
*especially* if the solution does not pop up immediately.

Well, maybe this is what *excercise* is for.

There's an obvious thread of questions:

- Is any order is OK, as long as the array is arranged in a
  counter-clockwise spiral?
- What should we do when there is a prime number of elements?
- Is it OK to have a good packing, but empty slots in the matrix?


# The solution

Well, I'm a bit tired so I decided to go for minimizing the target
function and stick to either square matrices, or with a maximum
difference of 1 in the two dimensions.

There are a lot of cases to be considered, which... I didn't enjoy
particularly!

The bottom line, anyway, is that:

- I start from the center and go to the outside - which is pretty much
  the contrary of the examples, but still within the requested packing;
- I calculate where to start, as well as initializing the matrix with
  all empty slots.
- Then I proceed to populate the matrix, one "frame" at a time. Each
  frame has a side that is two items bigger than the previous frame.

Without further ado... here's my whole solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Data::Dumper;

sub pack_a_spiral (@A) {
   my $N = scalar @A;
   my $side = int sqrt $N;
   --$side if $side * $side == $N;

   my (@M, $x, $y);
   if ($side * ($side + 1) >= $N) { # rectangle
      if ($side % 2) {
         $x = ($side - 1) / 2;
         $y = $side - $x - 1;
      }
      else {
         $x = $side / 2;
         $y = $side - $x;
      }
         @M = map { [('') x ($side + 1)] } 1 .. ($side);
   }
   else { # square
      $x = $side % 2 ? (($side - 1) / 2) : $side / 2;
      $y = $side - $x;
      ++$side;
      @M = map { [('') x $side] } 1 .. $side;
   }

   $M[$y][$x] = shift @A;
   $side = 2;

   OUTER:
   while ('necessary') {
      ++$x; # move to next frame
      ++$y;
      for ([0, -1], [-1, 0], [0, +1], [1, 0]) { # four sides
         my ($dx, $dy) = $_->@*;
         for (1 .. $side) {
            last OUTER unless @A;
            $x += $dx;
            $y += $dy;
            $M[$y][$x] = shift @A;
         }
      }
      $side+=2;
   }

   return \@M;
}

sub print_matrix ($M) {
   for my $row ($M->@*) {
      for my $item ($row->@*) {
         printf '%4s ', $item;
      }
      print "\n";
   }
}

my @items = @ARGV ? @ARGV : (1..16);
my $s = pack_a_spiral(@items);
print_matrix($s);
```

Stay safe!!!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#101]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-101/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-101/#TASK1
[Perl]: https://www.perl.org/
