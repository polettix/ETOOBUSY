---
title: All partitions of a set - W. Luis Mochán style
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-05-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> [W. Luis Mochán][] [explains][] a much simpler way to generate all
> [partitions of a set][].

I am *so* happy and humbled for having discovered that it's possible to
generate an iterator for all [partitions of a set][] with a quite
compact implementation:

```perl
sub all_partitions_iterator_wlm_style (@items) {
   return sub { state $r = 0; return $r++ ? () : [] } if @items == 0;
   my $last = pop @items;
   my ($pit, @presets, @postsets);
   return sub {
      $pit //= all_partitions_iterator_wlm_style(@items);
      if (@postsets == 0) { (@postsets, @presets) = $pit->() or return }
      my @pres = @presets;
      push @presets, my $set = shift @postsets;
      return (@pres, [$set->@*, $last], @postsets ? @postsets : []);
   };
}
```

This is it. You can throw away pretty much the whole series of posts
regarding this topic, and only use the function above.

It's *almost* a drop-in replacement for what described in previous post
[All partitions of a set][], with the following changes:

- I figured that a proper representation of a partition should also
  include the *empty set*. Hence, the output always includes the empty
  set as well.
- The order in which partitions are emitted is different from the
  previous one.

For the latter point, I have to admit that I liked the sorting in my
original implementation best. On the other hand, this implementation is
*so much simpler* that this aspect goes in second, or maybe third or
fourth row.

Regarding the first bullet, this is actually scratching my itch with the
seeming difference between $B_0$ and $B_n$ with $n > 0$, because the
justification for $B_0 = 1$ is that there is one partition containing
the empty set.

Why should the empty set disappear in later partitioning actions?

The obvious reason is that this empty set is probably of little to no
benefit for *using* a partition (most probably it will be ignored), so
removing it in the first place can be handy.

On the other hand... I'm still convinced that it belongs (or at least
*it can belong*) to any partition, so why not including it? It also
makes the implementation shorter 😄 Besides, if you don't want to fiddle
with the empty set, you can just ignore it because it's always located
at the end of the list.

So... thanks [W. Luis Mochán][] for putting the partitioning problem in
such a simple way to understand, and to [Colin Crain's review][] for
making it easy to find interesting stuff!

[explains]: https://wlmb.github.io/2021/04/12/PWC108/
[W. Luis Mochán]: https://wlmb.github.io/about/
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
[All partitions of a set]: {{ '/2021/04/27/all-partitions/' | prepend: site.baseurl }}
[Colin Crain's review]: https://perlweeklychallenge.org/blog/review-challenge-108/
