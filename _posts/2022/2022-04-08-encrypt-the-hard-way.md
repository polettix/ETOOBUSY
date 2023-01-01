---
title: 'Encrypt, the hard way'
type: post
tags: [ security, OpenSSL, OpenSSH, openpgp ]
comment: true
date: 2022-04-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some notes to do encryption **the hard way**.

When I need to encrypt a file, I usually reach for my [GnuPG][] client
and just use it. It's simple and straightforward.

Some time ago I discovered that you can do the same with [OpenSSL][],
using [OpenSSH][] keys. This was at the same time a *well, makes sense*
and a *mindblowing* experience.

It makes sense because [OpenSSL][] has a lot of code and utilities to
deal with encryption and symmetric and asymmetric stuff, so no big deal.
Additionally, [OpenSSH][] keys are... *keys*, so why not use them as
such?

On the other hand it was mindblowing, because there is this amazing
astral connection where pieces from separate projects can concur to
create an amazing [MacGyver][]-ish encryption solution, in lack of a
[GnuPG][] installation.

It is explained in this blog post: [Encrypt and decrypt a file using SSH
keys][post] by [Bjørn Johansen][bj]. In a nutshell:

```
# Encryption: asymmetric encryption works fine for small payloads, so
# we encrypt our real payload with a key derived from some random data
# using a symmetric algorithm, then encrypt the random data with the
# asymmetric algorithm. This is how it happens in the real world,
# usually

# Let's start from a payload we want to protect
$ printf >original-plaintext.txt 'Hello, secret world!\n'

# Generate 32 bytes of random data to use for key derivation
$ openssl rand -out random-key-stuff.bin 32

# Use the random data to encrypt the payload
$ openssl aes-256-cbc -pass file:random-key-stuff.bin \
    -in original-playtext.txt -out cyphertext.bin

# Now the 32-bytes random data file is our weak link, let's encrypt
# it too, with asymmetric encryption
$ openssl rsautl -encrypt -oaep -pubin \
    -inkey <(ssh-keygen -e -f ~/.ssh/id_rsa.pub -m PKCS8) \
    -in random-key-stuff.bin -out random-key-stuff.enc
```

At this point, we're left with two *interesting* files:

- `cyphertext.bin`, our payload encrypted with a symmetric algorithm,
  and
- `random-key-stuff.enc`, the key to decrypt the `cyphertext.bin` file,
  but protected with asymmetric encryption based on our RSA SSH key.

These two files can be transmitted *safely*, if your threat model makes
you trust these algorithms! On the receiving side:

```
# Decryption: let's just go in reverse

# Get the symmetric encryption key back first, using the private
# SSH RSA key
$ openssl rsautl -decrypt -oaep -inkey ~/.ssh/id_rsa \
    -in random-key-stuff.enc -out random-key-stuff.dec

# Now we can use it to decrypt the cyphertext
$ openssl aes-256-cbc -d -pass file:randon-key-stuff.dec \
    -in cyphertext.bin -out reconstructed-plaintext.txt

# We should be there...
$ cat reconstructed-plaintext.txt
Hello, secret world!
```

So *it can work!*.

We'll talk about one big *BUT*... in a future post, for this moment
let's rejoy and... stay safe!


[GnuPG]: https://gnupg.org/
[OpenSSH]: https://www.openssh.com/
[OpenSSL]: https://www.openssl.org/
[post]: https://www.bjornjohansen.com/encrypt-file-using-ssh-key
[bj]: https://www.bjornjohansen.com/about-me
[MacGyver]: https://it.wikipedia.org/wiki/MacGyver
