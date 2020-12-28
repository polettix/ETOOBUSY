---
title: PWC093 - GCD Sum
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-12-28 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#093][]. Enjoy!

# The challenge

> You are given set of co-ordinates `@N`. Write a script to count maximum
> points on a straight line when given co-ordinates plotted on 2-d plane.

# The questions

Well, this is interesting. Nowhere, I mean *nowhere* it's stated what these
coordinates are made of. Integers? Double precision? Rational numbers?

The safe approach here would be to assume some floating point
representation. But this would be so *boring*. So I'll not ask this time...
I'll *assume* we're dealing with integers. Not even particularly big ones 😅

(In my defense, *all* examples use integers.)

And no, I didn't ask so I don't want to know the answer!

# The solution

Ok ok, let's get this away first of all: if you *really* want something that
works in the generic floating point case, then you can take a look at [this
page][]. But I claim it's boring, because the idea *per-se* is amazing, only
you will have to settle for some *precision* to figure out what to do with
small rounding errors.

Which is boring because... *well*... I would have to look a lot of things
around 😇

## A bit of thinking

So... integers. A good representation for a line here would be a
*parametric* one, i.e. where we have two separate equations for the two
axes, both leveraging on the same *parameter* that we will call $t$. Hence,
a generic alignment of points centered at $\mathbf{P}$ would be represented as:

$$
Q_x = P_x + t \cdot d_x \\
Q_y = P_y + t \cdot d_y
$$

with the benefit that all quantities in these equations are integers. No
rounding madness!

In vector notation, this can also be expressed as:

$$
(\mathbf{Q} - \mathbf{P}) = t \cdot \vec{d_{PQ}}
$$

We put a little subscript to vector $\vec{d_{PQ}}$ to remind ourselves that
varying $\vec{d}$ gives us *every possible* alignment through $\mathbf{P}$,
and that specific value is the one that is good for the alignment that
includes $\mathbf{Q}$ too.

The astute reader might be wondering *why $t$* at this point. As a matter
of fact, it might be always equal to $1$ and this would guarantee that we
are only dealing with integers. So we will introduce another requirement:
the two components of $\vec{d_{PQ}}$ MUST be coprime. This might imply that $t$
is actually an integer different from one.

Now, let's consider another point $\mathbf{R}$ and ask ourselves whether
it's collinear with the other two. For this to happen, we MUST have that
some value of the parameter $t$ over the line through $\mathbf{P}$ and
$\mathbf{Q}$ lands us exactly on $\mathbf{R}$. In other terms, we MUST have
that $\vec{d_{PR}} = \pm \vec{d_{PQ}}$, where the uncertainty on the sign
stems from where the three points are located on their alignment.

Which brings us to a further requirement: let's just make it so that $d_x$
is always greater than, or equal to, zero.

One specific case we have to consider is when one of the two components of
$\vec{d}$ is zero. In this case it makes no sense of thinking of the two
components as *coprime*, so we can just assume that the non-zero one is
equal to $1$.

Last, but not least, we have to account for the possibility that a point is
repeated multiple times at $\mathbf{P}$! This is easily addressed though:
let's just count the number of repetitions: wherever $\mathbf{P}$ appears in
an alignment, we can just add also these repetitions and we will have our
count of aligned points.

I guess it's everything from a theoretical standpoint, right?

## Implementation

At this point, we can move on to the implementation:

```
 1 sub max_points ($inputs) {
 2    my $max = 0;
 3    my %skip;
 4    for my $i (0 .. $#$inputs - 1) {
 5       next if $skip{$i};    # it's coincident with some points before
 6       my ($x, $y) = $inputs->[$i]->@*;
 7       my %count_for;
 8       my $coincident = 1;    # the point itself
 9       for my $j ($i + 1 .. $#$inputs) {
10          my $q = $inputs->[$j];
11          my ($dx, $dy) = ($q->[0] - $x, $q->[1] - $y);
12          if ($dx == 0) {
13             if ($dy == 0) { $skip{$j}++; $coincident++ }
14             else          { $count_for{'0,1'}++ }
15          }
16          else {
17             ($dx, $dy) = (-$dx, -$dy) if $dx < 0;
18             my $gcd =
19                 $dy > 0 ? gcd($dx, $dy)
20               : $dy < 0 ? gcd($dx, -$dy)
21               :           $dx;
22             $count_for{($dx / $gcd) . ',' . ($dy / $gcd)}++;
23          } ## end else [ if ($dx == 0) ]
24       } ## end for my $j ($i + 1 .. $#$inputs)
25       my $rmax = $coincident + max(0, values %count_for);
26       $max = $rmax if $rmax > $max;
27    } ## end for my $i (0 .. $#$inputs...)
28    return $max;
29 } ## end sub max_points ($inputs)
```

The input points are assumed to be passed as an Array of Arrays, eash
sub-array holding a single pair of coordinates for a point.

The `%skip` hash at line 3 is only a little optimization to avoid spending
effort on duplicated nodes. Whenever we find a duplicate node (line 13) we
increment the count of `$coincident` points and make a note to skip the
duplicate node afterwards (line 5).

To account for all possible lines, we do a double loop:

- the outer one goes through all points except the last one. We will always
  need to have *two* points for an alignment, so it does make sense to only
  put ourselves in the condition of having at least a *pair of points*;

- the inner one goes from past the outer point to the end. Alignment is
  commutative, so it does make sense to avoid considering a pair of points
  twice.

At each outer loop we calculate how big are alignments where a specific
point at index `$i` participates in. Variable `%count_for` keeps track of
how many times we hit into specific values of vector $\vec{d}$, because as
we saw it's how we can establish when points are aligned or not. Variable
`$coincident` keeps track of how many *duplicates* we have for the point we
are analyzing; it's initialized at `1` to keep track of the point itself.

Lines 10 through 23 make sure to calculate the *right* value for $\vec{d}$,
taking into account the different cases and making sure to only track
coprimes (or whatever we can consider good as a unique representation).
Tracking of the vector is done keeping a count in a hash, where the keys is
a string representation of the vector (lines 14 and 22).

After the inner loop, it's time to calculate the maximum number of
alignments for the specific round (line 25) and then update the overall
maximum value if applicable (line 26).

## Everything put together

Here's the whole thing:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'max';

sub max_points ($inputs) {
   my $max = 0;
   my %skip;
   for my $i (0 .. $#$inputs - 1) {
      next if $skip{$i};    # it's coincident with some points before
      my ($x, $y) = $inputs->[$i]->@*;
      my %count_for;
      my $coincident = 1;    # the point itself
      for my $j ($i + 1 .. $#$inputs) {
         my $q = $inputs->[$j];
         my ($dx, $dy) = ($q->[0] - $x, $q->[1] - $y);
         if ($dx == 0) {
            if ($dy == 0) { $skip{$j}++; $coincident++ }
            else          { $count_for{'0,1'}++ }
         }
         else {
            ($dx, $dy) = (-$dx, -$dy) if $dx < 0;
            my $gcd =
                $dy > 0 ? gcd($dx, $dy)
              : $dy < 0 ? gcd($dx, -$dy)
              :           $dx;
            $count_for{($dx / $gcd) . ',' . ($dy / $gcd)}++;
         } ## end else [ if ($dx == 0) ]
      } ## end for my $j ($i + 1 .. $#$inputs)
      my $rmax = $coincident + max(0, values %count_for);
      $max = $rmax if $rmax > $max;
   } ## end for my $i (0 .. $#$inputs...)
   return $max;
} ## end sub max_points ($inputs)

sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }

say max_points([[1, 1], [2, 2], [3, 3]]);
say max_points(
   [
      [1, 1], [2, 2], [3, 1], [1, 3], [5, 3], [4, 4],
      [3, 3], [4, 0], [0, 4], [0, 4]
   ]
);
```

# That's it for today!

I hope the integer version of this challenge was somehow interesting for
you. Let me know in the comments, but in any case let me wish you a Happy
New (western) Year!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#093]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-093/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-093/#TASK1
[Perl]: https://www.perl.org/
[this page]: https://www.cs.princeton.edu/courses/archive/spring03/cs226/assignments/lines.html
