---
title: Basic Priority Queue with Heaps
type: post
tags: [ perl, algorithm, coding ]
comment: true
date: 2020-02-25 08:00:00 +0100
preview: true
---

**TL;DR**

> A heap-based priority queue, in its basic form. Almost.

While coding [cglib-perl][], I was also studying for a couple of
[Coursera][] courses about [#algorithm][]s. In particular, course
[Algorithms, Part I][] deals with *priority queues*; you can also find a
high level explanation in the relevant [page about the algorithm][algs4-pq].

Hence, it seemed just natural to leverage what I learned and implement it in
some *tight* code that I could use in [CodinGame][] - yes, in a
copy-and-paste mode, but this is life.

# What Is a Priority Queue?

A priority queue is a data structure where you can put elements in and get
them out. Differently from a regular queue - where you get elements out in
the same order as you put them in, in a *priority* queue the elements come
out according to their priority: the higher (or the lower, depending on your
metric) is the priority, the sooner they come out.

# Implementing a Priority Queue through Heaps

In a very *naive* implementation, you might just keep the elements in a
list. When you need to get something out, you just look for it.
Alternatively, you can keep the list always ordered, so that you will always
know what's the next item to get from the queue.

These implementations would be *naive* because their complexity would be
linear in the number of elements. We can do better.

Long story short, it's possible to use a *heap* to implement a priority
queue in an *efficient* way. You can find details in [this page][algs4-pq]
and, of course, in the [Algorithms, Part I][] course.

# A Perl Compact Implementation

An implementation of the heap-based priority queue can be found at
[BasicPriorityQueue.pm][]. Here it is, as of today, adapted from [the page
in algs4][algs4-pq]:

```perl
 1 package BasicPriorityQueue;
 2 use strict;     # Adapted from https://algs4.cs.princeton.edu/24pq/
 3 sub dequeue;    # see below
 4 sub enqueue;    # see below
 5 sub is_empty { return !$#{$_[0]{items}} }
 6 sub max { return $#{$_[0]{items}} ? $_[0][1] : () }
 7 sub new;        # see below
 8 sub size { return $#{$_[0]{items}} }
 9 
10 sub dequeue {    # includes "sink"
11    my ($is, $before, $k) = (@{$_[0]}{qw< items before >}, 1);
12    return unless $#$is;
13    my $r = ($#$is > 1) ? (splice @$is, 1, 1, pop @$is) : pop @$is;
14    while ((my $j = $k * 2) <= $#$is) {
15       ++$j if ($j < $#$is) && $before->($is->[$j + 1], $is->[$j]);
16       last if $before->($is->[$k], $is->[$j]);
17       (@{$is}[$j, $k], $k) = (@{$is}[$k, $j], $j);
18    }
19    return $r;
20 } ## end sub dequeue
21 
22 sub enqueue {    # includes "swim"
23    my ($is, $before) = (@{$_[0]}{qw< items before >});
24    push @$is, $_[1];
25    my $k = $#$is;
26    (@{$is}[$k / 2, $k], $k) = (@{$is}[$k, $k / 2], int($k / 2))
27      while ($k > 1) && $before->($is->[$k], $is->[$k / 2]);
28 } ## end sub enqueue
29 
30 sub new {
31    my $package = shift;
32    my $self = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
33    $self->{before} ||= sub { $_[0] < $_[1] };
34    (my $is, $self->{items}) = ($self->{items} || [], ['-']);
35    $self->enqueue($_) for @$is;
36    return $self;
37 } ## end sub new
```

The object is a hash reference (line 32) with two keys inside: `items` is
the array where items are kept, and `before` is a reference to a function
that allows us to specify what "higher priority" means. It defaults to just
comparing two items numerically (line 33).

The representation is pretty much the one described in the [algs4
page][algs4-pq]: an array whose first element is ignored. This is why
`$self->{items}` is initialized with an anonymous array containing the
placeholder string `-` as its 0-th element.

The constructor allows passing the items as an input, with key `items`. In
case it is not empty, these items are put in the queue in the "right" way,
i.e. through the `enqueue` function (line 35).

Lines 3 to 8 provide the main interface of the module:

- `dequeue` and `enqueue` are function to respectively get one element from
  the queue or add one to it;
- `is_empty` tests whether the queue is empty or not;
- `max` gets the highest priority element, while it leaves the element in
  the queue;
- `new` is a constructor for the queue;
- `size` tells how many elements are in the queue.

Both `is_empty` and `size` return a value based on `$#{...}`, which is one
less than the number of elements in the array. This is a consequence of the
fact that the 0-th element is ignored.

Getting the `max` element (i.e. the one with the highest priority) is also
straighforward, as it sits at the root of the heap, i.e. in position `1`
inside the array.

The real core of the algorithm is in the `enqueue` and `dequeue` functions.
This observations in [this page][algs4-pq] is interesting to this regard:

> Insert. We add the new item at the end of the array, increment the size of
> the heap, and then swim up through the heap with that item to restore the
> heap condition.
>
> Remove the maximum. We take the largest item off the top, put the item
> from the end of the heap at the top, decrement the size of the heap, and
> then sink down through the heap with that item to restore the heap
> condition. 

In other terms, the generic functions *swim* and *sink* are only used,
respectively, in `enqueue` and `dequeue`. This means that we can embed them
in these functions and spare a few lines. Just in the spirit of readability 🙄

The `enqueue` function puts the new element at the end of the array (line
24), then makes it *swim* up in the heap (assignments in line 26) while the
element's position is incompatible with the heap rules (line 27).

The `dequeue` function, too, implements the suggestion in the [algorithm's
page][algs4-pq]. The highest priority element is at the root, from where it
is extracted. This happens in line 13, which needs a bit of unboxing:

- if there are 2 or more elements, then the algorithm tells us to get the
  root element at index 1 in the array (`splice @$is, 1, 1` removes this
  item and returns it) and to put the last element in its place (adding a
  fourth argument to `splice` puts an element in the places left by the
  splicing operators, and `pop @$is` takes the last element);

- if there's only one element left in the queue, then it's the last element
  and we can just `pop @$is` (this is the `:` alternative in the ternary
  operator).

So, line 13 gets the return value `$r` out of the queue, and prepares the
queue itself for the *sink* operation that is performed in lines 14 to 18.

In both cases (`enqueue` and `dequeue`) the function in `before` is used to
tell different priorities apart, allowing to use the same implementation for
both the *max* and *min* priorities.

# Summing up

Priority queues are... fun! Heaps too, and the two play well together. Are
you looking for something less... *basic*? Take a look at
[PriorityQueue.pm][]!


[algs4-pq]: https://algs4.cs.princeton.edu/24pq/
[Perl]: https://www.perl.org/
[cglib-perl]: https://github.com/polettix/cglib-perl
[CodinGame]: https://www.codingame.com/
[dfv-docs]: https://github.com/polettix/cglib-perl/blob/master/DepthFirstVisit.pod
[#algorithm]: {{ '/tagged/#algorithm' | prepend: site.baseurl | prepend: site.url }}
[Coursera]: https://www.coursera.org/
[Algorithms, Part I]: https://www.coursera.org/learn/algorithms-part1
[BasicPriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/BasicPriorityQueue.pm
[PriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/PriorityQueue.pm
