---
title: All partitions of a set into same-sized subsets
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-25 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Finding all distinct [partitions of a set][] into same-sized subsets.
> Almost there!

As we observed in previous post [All partitions of a set - preliminary
considerations][], partitioning a set into same-sized subsets is a bit
*more* challenging because we must avoid repeating creating the same
configurations over and over.

There are two ways to accomplish this:

- *rejection method*: go through all possible arrangements, keep track
  of the *new* ones and reject the duplicates as the appear;
- *minimal generation*: find a way to only generate unique items in the
  first place.

Previous posts about finding all the ways to partition an integer and
gruoping them should give an hint that... we're going the second route 😄

In this post, we will concentrate on what happens when we want to
partition a set into same-sized subsets. As an example, let's consider
a starting set of $4$ items, partitioned into $2$-items subsets:

{% raw %}
$$
\{\{a, b\}, \{c, d\}\} \\
\{\{a, c\}, \{b, d\}\} \\
\{\{a, d\}, \{b, c\}\} \\
$$
{% endraw %}

It's clear that we have to stop here: any other possible layout will
just be a variation upon one of the arrangements above, e.g.:

{% raw %}
$$
\{\{b, a\}, \{c, d\}\} \iff \{\{a, b\}, \{c, d\}\} \iff
\{\{c, d\}, \{a, b\}\}
$$
{% endraw %}

because in each subset (or set of subsets) we only care about the items
that are inside, not how they are ordered when we write them down.

How should we move on? A key insight in this case comes from trying to
actually *impose* an ordering, making sure that we only take the
"lowest" representative in all equivalent representations. This is
easily done in the code, because we will pass the sets around
represented as lists, which naturally carry an ordering of the items in
the sets (i.e. their position in the list).

So, for example, in whatever partition of an $n \cdot k$ items set into
$n$ subsets of size $k$, it makes sense to only consider the partitions
where the very first item in the big set appears as the first item of
the first subset:

{% raw %}
$$
\{a, b, c, ...\} \to
\{\{a, ...\}, ...\} \\
$$
{% endraw %}

After fixing this item, we then draw all possible distinct $k-1$ subsets
from the remaining $n \cdot k - 1$ items in the starting set, to fill in
the rest of the first subset:

{% raw %}
$$
\{a, b, c, ...\} \to
\{\{a, X_2, X_3, ..., X_k\}, ...\} \\
$$
{% endraw %}

At each step, this leaves us with a set of $(n - 1) \cdot k$ items, that
we can partition using the same approach recursively, landing on a $(n - 2) \cdot k$
set of remaining items, and so on until we use all items in the original set.

Lost? Let's take a look at the code:

```perl
sub equalsets_partition_iterator ($k, @items) {
   if ($k == 1) { # there's only one way to do this... let's do it!
      my @retval = map { [$_] } @items;
      return sub {
         (my @rv, @retval) = @retval;
         return @rv;
      };
   }
   if ($k == @items) {
      my @retvals = ([@items]);
      return sub { @retvals ? shift @retvals : () };
   }
   my @leader = shift @items;
   my $cit = combinations_iterator($k - 1, @items);
   my $rit;
   return sub {
      return unless $cit;
      while ('necessary') {
         $rit //= do {
            my ($lref, $rref) = $cit->() or do {
               $cit = undef;
               return;
            };
            splice @leader, 1; # keep first item (only)
            push @leader, $lref->@*;
            equalsets_partition_iterator($k, $rref->@*);
         };
         my @sequence = $rit->() or do {
            $rit = undef;
            next;
         };
         return ([@leader], @sequence);
      }
   };
}
```

Our inputs are:

- the size of the subsets $k$, as variable `$k`;
- the list of `@items` representing the set we want to partition. Its
  size represents $n \cdot $k$.

The initial two `if` checks take care of the two corner cases which
provide a trivial solution:
- if $k$ is one, there is only one single partition (i.e. the one
  composed of all singletons);
- if $k$ is equal to the number of items, there is only one single
  partition (i.e. the set of all items).

Admittedly, we should also check for wrong inputs, like the number of
items not being a multiple of $k$, or being $0$. It's an easy exercise
for the reader 🙄

If there are more items than $k$, it's time to apply our algorithm
above. Our variable `@leader` will hold our "first" subset; we pre-load
it with the very first item in `@items`, as explained. During the rest
of the execution in this iterator, we will always preserve this item,
and fill the rest with a suitable combination from the remaining
`@items` (note that we do a `shift` to remove this initial item from the
extraction of combinations).

The iterator follows a typical pattern: an indefinite loop that will
either emit a new partitioning, or the empty list.

There are two iterators of interest here:

- `$cit` iterates through the *combinations* of $k - 1$ items over the
  `@items` that remain after removing the very first one. It is
  initialized just after `@leader`;
- `$rit` is the *recursion* iterator that takes care to iterate through
  all the partitions of $(n - 1) \cdot k$ items; it is initialized every
  time we take out a new combination, using the items from `@items` that
  were *not* chosen for the combination to fill in the `@leader` (this
  thanks to the interface provided by `combinations_iterator`).

Funny, uh?

[PWC108 - Bell Numbers]: {{ '/2021/04/15/pwc108-bell-numbers/' | prepend: site.baseurl }}
[Bell numbers]: https://en.wikipedia.org/wiki/Bell_number
[Bell triangle]: https://en.wikipedia.org/wiki/Bell_triangle
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
[All partitions of a set - preliminary considerations]: {{ '/2021/04/20/all-partitions-preliminary/' | prepend: site.baseurl }}
