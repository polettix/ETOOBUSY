---
title: Caching with CHI
type: post
tags: [ perl ]
comment: true
date: 2022-06-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [CHI][] is an interesting module.

It's probably no wonder that I have a command-line tool that I sometimes
use for running LDAP queries.

Many times I query the same record multiple times within a limited
amount of time, so it makes sense to use some caching mechanism for
keeping the latest data around *for some time*, like a few minutes, in
order to retrieve them quickly locally and avoid generating unnecessary
traffic and load.

The typical way of using a cache is to "wrap" the query function like
this:

```perl
sub cacheable_query (@args) {
    my $key = compute_key_from(@args);
    if (my $cached_data = fetch_from_cache($key)) {
        return $cached_data;
    }
    my $fresh_data = real_query(@args);
    save_into_cache($key, $fresh_data);
    return $fresh_data;
}
```

This is just scratching the surface, of course. One thing that should be
taken into account is the *validity* of the cache, e.g. forcing the need
to *refresh* data if it's been cached more than a certain amount of
time.

This too is debatable: should we set an expiration time upon saving the
`$fresh_data`, much like food, or should we allow the call to
`fetch_from_cache()` to state what is considered fresh and what not in a
dynamic way?

The former approach (setting the expiration upon saving the data) is
very common and widespread, e.g. this is basically how HTTP caching
works (the server sets the expiration time).

This is also the approach taken by [CHI][], the go-to solution for
getting a robust and flexible framework for caching, decoupling the
usage of the cache (i.e. something along the line of the example API
above) from its internals (there are a variety of *drivers* for saving
cached data in different ways). This module is what I'm adopting at the
moment.

```perl
use CHI;

my $cache = CHI->new(driver => 'File', root_dir => '/tmp/foo');
sub fetch_from_cache($key) { $cache->get($key) }
sub save_into_cache ($key, $data) {
    $cache->set($key, $data', '10 minutes');
}
```

In the example above, I'm implementing the API in terms of [CHI][],
which is straightforward (to the point that I might just as well change
the calling locations and get rid of the two proof-of-concept functions
altogether).

Yet I'm not 100% convinced that this is the final decision. My tool is a
command-line one and I might like the idea to give the caller (well...
me of the future, right?) the ability to decide on the spot what to
consider *stale* and what not, based on factors that might change from
time to time.

This does not mean avoiding [CHI][], just adding a tiny layer on top to
cope with this *last-time expiration* tactic which is useful in my case
(or at least I think it is).

Stay safe!

[Perl]: https://www.perl.org/
[CHI]: https://metacpan.org/pod/CHI
