---
title: A block... blocks
type: post
tags: [ perl ]
comment: true
date: 2021-06-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Unsuprisingly, a BLOCK in [Perl][] **blocks** a lot of things,
> including a `package` statement.

Back then when I was working at [cglib-perl][], a small collection of
algorithms implemented in [Perl][] to ease my life with the puzzles in
[CodinGame][], I came up with an implementation of the [Dijkstra's
algorithm][], available in [Dijkstra.pm][original Dijkstra.pm].

The *high level structure* of the module is that there is a function
`dijkstra`, which returns an object in package/class `Dijkstra` that is
possible to query for getting the output information (distance and/or
path between the source and a target node):

```perl
package Dijkstra;
...;
sub dijkstra {
   ...;
   return bless {...}, 'Dijkstra';
} ## end sub dijkstra

package Dijkstra; # repetita juvant... especially with cut-and-paste
use strict;

sub path_to     { ... }
sub distance_to { ... }
1;
```

I didn't like this arrangement too much, tough, because one of the goals
of this library is to be *copy-and-paste friendly* and that `package`
declaration might be easily overlooked.

This led me to code a mostly equivalent implementation in
[DijkstraFunction.pm][]. The difference is that the function returns a
hash with two keys pointing to the respective sub references to get the
`distance_to` and the `path_to` a target node:

```perl
package DijkstraFunction;
...
sub dijkstra {
   ...;
   return {
      path_to     => sub { ... },
      distance_to => sub { ... },
   };
} ## end sub dijkstra
1;
```

There we are: I can easily grab `sub dijkstra { ... }` only and be done
with it. Very, very *copy-and-paste friendly*!

The same design was also adopted by the implementation of other
algorithms, e.g. in [FloydWarshall.pm][]:

```perl
sub floyd_warshall {
   ...;
   return {
      has_path => sub { ... },
      distance => sub { ... },
      path     => sub { ... },
   };
}
```

It works, but still tastes a lot like a poor's man version of an
object-orientedish thing that might be done better.

One first observation that *present me* has for *past me* is that the
`package` declaration in the middle of [Dijkstra.pm][] is not strictly
necessary, because the following would work as well:

```perl
package Dijkstra;
...;
sub dijkstra {
   ...;
   return bless {...}, 'Dijkstra';
} ## end sub dijkstra
sub Dijkstra::path_to     { ... }
sub Dijkstra::distance_to { ... }
1;
```

This is *copy-and-paste friendly*-ish because we can copy from `sub
dijkstra` up to `sub Dijkstra::distance_to`; still I'm not fully happy
because it might be easy to eventually disconnect sub `dijkstra` from
the other two as the code evolves, with the potential to lose either
one.

*Recent me* discovered a simple truth that's been shining under the sun
for a long, long time: `package` declarations are confined to the
enclosing BLOCK. In other terms, a BLOCK blocks a `package` declaration,
avoiding it to spill out.

This leads to what should have been the solution in the first place:

```perl
package Dijkstra;
...;
{
   sub dijkstra {
      ...;
      return bless {...}, 'Dijkstra';
   } ## end sub dijkstra

   package Dijkstra;
   sub path_to     { ... }
   sub distance_to { ... }
}
1;
```

This has multiple advantages:

- it restricts the range (well, *scope*!) of the `package` declaration
  *inside* the BLOCK (not the one *outside*) to the BLOCK itself;
- it does not force `sub dijkstra` to be inside `package Dijkstra` (it
  is in the file, but copy-and-paste can leave that out);
- it keeps the subs close to one another.

This make it is super *copy-and-paste friendly*: let's just get the
whole block and we're done.

If only *past me* had known this... he would have coded the new
[Dijkstra.pm][] 😄

[original Dijkstra.pm]: https://github.com/polettix/cglib-perl/blob/535534f4333c6240f8f2f3622d8a424288f63ca4/Dijkstra.pm
[Dijkstra.pm]: https://github.com/polettix/cglib-perl/blob/master/Dijkstra.pm
[DijkstraFunction.pm]: https://github.com/polettix/cglib-perl/blob/master/DijkstraFunction.pm
[Perl]: https://www.perl.org/
[CodinGame]: https://www.codingame.com/
[Dijkstra's algorithm]: https://en.wikipedia.org/wiki/Dijkstra's_algorithm
[cglib-perl]: https://github.com/polettix/cglib-perl
[FloydWarshall.pm]: https://github.com/polettix/cglib-perl/blob/master/FloydWarshall.pm
