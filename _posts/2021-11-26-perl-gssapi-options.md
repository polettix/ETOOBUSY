---
title: Perl GSSAPI options
type: post
tags: [ perl, gssapi, security, kerberos ]
comment: true
date: 2021-11-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Passing options to [Perl][] module [GSSAPI][] is a bit clunky but
> doable.

It's no secret I'm messing with [Net::LDAP][] and [Kerberos][] too, which
means using [Authen::SASL][] with a [GSSAPI][] mechanism.

Confused? Well, I was, and I probably still am - although possibly a bit
less. More on this in some future post, anyway.

One specific problem I encountered while trying to make the
[getcred\_hostbased.pl][example] example ([local version here][]) work
was about some automatic DNS resolutions and canonicalization actions
performed by the library, which make working with the [FreeIPA demo][]
impossible

> See also the ASCII-cast in [Trying Kerberos][]. The need to add
> command-line option `-N` to `ldapsearch` stems from the same reason.

There seems to be no place where to put additional options in the
[GSSAPI][] bindings, and probably in the whole `GSSAPI` thing, which is
a generic mechanism that *might* be tied to [Kerberos][], but not
necessarily.

One way to get those options in place is through a configuration file,
which the library goes to look for based on environment variable `KRB5_CONFIG`. In my case, to disable the annoyance it sufficed to do this:

```shell
$ export KRB5_CONFIG="$PWD/custom-krb5.conf"
$ cat > "$KRB5_CONFIG" <<'END'
[libdefaults]
dns_canonicalize_hostname = false
default_ccache_name = MEMORY
END
```

Actually... only disabling `dns_canonicalize_hostname` was needed to
make the example work, but I decided to avoid cluttering the filesystem
anyway 😅

Now I'm left wandering how many security pitfalls are hidden in this
intricate way of setting a few options... 🤯  I'll probably go look into
`ldapsearch` to see what they do.

Stay safe folks!

[Perl]: https://www.perl.org/
[GSSAPI]: https://metacpan.org/pod/GSSAPI
[Authen::SASL]: https://metacpan.org/pod/Authen::SASL
[example]: https://metacpan.org/release/AGROLMS/GSSAPI-0.28/source/examples/getcred_hostbased.pl
[local version here]: {{ '/assets/code/getcred_hostbased.pl' | prepend: site.baseurl }}
[Trying Kerberos]: {{ '/2021/11/22/trying-kerberos/' | prepend: site.baseurl }}
[FreeIPA Demo]: https://www.freeipa.org/page/Demo
[Kerberos]: https://web.mit.edu/kerberos/
[Net::LDAP]: https://metacpan.org/pod/Net::LDAP
