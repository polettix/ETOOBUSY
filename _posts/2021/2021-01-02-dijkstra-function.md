---
title: Dijkstra Algorithm - as functions only
type: post
tags: [ cglib, perl ]
comment: true
date: 2021-01-02 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I made a version of [Dijkstra.pm][] that returns two sub references
> instead of an object: [DijkstraFunction.pm][].

Some time ago (in 2017, according to [git][] [blame][git-blame]) I
translated the code for the [Dijkstra Algorithm][] from [its Java
implementation][dijkstra-java] into [Perl][], resulting in
[Dijkstra.pm][] inside [cglib][].

If you (yes, I'm looking at you, future me!) need a refresher for what
this algorithm is good for... suffices to say that is solves the *single
source shortest paths* problem. In brief, you have one starting node
(that is the *single source*) and it computes the minimul distance, as
well as the path with that distance, towards every other (reachable)
node in the graph.

As I've probably already written elsewhere, [cglib][] is explicitly
coded as a *copy-and-paste* library of functions. For this reason, I was
not entirely happy with the implementation because it returned an object
(blessed into the `Dijkstra` package).

Inspired by other functions in that library, I decided to code an
alternative [DijkstraFunction.pm][] library file that does pretty much
the same (with the same code! Duplication!!!) but returns a hash
reference instead.

```perl
   return {
      path_to => sub {
         my ($v) = @_;
         my $vid = $id_of->($v);
         my $thr = $thread_to{$vid} || return; # connected?

         my @retval;
         while ($v) {
            unshift @retval, $v;
            ($v, $vid) = @{$thr}{qw< p pid >};
            $thr = $thread_to{$vid};
         }
         return wantarray ? @retval : \@retval;
      },
      distance_to => sub { ($thread_to{$id_of->($_[0])} || {})->{d} },
   };
```

This hash contains two keys: `path_to` and `distance_to`. The
corresponding value is a subroutine reference that allows calculating
the path, or the distance, towards a provided target vertex.

So... enjoy [DijkstraFunction.pm][]!

[git]: https://www.git-scm.com/
[git-blame]: https://www.git-scm.com/docs/git-blame
[Dijkstra Algorithm]: https://algs4.cs.princeton.edu/44sp/
[dijkstra-java]: https://algs4.cs.princeton.edu/44sp/DijkstraSP.java.html
[Perl]: https://www.perl.org/
[Dijkstra.pm]: https://github.com/polettix/cglib-perl/blob/master/Dijkstra.pm
[DijkstraFunction.pm]: https://github.com/polettix/cglib-perl/blob/master/DijkstraFunction.pm
[cglib]: https://github.com/polettix/cglib-perl/
