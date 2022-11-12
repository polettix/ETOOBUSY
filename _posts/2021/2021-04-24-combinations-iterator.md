---
title: Combinations iterator
type: post
tags: [ perl weekly challenge, combinatorics, maths, perl ]
series: Perl Weekly Challenge 108
comment: true
date: 2021-04-24 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> A little deviation to take a look at an iterator for [combinations][].

One thing that is clear in this little series of post is that, at a
certain point, we will have to compute [combinations][], i.e. take a
given number $k$ out of a set of $n$, possibly computing the remaining
$n - k$ while we're at it.

Here's an implementation, iterator-based:

```perl
sub combinations_iterator ($k, @items) {
   my @indexes = (0 .. ($k - 1));
   my $n = @items;
   return sub {
      return unless @indexes;
      my (@combination, @remaining);
      my $j = 0;
      for my $i (0 .. ($n - 1)) {
         if ($j < $k && $i == $indexes[$j]) {
            push @combination, $items[$i];
            ++$j;
         }
         else {
            push @remaining, $items[$i];
         }
      }
      for my $incc (reverse(-1, 0 .. ($k - 1))) {
         if ($incc < 0) {
            @indexes = (); # finished!
         }
         elsif ((my $v = $indexes[$incc]) < $incc - $k + $n) {
            $indexes[$_] = ++$v for $incc .. ($k - 1);
            last;
         }
      }
      return (\@combination, \@remaining);
   }
}
```

It is called like this:

```perl
my $it = combinations_iterator(2, qw< a b c d e >);
```

which means: iterate through all possible subsets of two letters from
the input of five letters. It can be used like this:

```perl
while (my ($c, $r) = $it->()) {
    say "($c->@*) | ($r->@*)";
}
```

with this result:

```
(a b) | (c d e)
(a c) | (b d e)
(a d) | (b c e)
(a e) | (b c d)
(b c) | (a d e)
(b d) | (a c e)
(b e) | (a c d)
(c d) | (a b e)
(c e) | (a b d)
(d e) | (a b c)
```

At each call, the iterator returns both the `$k` subset, as well as its
complement in the overall set. This will make things easier later on,
because each of these two subsets will be further... *iterated*.

The iteration mechanism is basic: start taking the first two items, then
keep the first fixed and take all other items in the second place. When
done, advance the first and start over from the item immediately after,
and so on. This approach is easily generalized as coded above.

Enough for today! Have a good rest of the day and stay safe!

[combinations]: https://en.wikipedia.org/wiki/Combination
