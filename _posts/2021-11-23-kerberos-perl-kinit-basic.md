---
title: A bare-bones kinit in Perl
type: post
tags: [ perl, kerberos, security ]
comment: true
date: 2021-11-23 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Implementing a very basic [kinit][] functionality using
> [Authen::Krb5][] in [Perl][].

When playing with [Kerberos][], at a certain point there will be the
need to login with a password *at least on time*, right?

This is where [kinit][] usually comes into play: run it with the
*principal* and it will populate the cache with
*one-ticket-to-rule-them-all*:

```
kinit admin@DEMO1.FREEIPA.ORG    # password is Secret123
```

(Example possible thanks to the [demo at FreeIPA][]).

This is (I hope) sufficient, i.e. no fancy options to be passed. Just a
plain remote authentication with whatever is default.

What if we don't (want to) have [kinit][] though?

Well... we can use [Perl][] with [Authen::Krb5][], of course!

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Scalar::Util 'blessed';

use Authen::Krb5;

sub wtf () { die Authen::Krb5::error() . "\n" }

Authen::Krb5::init_context() or wtf;

my $user = shift // 'admin@DEMO1.FREEIPA.ORG';
my $principal = Authen::Krb5::parse_name($user)  or wtf;
say 'principal is-a ', blessed($principal);

my $cache_location = 'MEMORY';
my $cache = Authen::Krb5::cc_resolve($cache_location) or wtf;
say 'cache is-a ', blessed($cache);
$cache->initialize($principal) or wtf;

my $credentials = Authen::Krb5::get_init_creds_password(
   $principal, 'Secret123') or wtf;
say 'credentianls is-a ', blessed($credentials);
$cache->store_cred($credentials) or wtf;

exit 0;
```

The magic is done by `get_init_creds_password`, which takes defaults
from a file and environment variables, *I guess*. Whatever, it works!

In this case we're setting the *cache location* in `MEMORY`, because we
don't need to save the received ticket permanently. For any later usage
(be it in `MEMORY` or elsewhere) it's still necessary to call
`$cache->store_cred(...)` or our `$credentials` will not be available
down the line. *I guess*.

It's also possible to select the default location for the system,
usually a file that will be used by all other applications (e.g. an LDAP
client). In this case, instead of `cc_resolve(...)` it's possible to use
`cc_default()` (no parameters).

Next stop will be figuring out if it's possible to mix this loading of
the tickets *in memory* and have the SASL modules use it... stay tuned!



[Perl]: https://www.perl.org/
[Authen::Krb5]: https://metacpan.org/pod/Authen::Krb5
[kinit]: https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kinit.html
[Kerberos]: https://web.mit.edu/kerberos/
[demo at FreeIPA]: https://www.freeipa.org/page/Demo
