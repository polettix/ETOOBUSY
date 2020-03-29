---
title: Aquarium - cooperating constraint
type: post
tags: [ aquarium puzzle game, coding, perl, constraint programming ]
comment: true
date: 2020-04-03 08:00:00 +0200
preview: true
---

**TL;DR**

> Just like in real life, it's better for constraints to help out instead of
> just being picky.

In the last post [Aquarium - search the solution space][] we left with a
big issue: a correct solution, but hardly useful because too bad at scaling.
To address this, we put our constraints at work, pushing them to be less
picky and more immediately useful - see something, say something!

The code for this post is found in [stage 5][].

# Water level constraint, revisited

Let's take a  look at our constraint about the water level:

```perl
sub assert_water_level ($puzzle) {
   my ($n, $field, $status) = $puzzle->@{qw< n field status >};
   for my $i (0 .. $n - 1) {    # iterate rows from top to bottom
      my %expected;
      for my $j (0 .. $n - 1) {
         my $id = $field->[$i][$j];
         my $st = $status->[$i][$j];

         die "wrong vertical leveling for aquarium $id\n"
           if ($i > 0)
           && ($id == $field->[$i - 1][$j])
           && ($st < $status->[$i - 1][$j]);

         $expected{$id} //= $st;
         die "wrong horizontal leveling for aquarium $id\n"
           if $expected{$id} != $st;

      } ## end for my $j (0 .. $n - 1)
   } ## end for my $i (0 .. $n - 1)
   return $puzzle;
} ## end sub assert_water_level ($puzzle)
```

As it is, it's just complaining about neighbors not being *exactly equal* to
what is expected, although in some conditions it might give some help. For
example, let's consider the following situation:

```
            2       1   

        +-------+-------+
        |~~~~~~~|       |
     1  |~~~~~~~|   X   |
        |~~~~~~~|       |
        |~~~~~~~+-------+
        |               |
     2  |               |
        |               |
        +---------------+
```

Our constraint would complain in this situation, although a normal player
would just take advantage of the situation and *flood* the second row based
on the fact that there is water in the upper left corner. In other terms,
we have to take into consideration that *unknown* cells might be either
water-filled or empty, and act accordingly.

Let's turn the function to `adjust_water_level` then:

```perl
 1 sub adjust_water_level ($puzzle) {
 2    my ($n, $field, $status) = $puzzle->@{qw< n field status >};
 3    my $n_changes = 0;
 4    for my $i (0 .. $n - 1) {    # iterate rows from top to bottom
 5       my %expected;
 6 
 7       # first sweep: adjust vertical flooding, set expectations
 8       for my $j (0 .. $n - 1) {
 9          my $id = $field->[$i][$j];
10          my $st = $status->[$i][$j];
11 
12          # vertical condition from second row on...
13          if (($i > 0) && ($id == $field->[$i - 1][$j])) {
14             if ($st < $status->[$i - 1][$j]) { # possible mismatch?
15                if ($st == 0) { # current cell is *unknown*, relax!
16                   $st = $status->[$i][$j] = 1;  # fill with water
17                   $n_changes++;
18                }
19                elsif ($status->[$i - 1][$j] == 0) { # previous is unknown
20                   # let's just ignore this for the moment...
21                }
22                else {
23                   die "wrong vertical leveling for aquarium $id\n";
24                }
25             }
26          }
27 
28          $expected{$id} ||= $st; # change only if unknown
29       }
30    
31       # second sweep: adjust horizontal flooding based on expectations
32       for my $j (0 .. $n - 1) {
33          my $id = $field->[$i][$j];
34          my $st = $status->[$i][$j];
35 
36          if ($st == 0) {
37             if ($expected{$id}) {
38                $st = $status->[$i][$j] = $expected{$id};
39                $n_changes++;
40             }
41          }
42          elsif ($st != $expected{$id}) {
43             die "wrong horizontal leveling for aquarium $id\n"
44          }
45       } ## end for my $j (0 .. $n - 1)
46    } ## end for my $i (0 .. $n - 1)
47    return $n_changes;
48 } ## end sub assert_water_level ($puzzle)
```

Admittedly, it's a bit more *complicated*. The inner loop is repeated two
times: the first one takes care of propagating water vertically (from top to
bottom), the second one propagates water horizontally. Hence, no more
complaining when there is a mismatch involving water tiles and unknown, but
flooding!

One thing that we just observe right now: the test in line 19 is there to
exclude a complaint where an *unknown* line is over an *empty* line. This is
not actually a problem at this stage... but it might be in a later one.

# Going on with constraints

The return value in `assert_water_level` has been set to report the number
of cells that were filled with water in the process. This will come handy
when checking the constraints:

```perl
sub apply_constraints ($puzzle) {
   my $changes = -1;
   while ($changes != 0) {
      $changes = 0;
      $changes += adjust_water_level($puzzle);
      assert_boundary_conditions($puzzle);
   }
}
```

Having constraints also do some state-changing actions requires us to
evaluate them over and over until none of them makes any change, which is
why we put constraints-checking inside a `while` loop.

This is not really useful... yet. It will become better soon, though, when
also the other constraints will be... *evolved* 🤓

# Improvements?

Not really - well, not yet! *Yeah, well, history is gonna change*.


[Aquarium - search the solution space]: {{ '/2020/04/02/aquarium-search/' | prepend: site.baseurl | prepend: site.url }}
[stage 5]: https://gitlab.com/polettix/aquarium-solver/-/blob/master/05-cooperating-constraint/aquarium.pl
