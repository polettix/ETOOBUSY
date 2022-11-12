---
title: Floyd-Warshall algorithm implementations
type: post
tags: [ algorithms, perl, rakulang ]
comment: true
date: 2021-07-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Two implementations of the [Floyd-Warshall algorithm][].

In recent post [PWC118 - Adventure of Knight][] I gave a solution
leveraging the [Floyd-Warshall algorithm][], which is an *all-pairs
shortest path* algorithm for directed, weighted graphs (which means that
it's easily used in undirected non-weighted graphs too).

The *all pairs* part refers to the fact that the algorithm's output is
the shortest path across *each possible pair of nodes* in the graph
(other ones, like [Dijkstra's algorithm][], are so-called *single
source* because they concentrate on the shortest path from a specific
node to all othe others).

I did an implementation in [Perl][] some time ago, available in
[cglib-perl][]. The fun part is that [I mistakenly did
this][fw-original]:

```perl
use PriorityQueue;
```

which I also [copied into the code for the challenge][], but the
algorithm does **not** use a priority queue. Whatever, it's now correct
in [FloydWarshall.pm][].

More recently, I also added a porting of the implementation to [Raku][],
as part of [cglib-raku][]; the result is [FloydWarshall.rakumod][].

It has an object-oriented interface, which is probably better than the
half-baked OO-ish solution that I chose (returning a few sub references
to get the needed information), but overall it's the same as the
[Perl][] module. Well, with the exception that in the [Perl][] version
you can pass one `start` node as a scalar or multiple `starts` nodes as
an array reference, while in the [Raku][] implementation you only get
`starts` (pass one single item in case).

I hope they can be helpful!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[cglib-perl]: https://github.com/polettix/cglib-perl
[cglib-raku]: https://github.com/polettix/cglib-raku
[Floyd-Warshall algorithm]: https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
[Dijkstra's algorithm]: https://en.wikipedia.org/wiki/Dijkstra's_algorithm
[fw-original]: https://github.com/polettix/cglib-perl/blob/e8d02b65cfb7f6cc4cf1c7cccdfa97bfacc5c6cb/FloydWarshall.pm#L3
[FloydWarshall.pm]: https://github.com/polettix/cglib-perl/blob/master/FloydWarshall.pm
[PWC118 - Adventure of Knight]: {{ '/2021/06/24/pwc118-adventure-of-knight/' | prepend: site.baseurl }}
[FloydWarshall.rakumod]: https://github.com/polettix/cglib-raku/blob/master/FloydWarshall.rakumod
[copied into the code for the challenge]: https://github.com/manwar/perlweeklychallenge-club/blob/8ba82f9d9d3cdb76cdc8f5ad90524ecd164a6dc7/challenge-118/polettix/perl/ch-2.pl#L222
