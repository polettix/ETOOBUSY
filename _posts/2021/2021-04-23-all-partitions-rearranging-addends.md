---
title: All partitions of a set - rearranging addends
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-23 07:00:00 +0200
mathjax: true
published: true
---

> Rearranging addends after [All partitions of a set - preliminary
> considerations][].

Armed with our iterator-based implementation, it's easy to tweak it to
generate the sequence according to the following representation:

$$
N = \sum_{j = 1}^{J}{k_j \cdot n_j}
$$

where $k_j$ is the count (or maybe the *kount*?) of times that addend
$n_j$ appears in the specific sum.

We *just* have to produce an iterator that takes our iterator as input,
and produces the different sequences.

Too complicated? Another way of seeing this is: let's group all addends
that have the same value and keep a count of their occurrences, so that
instead of this:

```
6 = 6
6 = 5 + 1
6 = 4 + 2
6 = 4 + 1 + 1
6 = 3 + 3
6 = 3 + 2 + 1
6 = 3 + 1 + 1 + 1
6 = 2 + 2 + 2
6 = 2 + 2 + 1 + 1
6 = 2 + 1 + 1 + 1 + 1
6 = 1 + 1 + 1 + 1 + 1 + 1
```

we write this:

```
6 = (1 * 6)
6 = (1 * 5) + (1 * 1)
6 = (1 * 4) + (1 * 2)
6 = (1 * 4) + (2 * 1)
6 = (2 * 3)
6 = (1 * 3) + (1 * 2) + (1 * 1)
6 = (1 * 3) + (3 * 1)
6 = (3 * 2)
6 = (2 * 2) + (2 * 1)
6 = (1 * 2) + (4 * 1)
6 = (6 * 1)
```

where `(X * Y)` means *`X` occurrences of value `Y`*.

Let's take a look at the implementation:

```perl
sub int_sums_iterator ...;

sub compactify ($it) {
   return sub {
      my $list = $it->() or return;
      my @retval;
      for my $item ($list->@*) {
         if (@retval && $item == $retval[-1][1]) {
            $retval[-1][0]++;
         }
         else {
            push @retval, [1, $item];
         }
      }
      return \@retval;
   }
}

my $it = int_sums_iterator(shift || 3); # from previous posts...
my $cit = compactify($it);
while (my $list = $cit->()) {
   say join ' + ', map { '(' . join(' * ', $_->@*) . ')' } $list->@*;
}
```

The new iterator is built *around* the previous one. It still gives out
lists wrapped in anonymous arrays, but this time its items are not
integer scalars but anonymous arrays themselves, where the first item is
the count of occurrences and the second item is the number appearing in
the specific decomposition.

We hope that this will be... useful for our goal 😅

[All positive integer sums]: {{ '/2021/04/18/all-positive-integer-sums/' | prepend: site.baseurl }}
[PWC108 - Bell Numbers]: {{ '/2021/04/15/pwc108-bell-numbers/' | prepend: site.baseurl }}
[Bell numbers]: https://en.wikipedia.org/wiki/Bell_number
[Bell triangle]: https://en.wikipedia.org/wiki/Bell_triangle
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
[ifl]: {{ '/2020/07/31/iterator-from-loop/' | prepend: site.baseurl }}
[ibi]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[All positive integer sums, as iterator]: {{ '/2021/04/19/all-positive-integer-sums-iterator/' | prepend: site.baseurl }}
[All partitions of a set - preliminary considerations]: {{ '/2021/04/20/all-partitions-preliminary/' | prepend: site.baseurl }}
