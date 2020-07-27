---
title: Loop from iterator
type: post
tags: [ algorithm, loop ]
comment: true
date: 2020-08-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> If we have an iterator... it's easy to go back to a full loop.

In last post [Iterator from loop][] we saw a generic technique to get an
iterator from a full loop, so that we can go through each iteration at
will.

When we have an iterator, it's then easy to implement a full loop based
on it, e.g. to feed a callback function with all the iterations. In
other terms, it's easy to re-implement `iterate_over_array` based on
`simple_iterator`:


```perl
sub simple_iterator {
    my ($input_array) = @_;
    my $i = 0; # this will index into $input_array
    return sub {
        return unless $i <= $#{$input_array};
        return $input_array->[$i++];
    };
}
sub iterate_over_array {
    my ($input_array, $callback) = @_;
    my $it = simple_iterator($input_array);
    while (my @items = $it->()) {
        $callback->(@items);
    }
}
```

As you might imagine, this is exactly what happens in
[Algorithm::Loops][]'s [`NestedLoops`][].

Nifty, uh?


[Iterator from loop]: {{ '/2020/07/31/iterator-from-loop' | prepend: site.baseurl }}
[Algorithm::Loops]: https://metacpan.org/pod/Algorithm::Loops
[Perl]: https://www.perl.org/
[`NestedLoops`]: https://metacpan.org/source/TYEMQ/Algorithm-Loops-1.032/lib/Algorithm/Loops.pm#L305
