---
title: All partitions of a set - preliminary considerations
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> We go on with finding all [partitions of a set][], following the track
> started with [PWC108 - Bell Numbers][].

In previous post [All positive integer sums][] we laid out a possible
strategy for finding all (distinct) [partitions of a set][].

The first half was to find out all possible ways to express a positive
integer as the sum of other (lower or equal) positive integers; this has
been addressed and led us to the iterator-based solution described in
[All positive integer sums, as iterator][].

Now... we're *only* left with generating the sets starting from these
partial sums. Let's take a first look at the case for $N = 3$:

{% raw %}
$$
(3) \Rightarrow \{\{a, b, c\}\} \\
(2 + 1) \Rightarrow \{\{a, b\}, \{c\}\} \\
(2 + 1) \Rightarrow \{\{a, c\}, \{b\}\} \\
(2 + 1) \Rightarrow \{\{b, c\}, \{a\}\} \\
(1 + 1 + 1) \Rightarrow \{\{a\}, \{b\}, \{c\}\}
$$
{% endraw %}

There is an obvious factor that has to be taken into considerations: we
have *three* distinct expansions for $2 + 1$, but only one for $1 + 1 + 1$.

In general, any subset of equal addends in the sum have to be taken with
care in order to avoid duplicates; this does not happen, of course,
across different values. For this reason, the $2 + 2$ decomposition for
$4$ has to be taken with care too, or we would have duplicates. In other
words, the following are the *only* distinct partitions of the type $2 +
2$:

{% raw %}
$$
\{\{a, b\}, \{c, d\}\} \\
\{\{a, c\}, \{b, d\}\} \\
\{\{a, d\}, \{b, c\}\} \\
$$
{% endraw %}

Any partition with the $a$ in the *second* subset would lead to a
partition that is equivalent to one of the above, i.e. a duplicate.

Summing up, when generating all partitions starting from our
decomposition of the integer input into possible sums, we will have to
address the subsets of equal addends as a kind of *unit* with a specific
algorithm.

For this reason, it's useful to express the generic sum
decomposition like this:

$$
N = \sum_{j = 1}^{J}{k_j \cdot n_j}
$$

where $n_j$ represents the addendum value and $k_j$ represents how many
that addendum appears in the decomposition. This would mean the
following:

$$
3 = 3 = 1 \cdot 3 \\
3 = 2 + 1 = 1 \cdot 2 + 1 \cdot 1 \\
3 = 1 + 1 + 1 = 3 \cdot 1
$$

Enough for the preliminary considerations... stay safe!

[All positive integer sums]: {{ '/2021/04/18/all-positive-integer-sums/' | prepend: site.baseurl }}
[PWC108 - Bell Numbers]: {{ '/2021/04/15/pwc108-bell-numbers/' | prepend: site.baseurl }}
[Bell numbers]: https://en.wikipedia.org/wiki/Bell_number
[Bell triangle]: https://en.wikipedia.org/wiki/Bell_triangle
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
[ifl]: {{ '/2020/07/31/iterator-from-loop/' | prepend: site.baseurl }}
[ibi]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[All positive integer sums, as iterator]: {{ '/2021/04/19/all-positive-integer-sums-iterator/' | prepend: site.baseurl }}
