---
title: Support of dynamic dimensions for nested loops
type: post
tags: [ algorithm, perl ]
comment: true
date: 2020-08-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's go past fixed arrays in nested loops and allow for dynamically
> generate them based on the specific position on the loop.

One thing that [`NestedLoops`][] allows doing is to pass sub references
instead of array references to dynamically generate the items in a
specific layer. This allows, for example, doing something like this
(taken from the module's documentation):

```perl
use Algorithm::Loops qw( NestedLoops );
my $depth= 3;
NestedLoops(
    [   [ 0..$N ],
        ( sub { [$_+1..$N] } ) x ($depth-1),
    ],
    \&Stuff,
);
```

One unfortunate thing is that I could not find what is the exact
interface of these subs, a quick look at the code seems to hint that:

- `$_` is localized with the latest value in the *previous* level of
  looping;
- all items for all previous levels are passed through `@_`.

This means that the *first* item must always be an array reference
(otherwise we could not put anything in `$_`). We will make the same
assumption.

Without further ado... here's the implementation of the iterator
solution with this enhancement:

<script src='https://gitlab.com/polettix/notechs/-/snippets/1999978.js'></script>

We're making our implementation much closer to a recursive one, to some
extent: our `@indexes` now tracks an explicit `@stack`, which contains
*frames* with all variables that have to be dynamically evolved during
the computation.

The other *big* change is in lines 40 to 48, where we figure out whether
we have to call the sub dynamically and then put a new item onto the
stack, with the right data.

Example run:

```shell
     1	A-2-Foo
     2	A-2-Bar
     3	A-2-Baz
     4	A-3-foo
    ...
    26	C-2-Bar
    27	C-2-Baz
    28	C-3-foo
    29	C-3-bar
    ...
    71	F-7-bar
    72	F-7-baz
```

Seems to be working!

We have been looking at the most interesting aspects of implementing
[`NestedLoops`][], at least for study reasons... I guess that by now you
know where to look for a solution to this kind of problems 😄


[`NestedLoops`]: https://metacpan.org/pod/Algorithm::Loops#NestedLoops1
