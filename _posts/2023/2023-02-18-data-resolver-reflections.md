---
title: 'Reflections after a couple of weeks of Data::Resolver'
type: post
tags: [ perl ]
comment: true
date: 2023-02-18 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Some reflections on the evolution of [Data::Resolver][].

I used [Data::Resolver][] for a couple of weeks now, so I'm here to
provide feedback on it.

> Yep... this has a definite scent of [Cast Away][ca].

For starters, it would be good to have a *Do What I Mean* factory that
just gets *something* and gives out the right thing. I mean, at the
basic level I'm providing support for *directories* and *TAR archives*,
shouldn't we be able to provide a path and let the code figure it out
automatically? It might be either a new function `dwim` or an extension
to the current `generate`, accepting a plain string for a path.

Another thing I didn't see coming is that support for sub-resolvers
would be good. In a directory, they would be like sub-directories.

This might already be solved *directly* by wrapping a resolver with a
function that performs automatic insertion of a prefix in the keys. It
would still require some out-of-band mechanism to figure out what
prefixes would be supported, though, so it's either a full analysis of
the list of keys (which would be sub-optimal with lots of them), or
requires an extension to the resolver specification to gather a list of
sub-resolvers in addition to a list of all supported keys.

While at it, I'm also playing with the idea of having small objects that
encapsulate some content, and have methods to get the right
representation out of them. This would be used like this:

```
my $obj = $resolver->get($key);
say $obj->as_scalar;
say ${$obj->as_scalar_ref};
say 'your data is at ', $obj->as_file;
my $fh = $obj->as_fh; # get a filehandle...
```

The similarity to the directory/file case is clear, so I'm tempted by
the [Path::Tiny][] approach to have a single object to manage them both;
I'm probably going for two different classes though, as
[Data::Resolver][] aims at solving a specific problem which does not
include much *common* stuff like fiddling with permissions and altering
the sources.

Stay tuned and stay safe!


[ca]: https://en.wikipedia.org/wiki/Cast_Away
[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[Path::Tiny]: https://metacpan.org/pod/Path::Tiny
