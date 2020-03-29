---
title: Aquarium - exploiting redundant constraints
type: post
tags: [ aquarium puzzle game, coding, perl, constraint programming ]
comment: true
date: 2020-04-06 08:00:00 +0200
preview: true
published: false
---

**TL;DR**

> Redundancy is often associated to overhead and waste of time, but in
> constraint programming redundant constraints, when *cooperating*, can save
> a lot.

In the last post about [aquarium][] ([Aquarium - search differently][]), we
left with a working solution that is capable of solving even the most
insidious puzzles on the website (also knowns as the [Special Monthly][]).
The time was not too bad, but nothing to brag about either:

```shell
$ time ./run.sh 07-search-differently/ monthly.aqp >/dev/null && printf 'OK\n'

real	1m2.964s
user	1m1.764s
sys	0m0.484s
OK
```

We can do better with some little redundancy. As you can guess, the code is
available in [stage 8][].

# Redundant constraints

Up to when we only used *picky* constraints, adding more redundant stuff had
really no point: if our initial set of constraint is complete, why add more?

Things changed dramatically when we taught our constraints to be a bit more
*cooperative* and help us doing some pruning, though. At this point,
*everything* that can help us get rid of unknown cells without guessing is a
big time saver!

# Empty spaces are just like inverted water

The key insight we can exploit at this point is that whatever happens to
water, it also happens to empty spaces when looking in reverse vertical
order.

Water must have one single level inside an aquarium? Well, so we have for
empty spaces. Water cannot have empty spaces below in the same aquarium?
It's the same as saying that empty spaces cannot have water above.

Hence, we can do a little of copy-and-paste, followed by a little of
changing here and there, to add the following cooperating constraint:

```perl
 1 sub adjust_empty_level ($puzzle) {
 2    my ($n, $field, $status) = $puzzle->@{qw< n field status >};
 3    my $n_changes = 0;
 4    for my $i (reverse 0 .. $n - 1) {    # iterate rows from bottom to top
 5       my %expected;
 6 
 7       # first sweep: adjust vertical emptying, set expectations
 8       for my $j (0 .. $n - 1) {
 9          my $id = $field->[$i][$j];
10          my $st = $status->[$i][$j];
11 
12          # vertical condition from before-last row on...
13          if (($i < $n - 1) && ($id == $field->[$i + 1][$j])) {
14             if ($st > $status->[$i + 1][$j]) { # possible mismatch?
15                if ($st == 0) { # current cell is *unknown*, relax!
16                   $st = $status->[$i][$j] = -1;  # mark empty
17                   $n_changes++;
18                }
19                elsif ($status->[$i - 1][$j] != 0) {
20                   die "wrong vertical leveling for aquarium $id\n";
21                }
22             }
23          }
24 
25          $expected{$id} ||= $st; # change only if unknown
26       }
27    
28       # second sweep: adjust horizontal emptying based on expectations
29       for my $j (0 .. $n - 1) {
30          my $id = $field->[$i][$j];
31          my $st = $status->[$i][$j];
32 
33          if ($st == 0) {
34             if ($expected{$id}) {
35                $st = $status->[$i][$j] = $expected{$id};
36                $n_changes++;
37             }
38          }
39          elsif ($st != $expected{$id}) {
40             die "wrong horizontal leveling for aquarium $id\n"
41          }
42       } ## end for my $j (0 .. $n - 1)
43    } ## end for my $i (0 .. $n - 1)
44    return $n_changes;
45 } ## end sub assert_water_level ($puzzle)
```

This must be added to our list of constraints, of course (addition in line
6):

```
 1 sub apply_constraints ($puzzle) {
 2    my $changes = -1;
 3    while ($changes != 0) {
 4       $changes = 0;
 5       $changes += adjust_water_level($puzzle);
 6       $changes += adjust_empty_level($puzzle);
 7       $changes += adjust_by_col($puzzle);
 8       $changes += adjust_by_row($puzzle);
 9    }
10 }
```

# How does it behave?

And now, it's time for testing:

```shell
$ time ./run.sh 08-redundancy 15x15-hard.aqp >/dev/null && printf 'OK\n\n'

real	0m0.184s
user	0m0.156s
sys	0m0.004s
OK

$ time ./run.sh 08-redundancy daily.aqp >/dev/null && printf 'OK\n\n'

real	0m0.379s
user	0m0.356s
sys	0m0.008s
OK

$ time ./run.sh 08-redundancy weekly.aqp >/dev/null && printf 'OK\n\n'

real	0m0.315s
user	0m0.304s
sys	0m0.004s
OK

$ time ./run.sh 08-redundancy monthly.aqp >/dev/null && printf 'OK\n\n'

real	0m1.083s
user	0m1.064s
sys	0m0.008s
OK

```

Now, I guess, we can say that we're fine. Of course... everybody has its own
parameters, please tell us in the comments if you go beyond!!!

[aquarium]: https://www.puzzle-aquarium.com/
[Special Monthly]: https://www.puzzle-aquarium.com/?size=11
[Aquarium - search differently]: {{ '/2020/04/05/aquarium-search-differently/' | prepend: site.baseurl | prepend: site.url }}
[stage 8]: https://gitlab.com/polettix/aquarium-solver/-/blob/master/08-redundancy/aquarium.pl
