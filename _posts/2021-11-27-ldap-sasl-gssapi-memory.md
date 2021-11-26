---
title: Example LDAP with on-the-fly Kerberos authentication
type: post
tags: [ ldap, kerberos, security, perl ]
comment: true
date: 2021-11-27 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> An example to do [Kerberos][] authentication in memory, i.e. without
> the need of using [kinit][] beforehand or to save anything on the
> disk.

Mixing [Net::LDAP][] with [Authen::SASL], being aware of how [GSSAPI][]
works and using [Authen::Krb5][] to get an initial ticket, without
necessarily saving anything in the filesystem.

<script src="https://gitlab.com/polettix/notechs/-/snippets/2209824.js"></script>

[Local version here][].

The `acquire_TGT` function is basically the same as [A bare-bones kinit
in Perl][] - nothing new here. Getting stuff with `LDAP_search` is
basically the same as in [eldap][]. So... we're just doing plain ol'
integration here - all with a configuration file!

Well... be my guest, *future me*, and stay safe everybody!

[GSSAPI]: https://metacpan.org/pod/GSSAPI
[Net::LDAP]: https://metacpan.org/pod/Net::LDAP
[Authen::SASL]: https://metacpan.org/pod/Authen::SASL
[Authen::Krb5]: https://metacpan.org/pod/Authen::Krb5
[Perl]: https://www.perl.org/
[Local version here]: {{ '/assets/code/ldap-search-with-memory-kerberos.pl' | prepend: site.baseurl }}
[Kerberos]: https://web.mit.edu/kerberos/
[A bare-bones kinit in Perl]: {{ '/2021/11/23/kerberos-perl-kinit-basic/' | prepend: site.baseurl }}
[eldap]: https://gitlab.com/polettix/eldap/-/blob/b7f8c4fbf0d31d8ccc790711978dd1b3631dc515/eldap#L101
