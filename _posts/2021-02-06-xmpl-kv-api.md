---
title: xmpl - the key/value API
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-06 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A closer look to the [implementation][code] of the key/value API in
> [xmpl][]. This is a [series of posts][series].

In previous post [xmpl - an example web application][] we took a look at
[xmpl][]; in this post we will begin taking a look at the internals,
starting from the implementation of the basic key/value store API.

# An assumption about the *model*

In the code, we will assume that there is a *class* (actually, a
[Perl][] package) implementing the *model* for the key/value store.

In practice, we will encapsulate all key/value store operations in a
class, and we will only call the public methods of this class. To make
sure we are always using the same instance inside a single process, we
will also assume that function `kvstore()` gives us the reference to the
object, so that we can call methods on it.

The basic interface of this class is the following:

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

# The API

Based on the model described above, this is the basic API provided by
the web interface:

```perl
get '/kvs' => sub ($c) {
    eval { $c->render(json => {kv => kvstore()->as_hash}); 1 }
        or $c->render(status => 500, text => $@);
};
post '/kvs' => sub ($c) {
    eval { kvstore()->set($c->param('key'), $c->param('value')); 1 }
        or $c->render(status => 500, text => $@);
};
del '/kvs/:key' => sub ($c) {
    eval {
        my $key = $c->stash('key');
        kvstore()->remove($key);
        $c->render(json => {key => $key});
        1;
    } or $c->render(status => 500, text => $@);
};
get '/kvs/:key' => sub ($c) {
    eval {
        my $key = $c->stash('key');
        my $value = kvstore()->get($key);
        $c->render(json => {key => $key, value => $value});
        1;
    } or $c->render(status => 500, text => $@);
};
put '/kvs/:key' => sub ($c) {
    eval {
        my $key = $c->stash('key');
        kvstore()->set($key, $c->req->body);
        $c->render(json => {key => $key});
        1;
    } or $c->render(status => 500, text => $@);
};
```

Most operations are wrapped by a call inside a *good* `eval` (i.e. the
block one, not the string one), in order to catch exceptions and
transform them into HTTP status code `500` responses. Apart from this,
each endpoint does what it's written on the tin, i.e. get the whole
key/value store, add stuff, remove stuff, etc.

Additionally, when things go right we want to return JSON-encoded
strings for our Perl data structures, so we rely on the convenience
provided by [Mojolicious][] to just pass `json => $data_structure`,
letting it do all the magic behind (including setting the right
`Content-Type` header in the response). I really like this DWIM attitude
in [Mojolicious][].

The setup is not particularly safe: when we return an error, we pass the
content of the exception, which might be a security concern. But it's a
test application, so we can live with that.

As antipated, all calls are performed upon the output of `kvstore()`,
which provides back a reference to the (singleton) object to manipulate
the key/value store.

# Enough!

We can call this a day... in posts to follow we will continue to take a
look at the code, don's say I didn't warn you!

[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
