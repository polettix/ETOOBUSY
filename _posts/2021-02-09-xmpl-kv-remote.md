---
title: xmpl - remote key/value store
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-09 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> We will take a closer look at the implementation for the remote
> key/value store in [xmpl][]. This post is [part of a series][series].

In previous posts [xmpl - in-memory key/value store][] and [xmpl -
on-file key/value store][] we looked at two possible ways of
implementing the key/value store interface, namely via a wrapper of a
simple hash (resulting in `KVStore::InMemory`) or via a wrapper to this
class that also takes care to save changes on a JSON-encoded file
(resulting in `KVStore::InMemory`).

This time we will take a look at the last alternative: a *remote*
repository implementing what described in [xmpl - the key/value API][].

To do this, we rely on another great feature of [Mojolicious][]: the
ease to use its [Mojo::UserAgent][] class to send calls to a *remote*
instance of [xmpl][] itself!

```perl
package KVStore::Remote {
   use Mojo::UserAgent;
```

This time we keep no cache at all and we always ask the remote instance
for performing any action, be it read some data or store them. This is
done under the assumption that the backend might be exposed to more than
one single client, so it's just easier to avoid caching altogheter. And,
of course, that we are *not* aiming for any kind of performance.

```perl
   sub as_hash ($self) { $self->ua->get($self->url)->result->json->{kv} }
   sub get ($self, $key) {
      my $result = $self->ua->get($self->url_for($key))->result;
      die "failed\n" unless $result->is_success;
      return $result->json->{value};
   }
   sub has ($self, $key) {
      return ! $self->ua->head($self->url_for($key))->result->is_error;
   }
   #...
   sub remove ($self, $key) {
      say "remove <$key>";
      $self->ua->delete($self->url_for($key))->result;
   }
   sub set ($self, $key, $value) {say "$key<$value>";
      my $result = $self->ua->put($self->url_for($key),
         {'Content-Type' => 'application/octet-stream'} => $value)->result;
      die "failed " . $result->content unless $result->is_success;
      return;
   }
```

We are not following a RESTful approach here, as you might have seen.
This means that we don't provide a list of endpoints for the different
operations *inside* all (or some) or our answers - we just expect the
client on the other side to build the right URL and use them.

Again, it's a test program and the API is so limited that doing it
"properly" would have not added value. Well, it does not now, but only
until it will.

The `is_healthy()` method is always successful:

```perl
sub is_healthy { return 1 }
```

This might seem counterintuitive. Why not ask the remote also in this
case, or raise something if a timeout occurs?

The answer lies in how this `is_healthy` method will be eventually
consumed, i.e. possibly by a [Kubernetes][] liveness probe. We don't
want [Kubernetes][] to evict our pod(s) for the frontend every time the
backend is unavailable... so we just ignore it and always flag that
things are fine.

The rest of the code in the class is just for housekeeping, e.g. to
track the URL, generate URLs specific to the different remote endpoints,
etc.

```perl
sub new ($package, %as) {
   my $self = bless { %as }, $package;
   $self->{_url} = Mojo::URL->new($as{url} =~ s{/*\z}{/kvs/}rmxs);
   return $self;
}
sub origin ($self) { return $self->url }
sub ua ($self) { state $ua = Mojo::UserAgent->new; $ua }
sub url ($self) { $self->{_url}->clone }
sub url_for ($self, $key) {
   die "invalid key <$key>\n" unless $key =~ m{\A[\-\w.]+\z};
   my $target = $self->url;
   $target->path($target->path->merge($key));
   return $target;
}
```

If you want to look at the complete code for the class... [head to
it][]!

Before closing, though, it's time to take a look at *how* we are
selecting the right key/value store in our code:

```perl
sub kvstore ($be = undef) {
   state $kvstore = sub {
      return KVStore::InMemory->new unless defined $be;
      return KVStore::Remote->new(url => $be) if $be =~ m{\A http }mxs;
      return KVStore::OnFile->new(filepath => $be);
   }->();
}
```

Using a `state` variable basically makes `kvstore` a factory function
that returns a singleton. OK, enough jargon: using a `state` variable
makes `kvstore` return always the same object, initialized once.

The selection process across the different alternatives is performed
only *the very first time* the function is called, that is like this:

```perl
kvstore($ENV{KVSTORE}); # set kvstore singleton for this instance
```

Hence, the environment variable `KVSTORE` is what eventually tells
[xmpl][] what key/value store to use, which will be the *in-memory*
implementation if nothing is set, the *remote* backend if the value
seems to be a URL, and a file otherwise.

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
[head to it]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl#L48
