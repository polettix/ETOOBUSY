---
title: All partitions of a set
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-27 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> At the very last, we can generate all [partitions of a set][].

In last post [All partitions of a set into differently arranged
subsets][] we got our last piece that separates us from generating all
[partitions of a set][].

Function `differsets_partition_iterator` takes a specific decomposition
of an integer $N$ and a list of $N$ items, providing us back all
possible partitions according to that specific decomposition.

Now we are ready to integrate this with the function we saw in [All
positive integer sums, as iterator][] and create an iterator to reach
our initial goal.

Let's get to the code:

```perl
sub all_partitions_iterator (@items) {
   my $sit = compactify(int_sums_iterator(scalar @items));
   my $ssit;
   return sub {
      while ('necessary') {
         $ssit //= do {
            my $arrangement = $sit->() or return;
            differsets_partition_iterator($arrangement, @items);
         };
         my @sequence = $ssit->() or do {
            $ssit = undef;
            redo;
         };
         return @sequence;
      }
   }
}
```

It's probably sort-of anticlimax:

- we create the `$sit` iterator to go through all possible decomposition
  of the number $N$ of items in `@items`;
- for each of those decomposition, we create an iterator and use it
  until it's exhausted and we need to move on to the next decomposition.

So... it is working?!? Let's see for the first values (considering only
non-empty sets):

```shell
--- 1 item only
     1	{ {a} }

--- 2 items
     1	{ {a b} }
     2	{ {a}, {b} }

--- 3 items
     1	{ {a b c} }
     2	{ {a b}, {c} }
     3	{ {a c}, {b} }
     4	{ {b c}, {a} }
     5	{ {a}, {b}, {c} }

--- you get the idea
     1	{ {a b c d} }
     2	{ {a b c}, {d} }
     3	{ {a b d}, {c} }
   ...
    13	{ {b d}, {a}, {c} }
    14	{ {c d}, {a}, {b} }
    15	{ {a}, {b}, {c}, {d} }

---
     1	{ {a b c d e} }
     2	{ {a b c d}, {e} }
     3	{ {a b c e}, {d} }
   ...
    50	{ {c e}, {a}, {b}, {d} }
    51	{ {d e}, {a}, {b}, {c} }
    52	{ {a}, {b}, {c}, {d}, {e} }

---
     1	{ {a b c d e f} }
     2	{ {a b c d e}, {f} }
     3	{ {a b c d f}, {e} }
   ...
   201	{ {d f}, {a}, {b}, {c}, {e} }
   202	{ {e f}, {a}, {b}, {c}, {d} }
   203	{ {a}, {b}, {c}, {d}, {e}, {f} }

---
     1	{ {a b c d e f g} }
     2	{ {a b c d e f}, {g} }
     3	{ {a b c d e g}, {f} }
   ...
   875	{ {e g}, {a}, {b}, {c}, {d}, {f} }
   876	{ {f g}, {a}, {b}, {c}, {d}, {e} }
   877	{ {a}, {b}, {c}, {d}, {e}, {f}, {g} }

---
     1	{ {a b c d e f g h} }
     2	{ {a b c d e f g}, {h} }
     3	{ {a b c d e f h}, {g} }
   ...
  4138	{ {f h}, {a}, {b}, {c}, {d}, {e}, {g} }
  4139	{ {g h}, {a}, {b}, {c}, {d}, {e}, {f} }
  4140	{ {a}, {b}, {c}, {d}, {e}, {f}, {g}, {h} }

---
     1	{ {a b c d e f g h i} }
     2	{ {a b c d e f g h}, {i} }
     3	{ {a b c d e f g i}, {h} }
   ...
 21145	{ {g i}, {a}, {b}, {c}, {d}, {e}, {f}, {h} }
 21146	{ {h i}, {a}, {b}, {c}, {d}, {e}, {f}, {g} }
 21147	{ {a}, {b}, {c}, {d}, {e}, {f}, {g}, {h}, {i} }

---
     1	{ {a b c d e f g h i j} }
     2	{ {a b c d e f g h i}, {j} }
     3	{ {a b c d e f g h j}, {i} }
   ...
115973	{ {h j}, {a}, {b}, {c}, {d}, {e}, {f}, {g}, {i} }
115974	{ {i j}, {a}, {b}, {c}, {d}, {e}, {f}, {g}, {h} }
115975	{ {a}, {b}, {c}, {d}, {e}, {f}, {g}, {h}, {i}, {j} }
```

The number of partitions is correct so I'd say that it's working fine.
Until a bug comes out, at least.

If you're interested into looking at the full code, there is a [local
copy here][].

One last thing! We can now solve challenge [PWC108 - Bell Numbers][] in
a different way:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub bell_number ($N) {
   return 1 unless $N;  # that pesky empty-set case...
   my $it = all_partitions_iterator(1 .. $N);
   my $n = 0;
   ++$n while $it->();
   return $n;
}

printf "B%d: %d\n", $_, bell_number($_) for 0 .. 9;
exit 0;

# ... put the rest of the code here...
```


Stay safe folks!


[All positive integer sums]: {{ '/2021/04/18/all-positive-integer-sums/' | prepend: site.baseurl }}
[PWC108 - Bell Numbers]: {{ '/2021/04/15/pwc108-bell-numbers/' | prepend: site.baseurl }}
[Bell numbers]: https://en.wikipedia.org/wiki/Bell_number
[Bell triangle]: https://en.wikipedia.org/wiki/Bell_triangle
[partitions of a set]: https://en.wikipedia.org/wiki/Partition_of_a_set
[ifl]: {{ '/2020/07/31/iterator-from-loop/' | prepend: site.baseurl }}
[ibi]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[All positive integer sums, as iterator]: {{ '/2021/04/19/all-positive-integer-sums-iterator/' | prepend: site.baseurl }}
[All partitions of a set into differently arranged subsets]: {{ '/2021/04/26/all-partitions-different-sets/' | prepend: site.baseurl }}
[local copy here]: {{ '/assets/code/all-partitions.pl' | prepend: site.baseurl }}
