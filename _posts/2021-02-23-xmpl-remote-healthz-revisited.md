---
title: xmpl - remote key/value store healthz revisited
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-23 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Changing approach to establish the *healthz* of a `KVStore::Remote`
> object for [xmpl][]. With rationale.
> This post is [part of a series][series].

In previous post [xmpl - remote key/value store][] we looked into the
implementaton of the `KVStore::Remote` class, which acts as a proxy for
a *remote* instance of [xmpl][].

The `is_healthy()` method described there is always successful:

```perl
sub is_healthy { return 1 }
```

This was the explanation:

> This might seem counterintuitive. Why not ask the remote also in this
> case, or raise something if a timeout occurs?
>
> The answer lies in how this `is_healthy` method will be eventually
> consumed, i.e. possibly by a [Kubernetes][] liveness probe. We don't
> want [Kubernetes][] to evict our pod(s) for the frontend every time
> the backend is unavailable... so we just ignore it and always flag
> that things are fine.

After pondering harder on this matter, I think this is not the right
approach. The class, and in general the program, should provide faithful
information about its state; if it's not able to access the real
key-value store, it should complain much like the `KVStore::OnFile`
class does.

On the other hand, *how* this information will be used needs to be aware
of it. If it's in [Kubernetes][] and it does not need to undergo an
eviction-recreation cycle when the test goes wrong... well, then there
should be no Liveness test. It's *at that point* that the information
should be dropped.

So... the method is now changed as follows:

```perl
sub is_healthy ($self) { eval { $self->ua->head($self->url) } }
```

i.e. it just checks that the query does not time out, although it
disregards the outcome. One step at a time.

While at it, I also decided to set some limits in the
[Mojo::UserAgent][] object:

```perl
sub ua ($self) {
   state $ua = Mojo::UserAgent->new(
      max_redirects   => 5,
      connect_timeout => 2,
   );
}
```

In this way, a failing remote instance will not make the current
instance wait for too long.

If you want to look at the complete code for the class... [head to
it][]!

Stay safe!



[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
[xmpl - the key/value API]: {{ '/2021/02/06/xmpl-kv.api.md' | prepend: site.baseurl }}
[xmpl - in-memory key/value store]: {{ '/2021/02/07/xmpl-kv-memory.md' | prepend: site.baseurl }}
[xmpl - on-file key/value store]: {{ '/2021/02/07/xmpl-kv-file.md' | prepend: site.baseurl }}
[Mojo::File]: https://metacpan.org/pod/Mojo::File
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[head to it]: https://gitlab.com/polettix/xmpl/-/blob/v0.3.0/xmpl#L48
[xmpl - remote key/value store]: {{ '/2021/02/09/xmpl-kv-remote/' | prepend: site.baseurl }}
