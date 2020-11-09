---
title: Monte Carlo Tree Search - an implementation
type: post
tags: [ algorithm, monte carlo tree search, coding, perl ]
comment: true
date: 2020-11-10 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> There's an implementation of the [Monte Carlo tree search][] in [cglib][],
> my library for [CodinGame][].

We already scratched the surface about this algorithm in previous post
[Monte Carlo Tree Search - basics][]. I've found that many times it's better
to bang my head over an implementation so that I can really understand the
ins and outs of an algorithm.

The implementation (in [Perl][], of course!) can be found at
[MonteCarloTreeSearch.pm][], with some documentation at
[MonteCarloTreeSearch.pod][]. And yes, I should really, really start to
write proper tests for all this stuff.

Or, for what matters, start using it in [CodinGame][] 🙄

My plan is to comment a bit on the code in the future posts... so stay
tuned!

[Monte Carlo tree search]: https://en.wikipedia.org/wiki/Monte_Carlo_tree_search
[cglib]: https://en.wikipedia.org/wiki/Monte_Carlo_tree_search
[CodinGame]: https://www.codingame.com/
[Monte Carlo Tree Search - basics]: {{ '/2020/11/09/mcts-basics' | prepend: site.baseurl }}
[MonteCarloTreeSearch.pm]: https://github.com/polettix/cglib-perl/blob/master/MonteCarloTreeSearch.pm
[MonteCarloTreeSearch.pod]: https://github.com/polettix/cglib-perl/blob/master/MonteCarloTreeSearch.pod
[Perl]: https://www.perl.org/
