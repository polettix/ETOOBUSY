---
title: Iterator for NestedLoops
type: post
tags: [ algorithm, perl ]
series: Algorithm::Loops
comment: true
date: 2020-08-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's turn our iterative solution from [A simplified iterative
> implementation of NestedLoops][] into an iterator.

It's about time to turn the iterative solution for NestedLoops into an
iterator. We will start from the optimized version found in
[Benchmarking simplified implementations of NestedLoops][]:

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

It's quite clear that `@indexes` and `@accumulator` will keep track of
the state, and that instead of calling the `$cb` as in line 13 we will
have "just" to return the contents of `@accumulator`:

```perl
 1 sub nested_loops_iterator {
 2    my ($dims, $opts, $cb, $accumulator) = @_;
 3    return unless scalar @{$dims};
 4    ($opts, $cb) = ($cb, $opts) if ref($opts) eq 'CODE';
 5    my @indexes     = (-1);
 6    my @accumulator = (undef) x scalar @{$dims};
 7    return sub {
 8       while ((my $level = $#indexes) >= 0) {
 9          my $dimension = $dims->[$level];
10          my $i         = ++$indexes[$level];
11          if ($i > $#{$dimension}) { pop @indexes }
12          else {
13             $accumulator[$level] = $dimension->[$i];
14             if   ($level == $#{$dims}) { return @accumulator }
15             else                       { push @indexes, -1 }
16          }
17       }
18       return;
19    }
20 }
```

As you can see, the change is quite minimal!

A full *modulino* is shown below:

<script src='https://gitlab.com/polettix/notechs/-/snippets/1999414.js'></script>

Until next time... take care!

[A simplified recursive implementation of NestedLoops]: {{ '/2020/07/28/nested-loops-recursive' | prepend: site.baseurl }}
[A simplified iterative implementation of NestedLoops]: {{ '/2020/07/29/nested-loops-iterative' | prepend: site.baseurl }}
[Benchmarking simplified implementations of NestedLoops]: {{ '/2020/07/30/nested-loops-benchmark' | prepend: site.baseurl }}
