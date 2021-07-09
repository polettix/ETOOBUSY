---
title: 'Raku cglib: a basic priority queue'
type: post
tags: [ rakulang, algorithms ]
comment: true
date: 2021-07-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A *basic* priority queue in [Raku][].

In previous post [Raku cglib: a priority queue][] we took a look at a
priority queue implementation in [Raku][] that can be overkill when
something very easy is needed.

In particular, if all we need to store are numbers, whose value also
represents their priority, and in addition we don't need to do fancy
operations on the data structure (like removing a specific item), we can
do with a simpler implementation that only has a handful of methods:

- `enqueue` to add items to the priority queue;
- `dequeue` to take the *best* item out of it;
- `is-empty` to do the obvious test;
- `elems`/`size` to see how many elements are still in the queue.

So enter [BasicPriorityQueue.rakumod][], a newcomer in the [cglib-raku][]
library!

It comes with an example of usage, showing that it does less than
[PriorityQueue.rakumod][] but it's still useful:

```raku
sub MAIN {
   sub printall (BasicPriorityQueue $pq) {
      $pq.dequeue.say while ! $pq.is-empty;
      put '-' x 10;
   }
   printall(BasicPriorityQueue.new(items => 1 .. 5));
   printall(BasicPriorityQueue.new(items => 1 .. 5, before => {$^b < $^a}));
   my $pq = BasicPriorityQueue.new;
   $pq.enqueue(10);
   put 'top is ', $pq.top;
   $pq.enqueue(3);
   put 'top is ', $pq.top;
   $pq.enqueue(1);
   put 'top is ', $pq.top;
   $pq.enqueue(5);
   put 'top is ', $pq.top;
   put 'queue has ', $pq.size, ' elements';
   put 'queue has ', $pq.elems, ' elements';
   printall($pq);
}
```

Well... to be *completely* honest, it's possible to store more than
numbers. As long as we can provide a `before` function that accepts two
items and is capable of telling whether the first should come before the
other, we're fine. E.g. to use letters/strings:

```
before => {$^a leg $^b}
```

This, of course, allows storing also more complex data structures;

```
before => {$^a<foo> leg $^b<foo>}
```

So... the thing that is actually lost is the possibility to refer to
items by their identifier, and get rid of an item before it's extracted
from the queue in the normal way. Whether or not we need these
additional functionalities... depends on the problem at hand.

I hope one day I'll be able to use it in [CodinGame][]!!!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Raku cglib: a priority queue]: {{ '/2021/06/27/raku-priority-queue/' | prepend: site.baseurl }}
[cglib-raku]: https://github.com/polettix/cglib-raku
[BasicPriorityQueue.rakumod]: https://github.com/polettix/cglib-raku/blob/main/BasicPriorityQueue.rakumod
[PriorityQueue.rakumod]: https://github.com/polettix/cglib-raku/blob/main/PriorityQueue.rakumod
[CodinGame]: https://www.codingame.com/
