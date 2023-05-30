---
title: A cheaper terminal trick
type: post
tags: [ perl, shell ]
comment: true
date: 2023-06-03 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An addition to [A cheap trick to manipulate PERL5LIB][].

In [A cheap trick to manipulate PERL5LIB][], from a *long* time ago, we saw
a way to generalize setting the `PERL5LIB` variable and reuse this
generalization.

The approach works fine when stuff is installed in a specific directory,
which is usually the `bin` directory in a `local` installation of modules.
This worked very good for applications that are available as, or in,
distributions.

Which led me to an additional trick that made the whole thing *cheaper*:
using a `cpanfile`. So I have a `perl-tools` directory, with a `cpanfile`
inside, and a short script to update the installation every time I want to
install something more:

```shell
#!/bin/sh
md="$(dirname "$(readlink -f "$0")")"
cd "$md"
PATH="$md/perl/bin:$PATH" PERL5LIB="$PERL5LIB:." "./carton-static"
```

The `carton-static` is just a standalone version of [Carton][], so that it
does not have to rely on anything already installed. There is a version in
[Installing Perl Modules][].

Stay safe!

[Perl]: https://www.perl.org/
[A cheap trick to manipulate PERL5LIB]: {{ '/2020/10/12/perl5lib-cheap-trick/' | prepend: site.baseurl }}
[Carton]: https://metacpan.org/pod/Carton
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
