---
title: 'Data::Resolver base class for resolver'
type: post
tags: [ perl ]
comment: true
date: 2023-02-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A base class for the object-oriented [Data-Resolver][].

To evolve [Data-Resolver][] I'm thinking about implementing the
following interface in the different resolver classes (e.g. getting
stuff rom a local directory or a TAR archive):

```
sub get_asset              ($self, $key) { ... }
sub get_sub_resolver       ($self, $key) { ... }
sub has_asset              ($self, $key) { ... }
sub has_sub_resolver       ($self, $key) { ... }
sub list_asset_keys        ($self)       { ... }
sub list_sub_resolver_keys ($self)       { ... }
```

We're handling two different kind of *things* out of a resolver, namely
*assets* and *sub-resolvers*.

Incidentally, I'm *literally* using `...` in the code of the base class
defining these methods. Hence I'm getting an abstract class definition
almost for free and very idiomatically!

Stay safe everybody!



[Perl]: https://www.perl.org/
[Data-Resolver]: https://codeberg.org/polettix/Data-Resolver
