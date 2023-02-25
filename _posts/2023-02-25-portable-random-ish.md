---
title: Portable(ish) Random(ish) Number Generator
type: post
tags: [ perl, rakulang, random ]
comment: true
date: 2023-02-26 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Sometimes we just need some mixing up of stuff.

For a little diversion that I'm taking, I wanted a random number
generator that could be easily ported to other languages too, so that I
could get a consistent behaviour.

So it was natural for me to remember that the glorious [Numerical
Recipes in C][nrc] had something about it (in Chapter 7), something
actually suggested by Knuth himself for a 32-bit *Pseudo-Random Number
Generator* (PNRG) using a recurrent function, with some help from H.W.
Lewis (section *Quick and Dirty Generators*):

$$R_{i+1} = R_i \cdot 1664525 + 1013904223 \pmod{2^{32}}$$

This is nothing that should be used for anything related to security or
betting, but it's good and simple enough for situation with much lower
expectations.

Implementing it in [Perl][] is pretty straightforward, as an iterator:

```perl
sub randomish_uint32_it ($seed = undef) {
   $seed = seed_to_num($seed) & 0xFFFFFFFF;
   return sub { $seed = ($seed * 1664525 + 1013904223) & 0xFFFFFFFF };
}
```

The function is a factory for generating an iterator, i.e. another
function that will give us the next pseudo-random integer at every call.
This factory expects to receive something as *seed*, so that using the
same seed allows re-generating the same sequence (either in some later
time, or in some other language). This is what I came up with for
turning a string into a seed value useable in the function above:

```perl
sub seed_to_num ($seed = undef) {
   return time() unless defined $seed;
   return $seed if $seed =~ m{\A (?: 0 | [1-9]\d*) \z}mxs;
   my $val = 0;
   $val = ($val << 8) | ord(substr($seed, $_)) for 0 .. length($seed) - 1;
   return $val;
}
```

Actually, it accepts something resembling a non-negative integer and
returns it unchanged; turns strings into integers; returns the current
epoch if the input is undefined.

For *reasons* I also needed to get a random bit; the suggestion in the
text is to use a different integer for each bit, and trust the higher
bits more than the lower ones, so here's my approach with a wrapper
iterator:

```perl
sub get_bit ($it, $max = 0xFFFFFFFF) { sub { 2 * $it->() > $max ? 1 : 0 } }
```

Now, this is *technically* less portable than the other (which is also
*more or less* portable by itself). In particular, the multiplication by
2 might overflow on architecture that do not support 64-bit integers.
Hence, in the specific case of the underlying generation, this is
probably better:

```perl
sub get_bit ($it) { sub { $it->() & 0x80000000 ? 1 : 0 } }
```

i.e. it checks the higest bit and returns accordingly.

The corresponding implementation in [Raku][] would be:

```raku
class Randomish {
   has $!s;

   submethod TWEAK (:$seed = Nil) {
      if (! defined($seed)) { $!s = DateTime.now.posix }
      elsif ($seed ~~ m{^^ [ 0 | <[ 1..9 ]>\d* ] $$}) { $!s = $seed }
      else { $!s = $seed.comb».ord.reduce({($^a +< 8) +| $^b}) }
      $!s +&= 0xFFFFFFFF;
   }

   method uint32() { $!s = ($!s * 1664525 + 1013904223 ) +& 0xFFFFFFFF }
   method bit() { self.uint32() +& 0x80000000 ?? 1 !! 0 }
}
```

Stay safe and stay random!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[nrc]: http://numerical.recipes/C210
