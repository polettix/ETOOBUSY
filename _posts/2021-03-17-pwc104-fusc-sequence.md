---
title: PWC104 - FUSC Sequence
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#104][]. Enjoy!

# The challenge


> Write a script to generate first 50 members of `FUSC Sequence`. Please
> refer to [OEIS][oeis-fusc] for more information.
>
> The sequence defined as below:
>
>     fusc(0) = 0
>     fusc(1) = 1
>     for n > 1:
>     when n is even: fusc(n) = fusc(n / 2),
>     when n is odd: fusc(n) = fusc((n-1)/2) + fusc((n+1)/2)

# The questions

My main questions here are regarding the inputs and the outputs, so they're
quite boring:

- is the input bound to be a non-negative integer?
- what is the expected output? Something to be printed or just an array?

# The solution

We'll take a look at two solutions, just for fun. Wheeee!

The first one is quite adherent to the definition above: calculate each new
item based on the recursive formula. This does not need to be implemented
*recursively* though, a simple iteration will do:

```perl
sub fusc ($n) {
   return [0 .. $n - 1] if $n <= 2;
   my @fusc = (0, 1); # fusc(0), fusc(1)
   while (@fusc < $n) {
      push @fusc, $fusc[@fusc >> 1];
      last if @fusc >= $n;
      push @fusc, $fusc[-1] + $fusc[1 + @fusc >> 1];
   }
   return \@fusc;
}
```

There's a bit to unpack here, because it's admittedly *not* in the best
interest of the reader (I just felt like this):

- there's no explicit index variable for tracking the item we have to add.
  Adding an item in a [Perl][] array can be done with `push` (so we don't
  need it) and its length can be taken by evaluating it in *scalar* context.
  *Who needs those stinking, readable variables then*?!?
- Dividing by 2 in an integer way is the same as a bit shift left of one
  position, which accounts for `@fusc >> 1`. This expression also provides
  the *scalar* context we need to get the number of elements in `@fusc`,
  yay!
- There are two ways to exit from the loop, one for even input `$n` and
  another one for odd values. Try to figure out which is which.
- For odd positions, the value in position $(n - 1) / 2$ is (by definition!)
  the same as the value in position $(n - 1)$, which in [Perl][] terms
  translates into `$fusc[-1]`

As a twist, I thought... why not go the other way around? I mean, all (well,
most) elements in the sequence *directly affect* three other elements. In
other terms, for *$k$ sufficiently large*, the $k$-th element affects
elements at positions $(2 k - 1)$, $2k$, and $(2k + 1)$.

There is an important caveat here, because this does not apply for *low*
values of $k$. Actually, `fusc(1)` does indeed affect `fusc(2)` and
`fusc(3)`... but it *MUST NOT* not affect `fusc(1)` 🙄

All of this allows us to build a *constructive* solution from the ground up:

```perl
sub fusc_sieve ($n) {
   my @fusc = (0, 1);
   for my $i (1 .. $n >> 1) {
      $fusc[$i * 2]      = $fusc[$i];
      $fusc[$i * 2 + 1] += $fusc[$i];
      $fusc[$i * 2 - 1] += $fusc[$i];
   }
   $fusc[1] = 1;
   return [@fusc[0 .. $n - 1]];
}
```

Again, we're using `$n >> 1` instead of `int($n / 2)` just to be a bit snob
and stimulate that *WTF?!?* feeling in the reader.

The `1`-exception is taken care of in two places here:

- the most obvious one is when we (re)set the value of `fusc(1)` explicitly
  just after the loop;
- the hidden one lies in the order used to updated the three affected
  values. Note that the value `$fusc[$i * 2 - 1]` is updated last... this
  allows us to defer the vicious self-updating of the element `1` last, so
  that this glitch does not affect any other element down the line.

Our last attention point is on the returned value: this method tends to
generate elements a bit generously, so we trim the output a bit when we
`return` it.

All in all, taking this route was a fun sub-challenge, although a perilous
one. Which is a lesson in itself: simpler solutions are often better for a
reason.

Stay safe everyone!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#104]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-104/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-104/#TASK1
[Perl]: https://www.perl.org/
[oeis-fusc]: http://oeis.org/A002487
