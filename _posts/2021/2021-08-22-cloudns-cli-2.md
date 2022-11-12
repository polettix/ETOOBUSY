---
title: 'ClouDNS CLI: update'
type: post
tags: [ perl, cloudns, cli ]
comment: true
date: 2021-08-22 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little update on this project.

I eventually put the code I'm working on in [cloudns][].

To try it out:

- install dependencies using the provided `cpanfile` (see [Installing
  Perl Modules][] if you don't know what to do with it);
- adjust environment variable `PERL5LIB` to see the modules. If you
  installed the modules under `$PWD/local`, then do:

```shell
export PERL5LIB="$PWD/local/lib/perl5"
```

- set relevant environment variables for the service:

```shell
CLOUDNS_CREDENTIALS='sub-auth-user your-user-name your-password'
CLOUDNS_DOMAIN=your-domain.com
CLOUDNS_DUMP=1
```

- try out a query or two

```shell
id="$(./cloudns add a --host gasp --record 10.20.30.40)"
printf 'id: <%s>\n' "$id"
sleep 2
./cloudns del "$id"
```

The prototype supports listing, adding a few record types and deleting
them by identifier. It might also be interesting to add an interactive
interface... time will tell.

Stay safe everyone!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[cloudns]: https://gitlab.com/polettix/cloudns
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
