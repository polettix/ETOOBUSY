---
title: A simplified recursive implementation of NestedLoops
type: post
tags: [ algorithm, perl ]
series: Algorithm::Loops
comment: true
date: 2020-07-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's look at a simplified implementation for what [`NestedLoops`][]
> does.

In the previous post about [Algorithm::Loops][] we took a look at
[`NestedLoops`][], a fine sub that allows building nested iterations
over a variable number of dimensions.

A possible implementation that is compatible in interface but only
offers a subset of the functionalities is the following:

<script src='https://gitlab.com/polettix/notechs/-/snippets/1999093.js'></script>

It's coded recursively, which in my opinion simplifies the
implementation and figuring out what's going on. Basically:

- lines 8 to 18 implment the [modulino][] trick
- line 25 tests whether there are still new levels to iterate to, if not
  then the callback is called in line 26 and the call returns;
- oterhwise, lines 29 to 33 implement one of the nested loops for the
  specifi level, then recurse (line 31). The recursive call has
  `$accumulator` with all elements currently generated at the available
  levels.

The implementation is *simplified* in the sense that:

- hash reference `$opts` is supported in the interface but ignored
- the iteration only accounts for arrays of items and does not support
  code references
- there is no support for returning an iterator.



[Perl]: https://www.perl.org/
[`NestedLoops`]: https://metacpan.org/pod/Algorithm::Loops#NestedLoops1
[Algorithm::Loops]: {{ '/2020/07/27/algorithm-loops' | prepend: site.baseurl }}
[modulino]: https://gitlab.com/polettix/notechs/-/snippets/1868370
