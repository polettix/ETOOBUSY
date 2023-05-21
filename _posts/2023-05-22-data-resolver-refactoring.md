---
title: 'Data::Resolver refactoring'
type: post
tags: [ perl ]
comment: true
date: 2023-05-22 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Moving on with [Data::Resolver][].

It's no secret that I had second thoughts about the initial interface of
[Data::Resolver][] (as already anticipated in [Data::Resolver - trial
release with OOP interface][]). At the moment, the module is in a *mixed*
state, both supporting the old interface and the new (with a split in the
implementation).

Some of the old interface is worth preserving, especially the support
functions that do not rely on the overall interface assumptions. To avoid
having double/diverging implementations, though, I think it's better to
implement the old interface by means of the new OOP approach, in particular
by using the `Data::Resolver::Asset` interface.

This led to the [updated implementation][], revolving around the `transform`
function which is a wrapper around the asset class:

```perl
sub data_to_fh   { ${transform($_[0], qw< data fh >)}          }
sub data_to_file { ${transform($_[0], qw< data file >, $_[1])} }

sub fh_to_data ($fh)          { ${transform($fh, qw< fh data >)}      }
sub fh_to_file ($fh, $kp = 0) { ${transform($fh, qw< fh file >, $kp)} }

sub file_to_data ($input) { ${transform($input, qw< file data >)} }
sub file_to_fh ($input)   { ${transform($input, qw< file fh >)}   }
```

The `transform` function always returns a reference... so there's the
`${transform(...)}` indirection to get back to the actual thing.

Stay safe!

[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[Data::Resolver - trial release with OOP interface]: {{ '/2023/03/04/data-resolver-oop-trial/' | prepend: site.baseurl }}
[updated implementation]: https://codeberg.org/polettix/Data-Resolver/src/commit/9780264a4c34bf1c2a177440bd98d661d69a5b08/lib/Data/Resolver.pm#L181
