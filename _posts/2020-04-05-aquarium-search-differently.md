---
title: Aquarium - search differently
type: post
tags: [ aquarium puzzle game, coding, perl, constraint programming, Aquarium ]
series: Aquarium
comment: true
date: 2020-04-05 17:48:24 +0200
published: true
---

**TL;DR**

> We continue looking for more efficient ways to solve [aquarium][], aiming
> at solving the *monthly* mega-puzzle in matters of seconds.

In [Aquarium - search the solution space][] we introduced a dumb, brute
force approach to search the solution space. It was up to the job at that
time, but now we need something a little smarter, as well as capable of
leveraging the enhancements that we introduced so far in terms of pruning.

You can find the code for this post in [stage 7][].

# Look for the best

The main insight at this point is that the choice should not be "just the
next in line", but somehow the *best* place to guess putting some water in.

One idea is to try out the *longest* horizontal streak that we find still
empty. In other terms, we look for the row that contains the most cells
belonging to a single aquarium. In any case - i.e. both if it's successful
or if it's a wrong choice - we will get rid of that amount of cells, because
they will be put either to *water* (first choice) or to *empty* (backtrack
choice).

This approach is also quite useful to interleave with the "cooperative"
constraints, because both investigation legs (i.e. the *water* first choice
and the *empty* fallback) will set a streak of cells and will (hopefully)
help the constraints perform more pruning.

# So let's code it!

We just need to change our `moves_iterator` to find out the longest
available streak and compute the two alternatives (filled with water, left
empty):

```perl
 1 sub moves_iterator ($puzzle) {
 2    my ($n, $field, $status) = $puzzle->@{qw< n field status >};
 3 
 4    my ($best_row, $best_id, $best_count);
 5    for my $row (0 .. $n - 1) {
 6       my %count_for;
 7       for my $j (0 .. $n - 1) {
 8          next if $status->[$row][$j];
 9          $count_for{$field->[$row][$j]}++;
10       }
11       for my $id (sort {$a <=> $b} keys %count_for) {
12          my $count = $count_for{$id};
13          ($best_row, $best_id, $best_count) = ($row, $id, $count)
14             if (! defined $best_row) || ($best_count < $count);
15       }
16    }
17 
18    my $alt_status = dclone($status);
19    for my $j (0 .. $n - 1) {
20       next unless $field->[$best_row][$j] == $best_id;
21       $status->[$best_row][$j] = 1;
22       $alt_status->[$best_row][$j] = -1;
23    }
24 
25    my @retval = ($status, $alt_status);
26    return sub { return shift @retval };
27 }
```

Lines 4..16 look for the *longest streak*, i.e. the best row and best
aquarium identifier that will guarantee us putting as much water (or empty
spaces) as possible in a single guess.

As anticipated, the two alternatives are pre-computed. The big time sucker
here is `dclone`, but we would have to do it anyway to save the previous
status, so it's an invariant. Hence, the only real pre-computation overhead
that we are introducing is the assignment in line 22, which should be
negligible.

The iterator itself (lines 25 and 26) is quite simple: it returns `$status`
with water at the first call, `$alt_status` the second, and a consistent
undefined value from there on.

# How does it behave?

Pretty well:

```shell
$ time ./run.sh 07-search-differently/ 15x15-hard.aqp >/dev/null && printf 'OK\n'

real	0m0.429s
user	0m0.416s
sys	0m0.008s
OK

$ time ./run.sh 07-search-differently/ daily.aqp >/dev/null && printf 'OK\n'

real	0m0.458s
user	0m0.432s
sys	0m0.016s
OK

$ time ./run.sh 07-search-differently/ weekly.aqp >/dev/null && printf 'OK\n'

real	0m7.515s
user	0m7.468s
sys	0m0.032s
OK

$ time ./run.sh 07-search-differently/ monthly.aqp >/dev/null && printf 'OK\n'

real	1m2.964s
user	1m1.764s
sys	0m0.484s
OK
```

So, we are the point where we are able to solve all the puzzles on the
site... although there's still space for some *big* improvement. Why wait
one minute when we can wait one second?!?

[aquarium]: https://www.puzzle-aquarium.com/
[Aquarium - search the solution space]: {{ '/2020/04/02/aquarium-search/' | prepend: site.baseurl | prepend: site.url }}
[stage 7]: https://gitlab.com/polettix/aquarium-solver/-/blob/master/07-search-differently/aquarium.pl
