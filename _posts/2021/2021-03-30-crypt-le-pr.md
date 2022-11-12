---
title: 'A pull request for Crypt::LE'
type: post
tags: [ perl, tls, acme2, letsencrypt ]
comment: true
date: 2021-03-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I sent a [Pull Request for Crypt::LE][pull request].

In previous post [Crypt::LE update][] I made a quick note about a few
*hiccups* that I had during the upgrade.

One of them has to do with the `le.pl` script that is shipped with the
distribution, with particular reference to the exit code that this program
provides when it's *too early* to renew the certificate.

Previously (well, at least as of version `0.17`...) this was not a real
error condition and made the program print a message but otherwise exit with
code `0`. This was useful for me because I run the script daily through a
cron job and it's expected that most of the times it will hit this type of
condition; having `0` simply meant that I could flag anything different with
a notification (via email).

The latest version (`0.37` as of... today) *sort of* preserves the same
behaviour. The script has been extended with the possibility to provide a
configuration file with custom error codes, and if this file is provided the
exit code for the *too early* error condition is indeed still `0`

Alas, this is not the case if no configuration file is provided. Which makes
the thing both a bit inconsistent (two different behaviours in the exit only
by a difference in the pure presence of a configuration file) and not
backwards compatible.

I filed a [pull request][] to try and propose a patch that should restore
the previous behaviour. I hope it will be accepted... otherwise, I'll
provide a fake configuration file to the new script 🙄

Stay safe everyone!

[Crypt::LE update]: {{ '/2021/03/29/crypt-le-update/' | prepend: site.baseurl }}
[Crypt::LE]: https://metacpan.org/pod/Crypt::LE
[letsencrypt]: https://letsencrypt.org/
[ACME protocol]: https://letsencrypt.org/docs/acme-protocol-updates/
[ACME v2]: https://tools.ietf.org/html/rfc8555
[dibs]: https://blog.polettix.it/hi-from-dibs/
[pull request]: https://github.com/do-know/Crypt-LE/pull/60
