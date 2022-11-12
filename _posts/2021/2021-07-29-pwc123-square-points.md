---
title: PWC123 - Square Points
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-07-29 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#123][].
> Enjoy!

# The challenge

> You are given coordinates of four points i.e. (x1, y1), (x2, y2), (x3, y3) and (x4, y4).
> 
> Write a script to find out if the given four points form a square.
> 
> **Example**
>
>     Input: x1 = 10, y1 = 20
>            x2 = 20, y2 = 20
>            x3 = 20, y3 = 10
>            x4 = 10, y4 = 10
>     Output: 1 as the given coordinates form a square.
>
>     Input: x1 = 12, y1 = 24
>            x2 = 16, y2 = 10
>            x3 = 20, y3 = 12
>            x4 = 18, y4 = 16
>     Output: 0 as the given coordinates doesn't form a square.

# The questions

As we will be doing some *potentially* floating point maths, a first
question would be what tolerance should the operations have, in
particular what tolerance is there to consider a value to be the same as
0.

As nothing is said about the ordering of the points, we will assume they
can be in any order and not necessarily assuming that close points in
the list are also adjacent in the candidate square.

The examples seem to indicate that the points we consider are in a
plane.

Last, I'd ask if this is meant to be a tricky question. The first
example is about a square whose sides are parallel to the coordinate
axes, but... squares might also be rotated in the plane!


# The solution

We'll use some vector maths here. Assuming that the input sequence of
points $(P_0, P_1, P_2, P3)$ is *ordered*, i.e. that each consecutive
pair is a side of the candidate polygon we want to check, we end up with
the following vectors representing the four sides:

$$
s_0 = P_1 - P_0 \\
s_1 = P_2 - P_1 \\
s_2 = P_3 - P_2 \\
s_3 = P_0 - P_3
$$

Much like the points, these "vector sides" are represented by pairs of
numbers, so we can "blur" the line and use the same representation for
the two.

In a square, two consecutive sides $s_i$ and $s_{i + 1}$ MUST fulfil the
following two conditions:

- have the same length;
- be orthogonal, i.e. form an angle of $\pm 90°$.

Fun fact: we only need to check the two conditions above for the first
three sides $s_0$, $s_1$, and $s_2$. If the comply, the fourth side
$s_3$ will comply too.

The length of a vector is calculated with Pythagora's theorem:

$$
L_v = \sqrt{v_x^2 + v_y^2}
$$

In comparing two sides, though, we can equivalently look a the squares
and avoid calculating the square root:

$$
L_v^2 = v_x^2 + v_y^2
$$

Checking for orthogonality can be done calculating their regular [scalar
(or *dot*) product][scalar]:

$$
v \cdot w = v_x w_x + v_y w_y
$$

This is 0 if and only if the two vectors are orthogonal, so it's exactly
the condition we are after.

OK, enough theory now... *show us the code!*

## Raku

[Raku][] first, which also gets the nice commenting. We define a class
to represent our points *and* vectors:

```raku
# a tiny class for handling a limited set of vector operations
class Vector {
   has @.cs is built is required;

   # "dot", i.e. scalar, product
   method dot (Vector $a) { return [+](self.cs »*« $a.cs) }

   # the *square* of the length is all we need in our solution
   method length_2 ()     { return self.dot(self) }
}
```

To make the implementation easier to read, we also override the
difference operator (so that we can calculate vectorized sides by
difference of two points):

```raku
multi sub infix:<->(Vector $a, Vector $b) {
   Vector.new(cs => [$a.cs »-« $b.cs]);
}
```

as well as the dot product, which relies on the `dot` method:

```raku
multi sub infix:<*>(Vector $a, Vector $b) { $a.dot($b) }
```

Our basic test function is the following:

```raku
sub is-sequence-a-square (@points is copy) {

   # comparing candidate sides means that we consider a "previous" side
   # and a "current" one. A side is defined as the vector resulting from
   # the difference of two consecutive points.
   my $previous = @points[1] - @points[0];

   # we just need to compare 3 sides, if they comply then the 4th will too
   for 1, 2 -> $i {
      my $current = @points[$i + 1] - @points[$i];

      # check if sides have the same length (squared)
      return False if $previous.length_2 != $current.length_2;

      # approximation might give surprises, we'll accept as orthogonal
      # sides whose scalar product is below our tolerance
      return False if $previous * $current > tolerance;

      # prepare for next iteration
      $previous = $current;
   }

   # three sides are compliant, it's a square!
   return True;
}
```

Now, of course, our input sequence of points might not be in the "right"
order, so we wrap the test above to check different alternative
orderings.

How many permutations should we consider? Out of 4 points, we have $4! =
24$ of them, but we don't need to consider them all.

First, we can fix our point in the first position as our *starting
point*, so in case we only have to consider permutations of the other
three, i.e. $3! = 6$ of them.

Then, we can observe that two arrangements that have the same point as
the opponent (i.e. non-adjacent) point to the *starting point* are
actually the same candidate polygon, traversed in opposite directions.
Hence, we can just consider one of these two.

In the end, we can just consider three possible permutations, like in
the following function:

```raku
sub is-square (*@points) {

   # try out permutations of the inputs that can yield a square. We fix
   # point #0 and only consider one permutation for each of the other
   # points as the opposite, ignoring the other because symmetric.
   state @permutations = (
      [0, 2, 1, 3],  # 0 and 1 are opposite
      [0, 1, 2, 3],  # 0 and 2 are opposite
      [0, 2, 3, 1],  # 0 and 3 are opposite
   );
   for @permutations -> $permutation {
      my @arrangement = @points[@$permutation].map({Vector.new(cs => @$_)});
      return 1 if is-sequence-a-square(@arrangement);
   }
   return 0;
}
```

A couple of final remarks:

- [Math::Vector][] was of... *great inspiration* for getting the
  implementation right. I used it in the first place, but it takes
  *ages* to load and eventually re-implemented only the relevant parts;
- inlining the `class` as I did means that the definition of the
  overloaded `multi sub infix` operators must appear *outside* the
  `class` definition. This took me a while to figure out.

## Perl

The [Perl][] translation is pretty much straightforward, also thanks to
the [overload][] module that allows us to overload a couple of
operators. Here's the complete program:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use constant False => 0;
use constant True  => 1;

use constant tolerance => 1e-7;

package Vector2D {
   use overload
     '-' => sub ($u, $v, $x) { v([ map { $u->[$_] - $v->[$_] } 0, 1 ]) },
     '*' => sub ($u, $v, $x) { $u->dot($v) };

   sub dot ($S, $t)   { return $S->[0] * $t->[0] + $S->[1] * $t->[1] }
   sub length_2 ($S)  { return $S->dot($S) }
   sub v ($v)         { return bless [$v->@*], __PACKAGE__ }
}

sub is_sequence_a_square (@points) {
   my $previous = $points[1] - $points[0];
   for my $i (1 .. $#points - 1) {
      my $current = $points[$i + 1] - $points[$i];
      return False if $previous->length_2 != $current->length_2;
      return False if $previous * $current > tolerance;
      $previous = $current;
   }
   return True;
}

sub is_square (@points) {
   state $permutations = [
      [0, 2, 1, 3],
      [0, 1, 2, 3],
      [0, 2, 3, 1],
   ];
   for my $permutation ($permutations->@*) {
      my @arrangement = map { Vector2D::v($_) } @points[@$permutation];
      return 1 if is_sequence_a_square(@arrangement);
   }
   return 0;
}

say is_square([10, 20], [20, 20], [20, 10], [10, 10]);
say is_square([12, 24], [16, 10], [20, 12], [18, 16]);
say is_square([0, 0], [1, 1], [0, 2], [-1, 1]);
```

# Thanks!

Thank you for reading this far and stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#123]: https://theweeklychallenge.org/blog/perl-weekly-challenge-123/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-123/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[scalar]: https://en.wikipedia.org/wiki/Dot_product
[overload]: https://metacpan.org/pod/overload
[Math::Vector]: https://github.com/colomon/Math-Vector
