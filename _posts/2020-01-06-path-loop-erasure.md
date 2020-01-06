---
title: Removing loops from a path
type: post
tags: [ algorithm, graph, perl ]
comment: true
date: 2020-01-06 09:52:40
mathjax: true
published: true
---

**TL;DR**

> An interesting and, after all, straightforward algorithm to remove loops
> in a path inside a graph.

Reading the [Wikipedia page on algorithmic maze
generation][wikipedia-maze], I stumbled upon the concept of a [Loop-erased
random walk][wikipedia-lerw] (or LERW), which are at the base of one of
the algorithms.

While the *random walk* is surely very important for the algorithm (which
we will discuss in due time), the loop erasure part intrigued me and here
we are.

## A data structure for the path

Our *path* will be defined as an ordered, finite sequence of *nodes*,
starting from a *source node* `S` and ending in a *target node* `T`.
In practical terms, we can think of an array of *node* identifiers (in
the following we will "confuse" these identifiers with the *nodes*
themselves).

This path may have loops or not. In our representation, it's alway
possible to detect a loop in the path, because at least one *node*
identifier will be repeated two or more times. If all entries in our array
contain a different identifier, the *path* is loop-free.

To make the following explanation a bit simpler we will remove some corner
cases where e.g. the starting *node* `S` or its target counterpart `T` can be
part of loops. To do this, we will introduce two *fictious* endoints `S'` and
`T'` respectively before `S` and after `T`, with the convention that these are
two additional nodes to the graph that do not appear anywhere in the whole
*path* from `S` to `T`. We will call this new *path* with the additional nodes
the *extended path*.

These additional items in the path can be later removed after the
simplified, loop-free path has been computed.


## Erasing loops

Erasing loops in our representation means producing a new array that is
loop-free, i.e. where all items are different from one another and, of
course, appear in the same "connected" order as the starting *path*.

By assumption, both the first *node* and the last one do not appear
anywhere in the "inner" part of the *path*, so they cannot possibly be
part of a loop. This means that `S'` is part of the simplified, loop-free
extended *path* and we will thus say that the index of the first item in
the computed loop-free path comes from position `0` of the original array:

$$ i_0 = 0 $$

Now, let's consider the item immediately following it, i.e. the one at
index `1` in the array. There are two cases:

- the identifier at that position does *not* appear later in the *path*,
  which means that it does not participate in a loop, OR
- the identifier does indeed appear other times in the path, which makes
  that *node* a crossing of one or more loops.

This latter case can be represented as follows, where `X` is the
identifier in position `1` of the array:

```
S' X   ...     X   ...     X    ...      X   ...     T'
   |---------->|---------->|------------>|---------->|
    sub-path-1  sub-path-2  sub-paths...  sub-path-N
```

It's clear that all sub-paths up to and including $N-1$ are loops, because
the start with `X` and end with `X`, which means that all of them can be
eliminated to just keep `sub-path-N` and we will still have a *path* from
`S'` to `T'`.

At this point, we have skipped all items in the array from the first
occurrence of `X` and before the *last* occurrence of `X`, and we are sure
that there are no more `X` identifier in the remaining part of the
original path. We will mark the position of this last `X` with index
$i_1$.

The situation is the following:

```
S' X   ...     X   ...     X    ...      X   ...     T'
   |---------->|---------->|------------>|---------->|
    sub-path-1  sub-path-2  sub-paths...  sub-path-N
^                                        ^
|                                        |
+-- i_0                                  +-- i_1
```

Removing loop sub-paths means that we will continue our analysis of the
*path* starting from position $i_1$ and looking at the immediately
following element, which we will assume will have identifier `Y`:

```
S' ...   X Y   ...     Y   ...     Y    ...      Y   ...     T'
           |---------->|---------->|------------>|---------->|
            sub-path-1  sub-path-2  sub-paths...  sub-path-M
^        ^
|        |
+-- i_0  +-- i_1
```

By construction, `Y` *surely* does not appear anywhere before position
$i_1$, simply because loop-erasure means that we will ignore any item
strictly included between $i_0$ and $i_1$. Again, we will toss away all
sub-paths that connect `Y` to `Y` and just keep the last one, marking the
position of the last `Y` with index $i_2$:

```
S' ...   X Y   ...     Y   ...     Y    ...      Y   ...     T'
           |---------->|---------->|------------>|---------->|
            sub-path-1  sub-path-2  sub-paths...  sub-path-M
^        ^                                       ^
|        |                                       |
+-- i_0  +-- i_1                                 +-- i_2
```

Our search now restarts from $i_2$ and moves on just like before, until we
reach `T'`, where our loop-erasure sweep stops.

The sequence of indexes $i_0, i_1, ..., i_J, i_{J+1}$ indicates the
positions in the original *path*'s array of items that participate into
the simplified, loop-free extended *path*. We now only have to remove the
first (corresponding to the fictious node `S'`) and the last
(corresponding to the fictious node `T'`) to obtain the simplified,
loop-free path.


## An example implementation

The following [Perl][] subroutine implements the algorithm:

```perl
# compute the loop-free path from $input_path
# return as anonymous array
sub path_loop_erasure ($input_path) {
    my @output_path;
    my $i = -1;
    my $N = @$input_path;
    while (++$i < $N) {

        # find latest occurrence of $input_path->[$i]
        my $j = $i;
        while (++$j < $N) {
            # "advance" $i if the corresponding item is found
            # later in the array
            $i = $j if $input_path->[$i] eq $input_path->[$j];
        }

        # whatever, this item fits into the output
        push @output_path, $input_path->[$i];
    }
    return \@output_path;
}
```

This implementation does not rely on fictious items but it is otherwise a
direct application of the algorithm seen before.

## Time's up

The path loop-erasure algorithm can be a bit daunting when you read it in
its full abstract, formal shape, but it can start to make a lot of sense
as soon as you jot down a couple examples to understand what does it mean
for a *path* to have loops. I hope the explanation above is clear,
otherwise please comment!


[wikipedia-maze]: https://en.wikipedia.org/wiki/Maze_generation_algorithm
[wikipedia-lerw]: https://en.wikipedia.org/wiki/Loop-erased_random_walk
[Perl]: https://www.perl.org/
