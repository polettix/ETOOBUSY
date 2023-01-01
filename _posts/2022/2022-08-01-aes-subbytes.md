---
title: AES - SubBytes
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The `SubBytes` function of [AES][], in [Perl][].

When I was at the University, I remember being explained about the
*top-down* and the *bottom-up* approaches. The gist being: you should
use the first but you'll end up using the latter.

So I *know* that I should start with `Cipher` in Figure 5 of [AES][],
but I also know that after one post introducing a series about [AES][],
doing another high-level post would be too dull.

So... `SubBytes` or, as we're doing [Perl][] here, `sub_bytes`:

```perl
sub sub_bytes ($state) {
   state $v = <<'END';
      637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0
      b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b275
      09832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cf
      d0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2
      cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdb
      e0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08
      ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9e
      e1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16
END
   state $value_for = [split m{}mxs, pack 'H*', $v =~ s{\s+}{}grmxs];
   $state->@* = map { $value_for->[ord $_] } $state->@*;
   return $state;
} ## end sub sub_bytes ($state)
```

The fun thing about this function in the standard is that it's
thoroughly explained in its inner workings etc... but from an
implementation point of view you can just look at Figure 7 and implement
that octet-to-octet mapping over all bytes in the block.

The `state` variable `$v` is that mapping, a little packed down; it's
turned into `$value_for`, which is an array of octets, indexed by the
[ord][] of the input octet.

So, at the end of the day, the function is just a simple transformation
applied to each octet, nothing more, by applying `$value_for` over all
input octets.

There is *a bit more* to it, anyway. It's implicitly assumed that we
receive our block as a linear array `$state`, where each item is a
single octect of the block. It's also clear that `sub_bytes` will
transform `$state` *in-place*, which is anyway similar to how the
standard *uses* the `SubBytes` function in `Cipher`. So there we have
our data model.

[AES][] is a symmetric algorithm, so it makes sense to look at the
inverse operation `inv_sub_bytes`. The logic is exactly the same as the
direct function, only leveraging a different mapping (i.e. the inverse
one):

```perl
sub inv_sub_bytes ($state) {
   state $v = <<'END';
      52096ad53036a538bf40a39e81f3d7fb7ce339829b2fff87348e4344c4dee9cb
      547b9432a6c2233dee4c950b42fac34e082ea16628d924b2765ba2496d8bd125
      72f8f66486689816d4a45ccc5d65b6926c704850fdedb9da5e154657a78d9d84
      90d8ab008cbcd30af7e45805b8b34506d02c1e8fca3f0f02c1afbd0301138a6b
      3a9111414f67dcea97f2cfcef0b4e67396ac7422e7ad3585e2f937e81c75df6e
      47f11a711d29c5896fb7620eaa18be1bfc563e4bc6d279209adbc0fe78cd5af4
      1fdda8338807c731b11210592780ec5f60517fa919b54a0d2de57a9f93c99cef
      a0e03b4dae2af5b0c8ebbb3c83539961172b047eba77d626e169146355210c7d
END
   state $value_for = [split m{}mxs, pack 'H*', $v =~ s{\s+}{}grmxs];
   $state->@* = map { $value_for->[ord $_] } $state->@*;
   return $state;
} ## end sub inv_sub_bytes ($state)
```

Our first brick is in place, stay safe for more!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[ord]: https://perldoc.perl.org/functions/ord
