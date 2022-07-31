---
title: AES is doable
type: post
tags: [ aes, security, perl ]
series: A toy AES implementation
comment: true
date: 2022-07-31 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Coding [AES][] is doable.

As it's probably clear by now, I'm going through the [Cryptopals][]
challenges and [Challenge 7][] introduces us to [AES][]. It suggests to

> use OpenSSL::Cipher and give it AES-128-ECB as the cipher.

Fact is that `OpenSSL::Cipher` does *not* exist in [Perl][]. I can only
guess that its closest *cousin* might be [SSLeay][], which is not
exactly *user friendly*. If you want to go with a module in [Perl][],
I'd suggest to go for [CryptX][] and in particular look for
[Crypt::Mode::ECB][].

Anyway, one of the good things about [Cryptopals][] is to look below the
blanket and see how things work. So... why not?

The [FIPS PUB 197][AES] standard introduces (or, better, *announces*)
the Advanced Encryption Standard. The standard itself is... *readable*,
in the sense that it is relatively easy to read and the functions are
relatively easy to code. So... why not?

This means that, after [A toy RSA implementation][], let's venture into
implementing [A toy AES implementation][] (in [Perl][]) for fun and
*profit*. Well, in the sense that we will be profiting from the
experience and possibly reuse the code in one or two [Cryptopals][]
challenges.

We're only aiming for *correctness* here. The code will be *at most*
useful for better understanding of the operations and possibly for doing
some of the challenges in [Cryptopals][], but it's going to stab you in
the back if you use it beyond this point. A toy is still a toy.

> This is no joke. Using this toy for encryption or decryption might
> expose your keys in ways I can't even think of, from using memory that
> might be swapped onto disk to providing an easy way for timing or
> other side-channel attacks.

Consider yourself warned, and stay tuned!

[Perl]: https://www.perl.org/
[AES]: https://csrc.nist.gov/csrc/media/publications/fips/197/final/documents/fips-197.pdf
[A toy RSA implementation]: {{ '/2021/07/20/a-toy-rsa-implementation/' | prepend: site.baseurl }}
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[A toy AES implementation]: {{ '/series/#a-toy-aes-implementation' | prepend: site.baseurl }}
[SSLeay]: https://metacpan.org/pod/SSLeay
[CryptX]: https://metacpan.org/pod/CryptX
[Crypt::Mode::ECB]: https://metacpan.org/pod/Crypt::Mode::ECB
[Challenge 7]: https://cryptopals.com/sets/1/challenges/7
