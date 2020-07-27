---
title: Benchmarking simplified implementations of NestedLoops
type: post
tags: [ algorithm, perl ]
comment: true
date: 2020-07-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Iterative counterparts of recursive function are not always more
> efficient.

In [A simplified iterative implementation of NestedLoops][] I claimed
that:

> Having an iterative counterpart of a recursive function is often
> useful to gain some performance, especially in non-functional
> programming languages (and in general where calling a function can be
> considered *expensive*). This goes at the expense of the programmer's
> time (usually) so it should really worth the effort, e.g. by doing
> some profiling. Also... this might also end up with a less-efficient
> implementation!

So, the obvious reason was to do some benchmarking of the two solutions!

A direct benchmarking of the two implementations (the recursive one can
be found in [A simplified recursive implementation of NestedLoops][])
showed that the recursive one was better:

```shell
$ perl nestedloops-benchmark.pl
             Rate recursive iterative
iterative 8220/s        --      -17%
recursive 9864/s       20%        --
```

So I figured... maybe I did something wrong with the iterative
implementation, and I transformed it to this:

```perl
 1 sub nested_loops_iterative {
 2    my ($dims, $opts, $cb) = @_;
 3    return unless scalar @{$dims};
 4    ($opts, $cb) = ($cb, $opts) if ref($opts) eq 'CODE';
 5    my @indexes     = (-1);
 6    my @accumulator = (undef) x scalar @{$dims};
 7    while ((my $level = $#indexes) >= 0) {
 8       my $dimension = $dims->[$level];
 9       my $i         = ++$indexes[$level];    # advance in "this" slot
10       if ($i > $#{$dimension}) { pop @indexes }
11       else {
12          $accumulator[$level] = $dimension->[$i];
13          if   ($level == $#{$dims}) { $cb->(@accumulator) }
14          else                       { push @indexes, -1 }
15       }
16    } ## end while ((my $level = $#indexes...))
17    return;
18 } ## end sub nested_loops_iterative
```

It's a bit more compact than its predecessor, and goes one step less in
the stack, providing a benefit:

```shell
$ perl nestedloops-benchmark.pl
             Rate recursive iterative
recursive  9774/s        --      -17%
iterative 11712/s       20%        --
```

Not terribly better, but the roles have at least been switched.

Or have they?

This is not fair. The recursive implementation can get some love too:

- the same exact optimization I did for the iterative implementation
  applies to the recursive one too, allowing to remove the last level of
  function call that is also the bigger one;
- there's some arguments-fiddling at the beginning of the function that
  is done over and over, and can be separated from the actual recursion
  process.

So, I ended up with this too:

```perl
 1 sub nested_loops_recursive {
 2    my ($dims, $opts, $cb) = @_;
 3    ($opts, $cb) = ($cb, $opts) if ref($opts) eq 'CODE';
 4    return _nested_loops_recursive($dims, $opts, $cb, [], 0);
 5 } ## end sub nested_loops_recursive
 6 
 7 sub _nested_loops_recursive {
 8    my ($dims, $opts, $cb, $acc, $level) = @_;
 9    if ($level == $#{$dims}) {    # last level
10       $cb->(@{$acc}, $_) for @{$dims->[$level]};
11    }
12    else {                        # intermediate level
13       for my $item (@{$dims->[$level]}) {
14          push @{$acc}, $item;
15          _nested_loops_recursive($dims, $opts, $cb, $acc, $level + 1);
16          pop @{$acc};
17       } ## end for my $item (@{$dims->...})
18    } ## end else [ if ($level == $#{$dims...})]
19    return;
20 } ## end sub _nested_loops_recursive
```

The function is split into two parts, `_nested_loops_recursive` does
most of the job without fiddling with arguments and also the last layer
of function calls is now avoided thanks to lines 9 to 11 (i.e. a
dedicated loop for the last dimension).

This is what I ended up with:

```shell
$ perl nestedloops-benchmark.pl
             Rate iterative recursive
iterative 11669/s        --      -46%
recursive 21692/s       86%        --
```

Oh my goodness! The recursive implementation is way faster in these
tests conditions!

If you want to play with it, here is the final benchmark script:

<script src='https://gitlab.com/polettix/notechs/-/snippets/1999230.js'></script>

Lesson learned: test your gut feelings with measurements, you might need
to vary your diet.

This is enough for today, isn't it?

[A simplified recursive implementation of NestedLoops]: {{ '/2020/07/28/nested-loops-recursive' | prepend: site.baseurl }}
[A simplified iterative implementation of NestedLoops]: {{ '/2020/07/29/nested-loops-iterative' | prepend: site.baseurl }}
