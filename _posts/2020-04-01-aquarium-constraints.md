---
title: Aquarium - constraints
type: post
tags: [ aquarium puzzle game, coding, perl, constraint programming ]
comment: true
date: 2020-04-01 08:00:00 +0200
preview: true
published: false
---

**TL;DR**

> It's time to start coding for [aquarium][], let's begin from the
> *constraints* that allow us to tell a good - if partial - solution from an
> evidently wrong one.

# Let's start from the rules

The rules for [aquarium][] are simple, from the site:

- The puzzle is played on a rectangular grid divided into blocks called
  "aquariums"
- You have to "fill" the aquariums with water up to a certain level or leave
  it empty.
- The water level in each aquarium is one and the same across its full width
- The numbers outside the grid show the number of filled cells horizontally
  and vertically. 

The constraints are stated in the third and fourth bullet, let's address
them individually. The following sections assume that you're comfortable
with the data structure to represent the whole puzzle, you can take a
refresher in the first post [Aquarium - parse puzzle input][].

# Water has one level only in one aquarium

This constraint can be translated into the following checks:

- vertically in one column, if two adjacent cells belong to the same
  aquarium, the upper one MUST have a value that is less than, or equal to,
  the lower one. This stems from the fact that *empty* (-1) is lighter than
  or equal to *unknown* (0), which is lighter than or equal to *water* (1);
- horizontally, whatever level we find for the leftmost cell of an aquarium,
  all other cells in the same aquarium MUST hold the same value.

This is the code for this constraint:

```perl
 1  sub assert_water_level ($puzzle) {
 2     my ($n, $field, $status) = $puzzle->@{qw< n field status >};
 3     for my $i (0 .. $n - 1) {    # iterate rows from top to bottom
 4         my %expected;
 5         for my $j (0 .. $n - 1) {
 6             my $id = $field->[$i][$j];
 7             my $st = $status->[$i][$j];
 8
 9             die "wrong vertical leveling for aquarium $id\n"
10                if ($i > 0)
11                && ($id == $field->[$i - 1][$j])
12                && ($st < $status->[$i - 1][$j]);
13
14             $expected{$id} //= $st;
15             die "wrong horizontal leveling for aquarium $id\n"
16                if $expected{$id} != $st;
17
18         } ## end for my $j (0 .. $n - 1)
19     } ## end for my $i (0 .. $n - 1)
10     return $puzzle;
21  } ## end sub assert_water_level ($puzzle)
```

It is basically a straight translation into code of the bullets above.

The vertical check is performed in lines 9 to 12; it can only be performed
from the second row on, which is the reason of the test in line 10.

Hash `%expected` tracks the expected value for each aquarium at the *same
level* (second bullet), initializing it with the first value found for each
aquarium (line 14 `$expected{$id //= $st`) and complaining if values differ
(lines 15 and 16). This test is only for the single horizontal level, hence
`%expected` is declared *inside* the outer loop so that it is reset for each
new row.

# Row-level and Column-level constraints

Boundary conditions are easy to check: it suffices to count how many water-
filled cells are there, and check that it's the right number. Put it like
this, anyway, the check would be somehow... *strict* because it can only be
fulfilled by a complete solution. We will check that there is not *too much
water* instead, as well as not *too much emptiness*:

```perl
 1 sub assert_boundary_conditions ($puzzle) {
 2    my ($n, $status, $items_by_row, $items_by_col) = 
 3       $puzzle->@{qw< n status items_by_row items_by_col >};
 4 
 5    # the field is square and this is an advantage, $i and $j can be
 6    # thought as either row-column or column-row
 7    for my $i (0 .. $n - 1) {
 8       my $i1 = $i + 1; # useful for the exception
 9       my ($water_row, $empty_row, $water_col, $empty_col) = (0) x 4;
10       for my $j (0 .. $n - 1) {
11          $water_row++ if $status->[$i][$j] > 0;
12          $empty_row++ if $status->[$i][$j] < 0;
13          $water_col++ if $status->[$j][$i] > 0;
14          $empty_col++ if $status->[$j][$i] < 0;
15       }
16 
17       die "too many filled cells in row $i1\n"
18          if $water_row > $items_by_row->[$i];
19 
20       die "too many empty cells in row $i1\n"
21          if $empty_row > $n - $items_by_row->[$i];
22 
23       die "too many filled cells in col $i1\n"
24          if $water_col > $items_by_col->[$i];
25 
26       die "too many empty cells in col $i1\n"
27          if $empty_col > $n - $items_by_col->[$i];
28 
29    }
30    return $puzzle;
31 }
```

In other terms, we allow for some cells to still be *unknown*, so our checks
translate into ensuring that the count of *empty* or *filled* cells is
within the expected bounds.

Iteration over variable `$i` (*outer iteration*) does the trick for both
rows and columns at the same time - the trick is to keep track of four
different variables to count the amount of water and confirmed empty spaces
for row `$i` *and* column `$i`. The actual counting is done in lines 10 to
15, where variable `$j` iterates *the other* dimension.

Tests in lines 17 to 27 are straightforward: if the specific quantity is out
of bounds, an exception is raised.

# Constraints in action!

The following [asciinema][] recording shows examples of all the different
ways to fail the constraints:

<script id="asciicast-314081" src="https://asciinema.org/a/314081.js" async></script>

Until next time... happy coding!

[Aquarium - parse puzzle input]: {{ '/2020/03/30/aquarium-parse-puzzle/' | prepend: site.baseurl | prepend: site.url }}
[aquarium]: https://www.puzzle-aquarium.com/
[aquarium-solver]: https://gitlab.com/polettix/aquarium-solver/
[stage 3]: https://gitlab.com/polettix/aquarium-solver/-/blob/master/03-constraints/aquarium.pl
[asciinema]: https://asciinema.org/
