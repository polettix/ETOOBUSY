---
title: PWC170 - Kronecker Product
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#170][].
> Enjoy!

# The challenge

> You are given 2 matrices.
>
> Write a script to implement `Kronecker Product` on the given 2
> matrices.
>
> For more information, please refer [wikipedia page][].
>
> For example,
>
>     A = [ 1 2 ]
>         [ 3 4 ]
>     
>     B = [ 5 6 ]
>         [ 7 8 ]
>     
>     A x B = [ 1 x [ 5 6 ]   2 x [ 5 6 ] ]
>             [     [ 7 8 ]       [ 7 8 ] ]
>             [ 3 x [ 5 6 ]   4 x [ 5 6 ] ]
>             [     [ 7 8 ]       [ 7 8 ] ]
>     
>           = [ 1x5 1x6 2x5 2x6 ]
>             [ 1x7 1x8 2x7 2x8 ]
>             [ 3x5 3x6 4x5 4x6 ]
>             [ 3x7 3x8 4x7 4x8 ]
>     
>           = [  5  6 10 12 ]
>             [  7  8 14 16 ]
>             [ 15 18 20 24 ]
>             [ 21 24 28 32 ]

# The questions

The challenge text requests us to *implement* the product, so I wonder
if using modules is OK in this case. I'll assume that it means in the
sense of "implement something that can calculate the product".

On a similar note, I'd ask if the output format is strict or can be
varied a bit... depending on what's easy to accomplish. Again, I'll
assume that whatever goes, as long as it's readable.

# The solution

These are busy weeks and this usually increments my likelihood to go for
simple and lazy solutions. Hence, you can imagine that between learning
[PDL][] and using [Math::Matrix][]... I opted for the second:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use Math::Matrix;

my $A = Math::Matrix->new([1, 2], [3, 4]);
my $B = Math::Matrix->new([5, 6], [7, 8]);
my $K = $A->kron($B);
$K->print("K\n");
```

I'm not sure I *entirely* like the output format, but it's a gift and I
don't want to whine about it.

For the [Raku][] solution, I remembered about the famous [Wally
Wood][ww]:

> Never draw anything you can copy, never copy anything you can trace,
> never trace anything you can cut out and paste up.

This was definitely one of those occasions, as the solution is already
there in [Rosetta Code][rcraku]. So with very little cosmetics, here we
go:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   .say for kronecker-product([ <1 2>, <3 4> ],
                              [ <5 6>, <7 8> ]);
}

sub kronecker-product (@a, @b) {
   (@a X @b).map: { .[0].list X* .[1].list };
}
```

Well, I guess I at least owe an explanation. To me.

We start with `@a` and `@b` being arrays of tuples:

```
> my @a = <1 2>, <3 4>;
[(1 2) (3 4)]
> my @b = <5 6>, <7 8>;
[(5 6) (7, 8)]
```

The `X` operator creates pairs from the two operands, so it creates
pairs of rows from the two arrays:

```
> @a X @b
(((1 2) (5 6)) ((1 2) (7 8)) ((3 4) (5 6)) ((3 4) (7 8)))
```

These pairs are fed into the `map` as the implicit variable `$_`, which
we don't even have to mention. Thus, `.[0]` and `.[1]` are the two rows
coming respectively from `@a` and `@b`, and we multiply element by
element with `X*`. The `.list` part allows us tell [Raku][] to do the
right thing with these sequences.

The sub can be put in a slightly more readable way:

```raku
sub kronecker-product (@a, @b) {
   (@a X @b).map: -> (@A, @B) { @A X* @B };
}
```

Here we assign each pair from `map` to `(@A, @B)`, which then
get the respective row from `@a` and `@b` like before. Here we don't
even have to use the `.list`, which in my humble opinion makes the
solution *more readable* **and** *shorter*.

OK, I've not been *that* lazy after all... Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#170]: https://theweeklychallenge.org/blog/perl-weekly-challenge-170/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-170/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[ww]: https://en.wikipedia.org/wiki/Wally_Wood
[rcraku]: http://www.rosettacode.org/wiki/Kronecker_product#Raku
[wikipedia page]: https://en.wikipedia.org/wiki/Kronecker_product
[PDL]: https://metacpan.org/pod/PDL
[Math::Matrix]: https://metacpan.org/pod/Math::Matrix
