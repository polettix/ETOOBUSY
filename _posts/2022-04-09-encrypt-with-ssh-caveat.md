---
title: 'Encrypt, the hard way - a caveat'
type: post
tags: [ security, OpenSSL, OpenSSH ]
comment: true
date: 2022-04-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> One thing to look out for when using [Encrypt, the hard way][].

In post [Encrypt, the hard way][] we saw that it's possible to use
[OpenSSH][] RSA keys from [OpenSSL][] to implement a working encryption
and decryption chain. Might be fun.

It's anyway possible to hit the following error while decrypting via the
asymmetric algorithm:

```
# Get the symmetric encryption key back first, using the private
# SSH RSA key
$ openssl rsautl -decrypt -oaep -inkey ~/.ssh/id_rsa \
    -in random-key-stuff.enc -out random-key-stuff.dec

... yadda yadda yadda...:Expecting: ANY PRIVATE KEY
```

Well, `~/.ssh/id_rsa` **is** a RSA PRIVATE KEY:

```
-----BEGIN OPENSSH PRIVATE KEY-----
...
```

What gives?

It turns out that the format with which the key was saved is not useable
by [OpenSSL][] (well, my version of [OpenSSL][] at least) and I have to
save it in a slightly different format to make it acceptable.

So thanks to [this answer][]:

```
# let's work in the SSH directory for my user
$ cd ~/.ssh

# let's also remain on the safe side, just in case...
$ cp id_rsa id_rsa.save

# we're passphrase-protecting our keys, right? RIGHT?!?
$ ssh-keygen -p -f id_rsa -m PEM
```

At this point we're asked for the old passphrase (to decrypt the current
contents of `id_rsa` into a useable private key) and a new passphrase
twice, to re-encrypt the private key with it. We end up with a file that
*starts differently*:

```
$ head id_rsa
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-...
...
```

Now *this* key can make my [OpenSSL][] happy and willing to work
properly... thanks!

Stay safe everyone!


[Encrypt, the hard way]: {{ '/2022/04/08/encrypt-the-hard-way/' | prepend: site.baseurl }}
[GnuPG]: https://gnupg.org/
[OpenSSH]: https://www.openssh.com/
[OpenSSL]: https://www.openssl.org/
[post]: https://www.bjornjohansen.com/encrypt-file-using-ssh-key
[bj]: https://www.bjornjohansen.com/about-me
[MacGyver]: https://it.wikipedia.org/wiki/MacGyver
[this answer]: https://stackoverflow.com/a/69945758/334931
