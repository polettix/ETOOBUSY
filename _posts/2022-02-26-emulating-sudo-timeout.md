---
title: Emulating sudo timeouts
type: post
tags: [ sudo, security ]
comment: true
date: 2022-02-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A way to emulate [sudo][]'s way of handling a timeout of the elevation
> of privileges.

I have a small command that allows querying several sources at the same
time, each with their respective credentials. As you can imagine, having
to insert the password/passphrase to each every time the command is
invoked would be *unfeasible*.

One first step would be to have *one password to rule them all*: encrypt
the credentials in a JSON file/string using one single password, then
ask only *that* password upon invocation, so that the encrypted file can
be turned back into cleartext JSON and, of course, a useable data
structure.

This still means that I would need to insert the password for each
invocation of the command, which would be a drag. So I thought that an
approach like [sudo][], that is caching the elevation capabilities for
some time (15 minutes by default, according to the [sudo manual][sudo])
would make things much easier.

This does **not** mean caching the password, of course, but only the
decryption capabilities. This is where [gpg-agent][] (remember [Some
notes on gpg-agent][]?) comes into play, because the `default-cache-ttl`
and `max-cache-ttl` can be used to obtain similar results.

So the prototype setup would be the following:

- save the sensitive credentials encrypted with key for user `foobar`,
  with a password;
- when the credentials are needed, decrypt the file. If this requires
  entering a password, [gnupg][] will use the relevant *pinentry*
  program to ask for it and insert into [gpg-agent][].
- every following usage within the` default-cache-ttl` and
  `max-cache-ttl` will simulate the caching mechanism of [sudo][] and
  provide a similar mechanism.

Does it make sense?

[sudo]: http://manpages.ubuntu.com/manpages/jammy/en/man8/sudo.8.html
[Some notes on gpg-agent]: {{ '/2022/02/25/gpg-agent-notes/' | prepend: site.baseurl }}
[gnupg]: https://www.gnupg.org/
[gpg-agent]: https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
