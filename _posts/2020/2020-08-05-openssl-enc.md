---
title: Encrypting with OpenSSL enc
type: post
tags: [ openssl, security ]
comment: true
date: 2020-08-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I recently discovered that [OpenSSL][] has an `enc` sub-command.

So... if you have a shared password/secret, you can leverage it to do
some encryption and decription.

Let's assume that you set the password in the environment variable
`PASS`:

```shell
$ PASS="$(printf >&2 'enter password> '; read x; printf '%s' "$x")"
```

The `enc` sub-command, by default, does the encryption, like this:

```shell
$ cleartext='53cr3t5!'
$ printf '%s' "$cleartext" \
    | openssl enc -base64 -aes256 -pass pass:"$PASS"
U2FsdGVkX18jFNoH2NtxHrdN8pnGKUMuk8XTnW4QBgM=
```

To decrypt, use the same command but add option `-d`:

```shell
$ cyphertext='U2FsdGVkX18jFNoH2NtxHrdN8pnGKUMuk8XTnW4QBgM='
$ printf '%s\n' "$cyphertext" \
    | openssl enc -d -base64 -aes256 -pass pass:"$PASS"
53cr3t5
```

It works!

One thing to note: the `printf` for feeding the `$cyphertext` to the
decrypting process MUST end with a newline!


[OpenSSL]: https://www.openssl.org/
