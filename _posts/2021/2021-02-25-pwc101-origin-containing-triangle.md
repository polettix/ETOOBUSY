---
title: PWC101 - Origin-containing Triangle
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-02-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#101][].
> Enjoy!

# The challenge

> You are given three points in the plane, as a list of six
> co-ordinates: `A=(x1,y1)', `B=(x2,y2)` and `C=(x3,y3)`. Write a script
> to find out if the triangle formed by the given three co-ordinates
> contain origin (0,0). Print 1 if found otherwise 

# The questions

A few questions...

- is a point on the edge (or even a vertex) considered to be *inside*?
    - the examples seems to imply that it is
- should we favour an integers-based solution?
    - if not, what should our tolerance be?
- is *inside* a synonym for *in the part of the plane delimited by the
  three segments and with a finite area*?
    - well, assume yes.

# The solution

I was thinking about a solution involving the vectors from the origin to
the three points and how they revolve around the origin itself, then I
thought that reinventing the wheel so late is moot and there's surely
some computational geometry article somewhere out there, just to
surrender to the power of [CPAN][].

So... [Math::Polygon][].

First of all, it does indeed allow to solve the problem quite easily:

```perl
sub origin_containing_triangle ($A, $B, $C) {
   Math::Polygon->new($A, $B, $C, $A)->contains([0, 0]) ? 1 : 0;
}
```

Then, it's by [Mark Overmeer][], which I consider a warranty in terms of
correctness and accuracy.

So... by all means I'll stick to this solution!

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Math::Polygon;

sub origin_containing_triangle ($A, $B, $C) {
   Math::Polygon->new($A, $B, $C, $A)->contains([0, 0]) ? 1 : 0;
}

my @pts;
push @pts, [splice @ARGV, 0, 2] while @ARGV;
say origin_containing_triangle(@pts[0..2]);
```

Stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#101]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-101/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-101/#TASK2
[Perl]: https://www.perl.org/
[CPAN]: https://metacpan.org/
[Math::Polygon]: https://metacpan.org/pod/Math::Polygon
[Mark Overmeer]: https://metacpan.org/author/MARKOV
