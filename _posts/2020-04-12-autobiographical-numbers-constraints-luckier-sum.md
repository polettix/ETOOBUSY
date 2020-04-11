---
title: Autobiographical numbers constraints - luckier weighted sum
type: post
tags: [ constraint programming, cglib, perl, algorithm ]
comment: true
date: 2020-04-12 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> By sheer luck, a buggy implementation of the weighted sum ended up
> providing a more efficient heuristic for pruning the search space.

The code for this post can be found in [stage 4][].

In the previous post [Autobiographical numbers constraints - weighted sum][] we
introduced a constraint based on the weighted sum redundancy:

$$ N = \sum_{i = 0}^{N-1} i \cdot v_i$$

Fact is that the initial implementation of this constraint was buggy... but
in a good sense, i.e. it was still a valid redundant constraint, only not
doing *exactly* what is was meant to!

```perl
 1 sub constraint_weighted_sum ($status) {
 2    my $solution = $status->{solution};
 3    my $n        = $solution->@*;
 4    my %min_for;
 5    for my $i (0 .. $n - 1) {
 6       my $slot = $solution->[$i];
 7       my $min = $min_for{$i} = min keys $slot->%*;
 8       $n -= $min;
 9    }
10    my $deleted = 0;
11    for my $i (1 .. $n - 1) {
12       my $slot = $solution->[$i];
13       my $available = $n + $min_for{$i};
14       my $max = int($available / $i);
15       for my $j ($max + 1 .. $n - 1) {
16          $deleted++ if delete $slot->{$j};
17       }
18    } ## end for my $i (1 .. $n - 1)
19    return $deleted;
20 } ## end sub constraint_weighted_sum ($status)
```

Line 8 is *doubly bugged* for our purposes.

First of all, it's not removing occupied slots according to the weighted sum
rule, but just by removing the minimum. Which is also a valid constraint (on
the total sum, as a matter of fact), just a different heuristic that is
*generally* less aggressive, except for slot `0` of course.

Secondly, line 8 acts on variable `$n` which is also used as the iteration
variable in the second loop starting at line 11. Lowering this number means
doing less pruning actions (i.e. not doing pruning over the last elements of
the array); again, this is not an invalid constraint, just apparently less
aggressive.

# How does it go?

And yet it goes noticeably better than the *correct* weighted sum redunant
constraint:

```shell
$ time ./run.sh 03-weighted-sum/ 80
solution => [76,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

real	0m15.683s
user	0m15.652s
sys	0m0.012s

$ time ./run.sh 04-luckier-sum/ 80
solution => [76,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

real	0m8.029s
user	0m8.016s
sys	0m0.004s
```

# Why?

I have a few ideas:

- first of all, solutions all have a big number of zeros, which are not
  considered in the weighted sum. So this approach is more aggressive with
  allocations on slot `0`, which also turns out to be the right thing;

- avoidance of the last part of the slots array is probably beneficial
  because these would be anyway tried out as value $0$ in the first place,
  so there's a gain in avoiding the pruning and trying out $0$ in the search
  phase.

# So long...

Curious about the whole series? Here it is:

- [Autobiographical numbers][]
- [Autobiographical numbers constraints - basic][]
- [Autobiographical numbers constraints - last is zero][]
- [Autobiographical numbers constraints - weighted sum][]
- [Autobiographical numbers constraints - luckier weighted sum][]
- [Code repository][repository]

Comments? Please comment below!

[Autobiographical numbers]: {{ '/2020/04/08/autobiographical-numbers/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - basic]: {{ '/2020/04/09/autobiographical-numbers-constraints-basic/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - last is zero]: {{ '/2020/04/10/autobiographical-numbers-constraints-last-zero/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - weighted sum]: {{ '/2020/04/11/autobiographical-numbers-constraints-weighted-sum/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - luckier weighted sum]: {{ '/2020/04/12/autobiographical-numbers-constraints-luckier-sum/' | prepend: site.baseurl | prepend: site.url }}
[repository]: https://gitlab.com/polettix/autobiographical-numbers
[stage 4]: https://gitlab.com/polettix/autobiographical-numbers/-/blob/master/04-luckier-sum/autobiographical-numbers.pl
