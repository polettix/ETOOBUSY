---
title: xmpl - in-memory key/value store
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> We will take a closer look at the implementation for the in-memory
> key/value store in [xmpl][]. This post is [part of a series][series].

In previous post [xmpl - the key/value API][] we gave a quick look at
the interface for the key/value store object that is used by the API
endpoints to actually store the key/value pairs:

- `as_hash()`: return the whole key/value store as a hash with key/value
  pairs;
- `get($key)`: get the value associated to a key;
- `has($key)`: check if the store has a given key;
- `is_healthy()`: return a boolean result depending on whether the
  object considers to be in a healthy state or not;
- `new(@args)`: the constructor;
- `origin`: what is the actual backend for the key/value store (e.g.
  memory, file, remote URL, ...);
- `remove($key)`: remove a given key/value pair;
- `set($key, $value)`: set the provided value associated to the provided
  key.

Here we go with the implementation of this interface for the *in-memory*
store:

```perl
package KVStore::InMemory {
   sub as_hash ($self) { return {$self->%*} }
   sub get ($s, $k) { return $s->{$k} if exists $s->{$k}; die "unknown\n" }
   sub has ($self, $key) { return exists $self->{$key} }
   sub is_healthy { return 1 }
   sub new ($package, $kvps = {}) { return bless {$kvps->%*}, $package }
   sub origin ($self) { return '<memory>' }
   sub remove ($self, $key) { delete $self->{$key}; return $self }
   sub set ($self, $key, $value) { $self->{$key} = $value; return $self }
}
```

I have to admit that this is the first time I use this way of declaring
a package with the scoping restricted to a block, but I like the idea
very much.

The basic idea in this initial key/value store is that we just provide a
wrapper around THE key/value store in [Perl][]: a hash. Hence, it's easy
to see that in `as_hash` we just provide a copy of the key/value pairs
in our hash, that `has` maps to `exists`, and so on.

As it's living in memory, we always consider instances of this class to
be healthy, so we're consistently returning `1` to flag that everything
is OK.

Last, `origin` is set to `<memory>` because... the hash lives in memory,
right?


[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[xmpl - the key/value API]: {{ '/2021/02/06/xmpl-kv.api.md' | prepend: site.baseurl }}
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
