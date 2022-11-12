---
title: PWC145 - Dot Product
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-29 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#145][]. Enjoy!

# The challenge


> You are given 2 arrays of same size, `@a` and `@b`.
>
> Write a script to implement `Dot Product`.
>
> **Example:**
>
>     @a = (1, 2, 3);
>     @b = (4, 5, 6);
>
>     $dot_product = (1 * 4) + (2 * 5) + (3 * 6) => 4 + 10 + 18 => 32

# The questions

My assumption here is that we are talking about the [Dot Product][]:

> In mathematics, the dot product or scalar product is an algebraic
> operation that takes two equal-length sequences of numbers (usually
> coordinate vectors), and returns a single number. [...] The name "dot
> product" is derived from the centered dot `·`, that is often used to
> designate this operation [...]

Which implies:

- the two input vectors are from the same vector space or, at least, the
  two sequences of numbers take elements from the same field;
- the product itself can be defined as follows:

$$
\mathbf{v} \cdot \mathbf{w} = \sum_{i = 0}^{d-1} v_i w_i
$$

# The solution

[Raku][] first, which allows for a very compact solution. We define a
`class` for storing vectors, and overload/define an operator `·` to
implement the [Dot Product][]:

```raku
#!/usr/bin/env raku
use v6;

class Vector { has @.v; method new (*@x) { self.bless(v => @x) } }
sub infix:<·> (Vector:D $x, Vector:D $y) { ($x.v »*« $y.v).sum }

sub MAIN {
   my $a = Vector.new(1, 2, 3);
   my $b = Vector.new(4, 5, 6);
   put $a · $b;
}
```

We're using the `»*«` version here to insist that the two sequences of
numbers at both ends have the same number of elements. In case they
don't... it will complain loudly.

The translation into [Perl][] is more... *lower level*, but still we can
overload something to represent the operation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $v = Vector->new(1, 2, 3);
my $w = Vector->new(4, 5, 6);
say $v . $w;

package Vector;
use v5.24;
use experimental 'signatures';
no warnings 'experimental::signatures';
use overload
   '.' => sub ($v, $w, @rest) {
      die "size mismatch\n" unless $v->$#* == $w->$#*;
      my $dp = 0;
      $dp += $v->[$_] * $w->[$_] for 0 .. $v->$#*;
      return $dp;
   };

sub new ($package, @a) { bless \@a, $package }
```

In this case we have to explicitly check for matching sizes of the
underlying arrays and possibly `die` if they are not the same.

Stay safe and mathy, people!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#145]: https://theweeklychallenge.org/blog/perl-weekly-challenge-145/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-145/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Dot Product]: https://en.wikipedia.org/wiki/Dot_product
