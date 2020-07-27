---
title: A simplified iterative implementation of NestedLoops
type: post
tags: [ algorithm, perl ]
comment: true
date: 2020-07-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's look at an iterative evolution of [A simplified recursive
> implementation of NestedLoops][] for what [`NestedLoops`][] does.

Having an iterative counterpart of a recursive function is often useful
to gain some performance, especially in non-functional programming
languages (and in general where calling a function can be considered
*expensive*). This goes at the expense of the programmer's time
(usually) so it should really worth the effort, e.g. by doing some
profiling. Also... this might also end up with a less-efficient
implementation!

In this case, though, we go for an iterative solution for two reasons:

- we're studying!
- the iterative solution paves the way to support the *iterator*-based
  alterantive, i.e. give back an iterator (which might be used by the
  caller completely, or only partially).

Here's our iterative take on it:

<script src='https://gitlab.com/polettix/notechs/-/snippets/1999211.js'></script>

The big difference here is that we have to simulate the stack of the
functions call explicitly. To this extent, we leverage the `@indexes`
array to keep track at which "depth" level we are in the simulated
recursion.

At each stage, two things might happen:

- we reached a point in our simulated call stack where we are *beyond*
  the available dimensions (line 27). This is the time where we can
  *consume* the current state and provide the inputs to the callback
  function (line 28), then *exit* from the call because there's no
  dimension to iterate here (line 29);
- we increment the index for the *current* depth level (line 33) and
  figure out whether:
  - we exhausted the items in this specific level (i.e. our index `$i`
    went past the last available index for the specific dimension, line
    34). This means that we have to *exit* the current frame and
    backtrack (line 35);
  - we are still within the iteration, so we put the updated value in
    the `@accumulator` and do the simulated recursive call (line 39).

Each simulated recursive call is done by pushing a `-1` index in
`@indexes`, because we do a pre-increment (line 33) so we will always
start getting items from index `0`. This is the advantage of leveraging
integer indexes to access the arrays in the input `$dims`.

[Perl]: https://www.perl.org/
[`NestedLoops`]: https://metacpan.org/pod/Algorithm::Loops#NestedLoops1
[Algorithm::Loops]: {{ '/2020/07/27/algorithm-loops' | prepend: site.baseurl }}
[modulino]: https://gitlab.com/polettix/notechs/-/snippets/1868370
[A simplified recursive implementation of NestedLoops]: {{ '/2020/07/28/nested-loops-recursive' | prepend: site.baseurl }}
