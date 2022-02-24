---
title: Some notes on gpg-agent
type: post
tags: [ gpg, gpg-agent ]
comment: true
date: 2022-02-25 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [gpg-agent][] is great but might use some enhancement.

I recently stumbled upon a situation that was more or less like this:

- I have multiple private keys in a [gnupg][] keyring.
- Files encrypted with key `foo` are more *sensitive*.
- Files encrypted with key `bar` are less *sensitive*.

My goal was to set different expiration times for keys managed by
[gpg-agent][], so that unlocking key `bar` would last longer.

Except that... this is not possible. There is no (easy) API to have
different expiration times, because [gpg-agent][] only handles two
values:

- the `default-cache-ttl` sets the expiration timer *unless the key is
  used again*;
- the `max-cache-ttl` sets an absolute expiration time, even if you use
  the key "continuously" (i.e. without ever letting it expire due to the
  `default-cache-ttl`).

That's it, this is what we get for *all* keys in the keyring. I was
hoping for some command to raise the value, some key-specific section in
the configuration file... but nothing.

One ugly hack to have a different behaviour for the two keys might be
having something that regularly uses key `bar`, so that it does not
expire due to `default-cache-ttl` but only for `max-cache-ttl`. But...
it's ugly and brittle.

The other thing that is possible to do is to have two different
directories, each with its own set of files and pointed to with two
different values for environment variable `GNUPGHOME`. This *might* mean
that there are two distinct keyrings, unless we do some linking magic to
share the same keyring files across the two different directories
(apart, of course, for [gpg-agent][] specific files, which we want to
keep separated).

So this works:

```
$ export GPGHOME

# this is where the most sensitive key/keyring is kept
$ GNUPGHOME="~/.foo"

# the configuration file sets both timeouts to 6 seconds
$ cat "$GNUPGHOME/gpg-agent.conf"
default-cache-ttl 6
max-cache-ttl 6
pinentry-program /usr/local/bin/pinentry-mac


# this is where the least sensitive key/keyring is kept
$ GNUPGHOME="~/.bar"

# here it's OK to leave stuff in the session for 10 hours
$ cat "$GNUPGHOME/gpg-agent.conf"
default-cache-ttl 36000
max-cache-ttl     36000
pinentry-program /usr/local/bin/pinentry-mac
```

So well, it's definitely doable although... not necessarily something
that I like!


[gpg-agent]: https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
[gnupg]: https://www.gnupg.org/
