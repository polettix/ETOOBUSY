---
title: Autobiographical numbers constraints - basic
type: post
tags: [ constraint programming, cglib, perl, algorithm ]
comment: true
date: 2020-04-09 00:20:33 +0200
mathjax: true
published: true
---

**TL;DR**

> Remember last post about [Autobiographical numbers][]? Here we will take a
> look at the constraints - horribly laid out, but effective (although maybe
> not very efficient).

So... the constraints. I coded a few of them, let's start from a very basic
one - although pretty effective on its own terms. If you want to try the
code below, you can find it in [autobiographical-numbers][] (the code itself
is in [stage 1][]).

# The code

```perl

 1 sub constraint_basic ($status) {    # little pruning, mostly checking
 2    my $solution = $status->{solution};
 3    my %count_for;
 4    my %is_exact = map { $_ => 1 } 0 .. $#$solution;
 5    for my $i (0 .. $#$solution) {
 6       my $slot       = $solution->[$i];
 7       my @candidates = keys $slot->%*;
 8       die "no candidate for $i" unless @candidates;
 9       my $exact = @candidates == 1;
10       for my $candidate (@candidates) {
11          $count_for{$candidate}++;
12          $is_exact{$candidate} = 0 unless $exact;
13       }
14    } ## end for my $i (0 .. $#$solution)
15    my $changes = 0;
16    for my $i (0 .. $#$solution) {
17       my $amount     = $count_for{$i} // 0;
18       my $slot       = $solution->[$i];
19       if ($is_exact{$i}) {
20          die "invalid amount if $i" unless exists $slot->{$amount};
21          if (scalar keys $slot->%* > 1) { # prune
22             $slot->%* = ($amount => 1);
23             $changes++;
24          }
25       }
26       else {
27          for my $needed (keys $slot->%*) {
28             if ($needed > $amount) {
29                delete $slot->{$needed}; # this can't be fulfilled
30                $changes++;
31             }
32          }
33          die "no valid candidate for $i" unless scalar keys $slot->%*;
34       }
35    } ## end for my $i (0 .. $#$solution)
36    return $changes;
37 } ## end sub constraint_basic ($status)
```

The first loop (lines 5 to 14) counts the number of available slots where a
specific amount can appear, collecting it in hash `%count_for`.
Additionally, it also tracks whether the specific amount appears *exactly*
in all those slots, i.e. if it's the only candidate remained in there.

The following loop (lines 16 to 35) does the constraints check and possibly
pruning, keeping track of the number of changes on the way (so that the
constraint function can signal whether pruning happened or not via
`return`).

Every slot is checked (line 16); the amount associated is the count of
possible slots where it might appear (line 17).

If the count associated to this slot is exact (i.e. it appeared as the only
candidate in all slots where it was present), then we have to make an exact
check. Hence we throw an exception in case this amount is not among the
possibilities for this slot (line 20) or, if present, we make sure to mark
it as the only possibility (lines 21 to 24, which avoid doing this operation
over and over).

If the count is not *exact*, then `$amount` represents the maximum number of
times that the specific value of the slot (i.e. `$i`) can appear overall.
For this reason, we can rule out all possibilities that would require *more*
than `$amount` (lines 28 to 32). After this pruning, we must have some
residual candidate for the slot, otherwise this cannot be a solution (line
33).

# How does it go?

I daresay that it goes pretty well - enough to solve the puzzle for the
[YouTube video][] in a bunch of milliseconds:

```shell
$ time ./run.sh 01-basic/ 10
solution => [6,2,1,0,0,0,1,0,0,0]

real	0m0.084s
user	0m0.068s
sys	0m0.008s
```

But there will be more... stay tuned!

[Autobiographical numbers]: {{ '/2020/04/08/autobiographical-numbers/' | prepend: site.baseurl | prepend: site.url }}
[autobiographical-numbers]: https://gitlab.com/polettix/autobiographical-numbers
[stage 1]: https://gitlab.com/polettix/autobiographical-numbers/-/blob/master/01-basic/autobiographical-numbers.pl
[YouTube video]: https://www.youtube.com/watch?v=lRfdMiURV4s
