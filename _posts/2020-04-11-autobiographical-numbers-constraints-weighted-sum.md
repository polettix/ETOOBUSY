---
title: Autobiographical numbers constraints - weighted sum
type: post
tags: [ constraint programming, cglib, perl, algorithm ]
comment: true
date: 2020-04-11 09:05:55 +0200
mathjax: true
published: true
---

**TL;DR**

> Going on with constraints for [Autobiographical numbers][]! We leverage a
> fact discovered in [Autobiographical numbers constraints - last is zero][]
> to get more pruning.

The code for this post can be found in [stage 3][].

We already discussed about this:

$$ N = \sum_{i = 0}^{N-1} i \cdot v_i$$

i.e. each slot `x` with a fixed amount $y$ takes a toll on the available
slots by $x \cdot y$.

What can we do when there are still several candidates for a slot (i.e.
several possible values for $y$)? We can say that the toll will be *at
least* equal to the one induced by the minimum candidate. As an example,
suppose that slot `10` still has values $2$ and $5$ as possible candidates.
In the former case, it would chip away $20$ slots, in the latter it would
chip away $50$ slots. In either case, *at least* $20$ slots will be
allocated, so it makes sense to remove them from the count and hope this
will help prune some other slot.

There is more though. If accounting for all the minimum requirement leaves a
number $z$ of residual slots, then we know that we cannot accomodate more
than that - which means possibly pruning out higher candidates.

# The code

We can leverage this redundant constraint like this:

```shell
 1 sub constraint_weighted_sum ($status) {
 2    my $solution = $status->{solution};
 3    my $n = my $available_slots = $solution->@*;
 4    my %chip_for;
 5    for my $i (0 .. $n - 1) {
 6       my $slot = $solution->[$i];
 7       my $chip = $chip_for{$i} = min(keys $slot->%*) * $i;
 8       $available_slots -= $chip;
 9    }
10    my $deleted = 0;
11    for my $i (1 .. $n - 1) {
12       my $slot = $solution->[$i];
13       my $max  = int(($available_slots + $chip_for{$i}) / $i);
14       for my $j ($max + 1 .. $n - 1) {
15          $deleted++ if delete $slot->{$j};
16       }
17    } ## end for my $i (1 .. $n - 1)
18    return $deleted;
19 } ## end sub constraint_weighted_sum ($status)
```

This is a pretty straightforward implementation of the insight discussed
previously.

The first loop (lines 5 to 9) computes the number of available slots
remaining in excess of what is the minimum required amount. This minimum is
saved in hash `%chip_for` because it will also become useful later.

The second loop (lines 11 to 17) leverages the collected information and
prunes out impossible candidates. To understand the maximum value for slot
`i`, we have to first re-integrate the *minimum number* that we chopped away
from `$available_slots`, and divide by $i$ (line 13). Then, everything past
this maximum value is removed (lines 14 to 16).


# How does it got?

The improvement is tangible:

```shell
$ time ./run.sh 02-last-is-zero/ 35
solution => [31,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

real	0m12.731s
user	0m12.696s
sys	0m0.012s

$ time ./run.sh 03-weighted-sum/ 35
solution => [31,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

real	0m0.849s
user	0m0.836s
sys	0m0.008s
```

And yet... by sheer luck... we can still do better!

[Autobiographical numbers constraints - last is zero]: {{ '/2020/04/10/autobiographical-numbers-constraints-last-zero/' | prepend: site.baseurl | prepend: site.url }}
[stage 3]: https://gitlab.com/polettix/autobiographical-numbers/-/blob/master/03-weighted-sum/autobiographical-numbers.pl
[Autobiographical numbers]: {{ '/2020/04/08/autobiographical-numbers/' | prepend: site.baseurl | prepend: site.url }}
