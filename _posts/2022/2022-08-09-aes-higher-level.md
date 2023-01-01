---
title: AES - Higher level functions
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-08-09 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Making our toy [AES][] implementation slightly useable.

Our implementation now has a useable way to encrypt and decrypt stuff
according to the [AES standard][AES], although it's not very
straightforward:

```
my $plain = shift // 'AES is a fun toy'; # 16 octets (block size)
my $key   = shift // 'YELLOW SUBMARINE'; # 16 octets => AES 128

my $cipher_schedule = key_expansion($key);
my $cipher = cipher($plain, $cipher_schedule);

my $decipher_schedule = modify_key_schedule_copy($cipher_schedule);
my $decrypted = eq_inv_cipher($cipher, $decipher_schedule);
```

> Let's remember that `cipher`/`eq_inv_cipher` operate on one single
> block of 16 octets, always and independently of the key length.

We can do better from a useability point of view, e.g.:

```perl
sub block_decrypt ($ct, $key) { block_decrypter($key)->($ct) }

sub block_decrypter ($key) {
   $key = modify_key_schedule_inplace(key_expansion($key));
   return sub ($ct) { return equivalent_inv_cipher($ct, $key) };
}

sub block_encrypt ($pt, $key) { block_encrypter($key)->($pt) }

sub block_encrypter ($key) {
   $key = key_expansion($key);
   return sub ($plaintext) { return cipher($plaintext, $key) };
}
```

The function names all start with `block_` to remind us that they're
useful for working on a single block of data, which means 16 octets in
[AES][]. Anything that has to work on more (or less!) data will have to
be dealt with separately (with some *mode of operation*, like ECB, CBC,
...).

The two `block_*crypter` functions take a key and give back a function
to apply the right [AES][] algorithm to a single block, like this:

```
my $encrypter = block_encrypter($key);
my $decrypter = block_decrypter($key);
die if $decrypter->($encrypter->($plain)) ne $plain;
```

They are useful if we have to perform multiple block
encryption/decryption with the same key. On the other hand, we also have
*one-off* block-level operations that take a block of plain/cipher data
and a key, and do the right thing:

```
die if block_decrypt(block_encrypt($plain, $key), $key) ne $plain;
```

So well, this is it for our little [AES][] toy implementation. If you
want to experiment with it, it's been encapsulated within a small
[Perl][] module `AesBasic`, which you can [download here][] (I don't see
any reason to publish it to [CPAN][]).

This also gives us the tool to continue our journey through
[Cryptopals][] challenges. Stay tuned and safe!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[CPAN]: https://metacpan.org/
[download here]: {{ '/assets/code/AesBasic.pm' | prepend: site.baseurl }}
