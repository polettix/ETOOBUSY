---
title: 'Data::Resolver in CPAN'
type: post
tags: [ perl ]
comment: true
date: 2023-02-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I released [Data::Resolver][].

After sharing the initial implementation [in the repository][], I
eventually wrote the rest of the documentation and release it as
[Data::Resolver][].

Then, by accident, I discovered that there's already [Path::Resolver][],
which addresses more or less the same problem in more or less the same
philosophy. I don't regret having shared it, though: I'm not thrilled to
use modules based on [Moose][], which is amazing but also mostly
overkill with respect to e.g. [Moo][] (at least in my limited
experience).

[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[in the repository]: https://codeberg.org/polettix/Data-Resolver
[Path::Resolver]: https://metacpan.org/pod/Path::Resolver
[Moose]: https://metacpan.org/pod/Moose
[Moo]: https://metacpan.org/pod/Moo
