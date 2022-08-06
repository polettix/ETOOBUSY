---
title: AES - Cipher
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Putting together the pieces to encrypt stuff with [AES][], in [Perl][].

At this point, we have all the moving parts we need to assemble the
Cipher function, let's go!

```perl
sub cipher ($input, $key_schedule) {
   return _generic_cipher(
      $input,        $key_schedule, \&add_round_key,
      \&mix_columns, \&shift_rows,  \&sub_bytes
   );
} ## end sub cipher
```

Wait... *what*?!?

It turns out that the Cipher operation has an inverse to go from the
ciphertext back to the plaintext, which is called InvCipher. This is
built by doing all the operations in Cipher the other way around. So far
so good.

The [AES][] standard, on the other hand, introduces an *equivalent*
algorithm EqInvCipher whose shape is exactly the same as Cipher, only
with a few setup modifications.

From an implementation point of view, then, it can be convenient to
encapsulate the common behaviour into its own `_generic_cipher`, and use
it from the outside, feeding the right data/moving parts. So we also
have the inverse *almost* for free:

```perl
sub equivalent_inv_cipher ($input, $modified_key_schedule) {
   return _generic_cipher($input, $modified_key_schedule, \&add_round_key,
      \&inv_mix_columns, \&inv_shift_rows, \&inv_sub_bytes);
}
```

All functions assume that the *key schedule* will be fed in, so the
functions signature aim to remind us that `cipher` needs the regular
output of `key_expansion`, while `inv_cipher` needs something out of
`modify_key_schedule_*`.

So, again, how is this generic ciphering implemented? Here it is:

```perl
sub _generic_cipher ($input, $key_schedule, $ark, $mxc, $shr, $sby) {
   my $state = [split m{}mxs, $input];
   my ($first, @mids) = $key_schedule->@*;
   my $last = pop @mids;

   $ark->($state, $first);
   $ark->($mxc->($shr->($sby->($state))), $_) for @mids;
   $ark->($shr->($sby->($state)), $last);

   return join '', $state->@*;
} ## end sub _generic_cipher
```

Almost straight from page 15 of [AES][], with the comfort of [Perl][]:

- `$ark` is the AddRoundKey operation - it could have been fixed to
  `add_round_key` in the implementation, as it's the same as its inverse
  so it's fed by both `cipher` and `equivalent_inv_cipher`
- `$mxc` is the *right* version between MixColumns/InvMixColumns
- `$shr` is the *right* version between ShiftRows/InvShiftRows
- `$sby` is the *right* version between SubBytes/InvSubBytes

The key schedule contains the parts of the expanded key that can be used
in the different rounds, where the first and last ones have to be
treated specially. I admit that I initially wrote this:

```
my ($first, @mids, $last) = $key_schedule->@*; # WRONG WRONG WRONG!
```

but *of course* this will not work in [Perl][] because `@mids` sucks
everything after the first item, leaving `$last` with nothing (i.e.
`undef`).

This *technically* is everything we needed, although it's still a bit
low level. In the next post we'll take a look at an API that's slightly
higher level.

Stay safe!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[last post]: {{ '/2022/08/05/gf28-multiplications/' | prepend: site.baseurl }}
