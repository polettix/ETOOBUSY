---
title: 'AES - multiplications in GF(256)'
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-05 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> The `MixColumns` transformation of [AES][] leverages operations in
> $GF(2^8)$, let's see it in [Perl][].

Before delving into `MixColumns`, we have to realize that it requires
operating over field $GF(2^8)$.

In the spirit of *doing most by myself*, I was very happy to have coded
[Math::GF][] in the past. Yay yay yay!

*On the other hand...* [Math::GF][] has two drawbacks as-is:

- a high setup time for $GF(2^8)$, which of course affects any program
  using it *directly*
- it figures out the needed irreducible polynomial by itself, while
  [AES][] tells us which one we should use.

The second issue is easy to address with some fiddling with the module's
code, so no big deal. The first one, though...

The main culprit is the calculation of the multiplication table, which
is theoretically a $256 \times 256$ matrix, which can be calculated more
compactly because it's symmetric (so there are only $\frac{257 \cdot
258}{2} = 33153$ items), but still there's a lot of items to calculate.

The solution I thought is to pre-calculate it once, save it and reload
it when needed. Each item is a octet representing a single
multiplication, so it's $33153$ bytes to store. Not too many.

This is how it can be coded, then:

```perl
sub GF_2_8_mult ($x, $y) {
   state $table = GF_2_8_table();
   my ($h, $l) = (ord($x), ord($y));
   ($h, $l) = ($l, $h) if $h < $l;
   return substr $table, $l + $h * ($h + 1) / 2, 1;
} ## end sub GF_2_8_mult
```

The `GF_2_8_table` function loads the pre-calculated mapping as above.
I'll not put it here *extensively*, you can [take it here][]. Anyway,
it's just a bunch of data.

The data are arranged in lower triangular form. This means that the
first row (0) contains one single element, representing the square of
the first element of the field (unsurprisingly mapped onto... 0), the
second row contains two elements, the third row three etc.

All these items are taken from the matrix and arranged one after the
other in a linear array (I know, I love linear arrays). So, if we want
to get the multiplication of the $X$th element by the $Y$th one,
assuming that $X \ge Y$, we have to look for the following element in the
linear array:

$$
\frac{X \cdot (X + 1)}{2} + Y
$$

The first part places us at the beginning of the $X$th row, then $Y$ is
the offset inside the row.

In the code, $X$ is `$h` and $Y$ is `$l`, stressing the requirement that
the former must be higher than, or equal to, the latter. This is also
explicitly checked and enforced by swapping them, if necessary.

So, we're now ready for `MixColumns` at last, in a *not-so-inefficient*
way.

Stay safe!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[Math::GF]: https://metacpan.org/pod/Math::GF
[take it here]: []: {{ '/assets/code/GF-2-8-table.pl' | prepend: site.baseurl }}
