---
title: Simpler Priority Queue
type: post
tags: [ algorithm, perl, cglib ]
comment: true
date: 2020-11-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Where I remember that I had a simpler solution for the priority queue I
> used in [PWC087 - Largest Rectangle][].

**Note for future me**: there is a simpler implementation of the priority
queue in [BasicPriorityQueue.pm][]. If you don't need the generic *indexed*
priority queue... use it!

Fun fact: in the [PWC087 - Largest Rectangle][] it is actually a drop-in
replacement for [PriorityQueue.pm][] - again, because indexing is not used
in this case. So, getting an instance of the priority queue would become:

```perl
my $mpq = BasicPriorityQueue->new(before => sub {$_[0]{size} > $_[1]{size}});
```

**Note for short-term future me**: document this thing, slacker!!!

[PWC087 - Largest Rectangle]: {{ '/2020/11/19/pwc087-largest-rectangle/' | prepend: site.baseurl }}
[BasicPriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/BasicPriorityQueue.pm
[PriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/PriorityQueue.pm
