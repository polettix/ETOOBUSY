---
title: AES - ShiftRows
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The `ShiftRows` function of [AES][], in [Perl][].

Reading the text, `ShiftRows` is not difficult to code, especially in a
language like [Perl][] that provides us a wide toolset of manipulation
of arrays.

But, of course, I got it wrong the first time 🙄

What I did not read *at all* is that the 4x4 arrangement of the input
block is *by columns*, **not** by rows. If you want to go down the same
path, **make sure you read section 3.4 of [the standard][AES]** where
this is explained clearly and with a picture too!

Apart from this bump, adapting the algorithm to work with *my*
representation of the state as a linear array was easy. I mean, it's
about moving stuff around, so it can be expressed in terms of properly
re-indexing the original state array using the slice array operations:

```perl
sub shift_rows ($state) {
   state $sources =
      [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11];
   $state->@* = $state->@[$sources->@*];
   return $state;
}
```

As the indexes are fixed, it makes sense to store them permanently in a
`state` variable. Or is it, really?!? I suspect this is one of those
gut-feeling-optimizations that aren't. Anyway, it's there now and I'll
keep it.

The inverse operation for decryption is the following:

```perl
sub inv_shift_rows ($state) {
   state $sources =
      [0, 13, 10, 7, 4, 1, 14, 11, 8, 5, 2, 15, 12, 9, 6, 3];
   $state->@* = $state->@[$sources->@*];
   return $state;
}
```

It's easy to see that these two operations are inverse to one another.
As an example, item 1 is put in the 13th slot by `shift_rows`, whereas
it is taken from slot 13 in `inv_shift_rows`. The first row is not
rotated in either function, so items `0`, `4`, `8`, and `12` remain
fixed.

And now we got our second brick well firm on the bottom. Stay safe and
tuned!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[ord]: https://perldoc.perl.org/functions/ord
