---
title: Cryptopals Diversion 1 - A counter
type: post
tags: [ security, cryptography ]
series: Cryptopals
comment: true
date: 2022-08-27 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little detour that will help with [Challenge 18][] in
> [Cryptopals][].

[Cryptopals challenge 18][Challenge 18] is about implementing *counter
mode*, so we will obviously need a counter. In our case, a 64 bits
counter.

I've always been aware to have lived - and still live - in a
technological bubble where things seem to be fixed and forever -
endianness, number of available bits for integers, etc. - but they
actually aren't. So I waste my time implementing solutions to
sub-problems that will not arise in real world - if anything, because
I'm *studying something else*.

Or am I? This diversion is a nice venture into the *how would I approach
building a 64 bits counter if I only had 32 bits arithmetics?* - so here
we go.

The approach is to keep it simple and safe, at the expense of
efficiency. I hope only efficiency, anyway. So we have 32 bits
arithmetics *or more*, and use it limited to 16 bits arithmetics: we
will never overflow, right?

```perl
sub counter_64bits ($init = '') { # 4x 16-bits integers, little-endian
   my @counter = (0) x 4;
   @counter = unpack 'v4', substr(("\x00\x00" x 4) . $init, -8, 8);
   return sub {
      my $retval = pack 'v4', @counter;
      my $i = 0;
      while ($i < 4) {
         last if ++$counter[$i] <= 0xFFFF;
         $counter[$i++] = 0;
      }
      return $retval;
   };
}
```

Variable `@counter` keeps four integers that we will cap at 16 bits;
whenever we go beyond, the counter is reset and the next integer is
incremented. The last carry, if any, will be just lost - so our counter
will happily pass from `0xFFFFFFFFFFFFFFFF` to `0x0`.

We're forcing *little-endianness* as per instructions in the text. This
means that we use `v4` to aggregate the four integers as four
little-endian 16-bits friends. Or disaggregate them, if we insist on
passing an initialization value.

The counter is used as an *iterator function*. You first get your
iterator, that is a sub reference:

```perl
my $counter_iterator = counter_64bits();
```

and then run the function whenever a new 64-bits encoded counter is
needed:

```perl
my $nonce = "\x00" x 8;
while ('necessary') {
    my $counter = $counter_iterator->();
    my $xor_bits = aes_block_encryption($key, $nonce . $counter);
    ...
}
```

Stay safe *and secure*!

[Perl]: https://www.perl.org/
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[Challenge 18]: https://cryptopals.com/sets/3/challenges/18
