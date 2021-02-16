---
title: 'Mojo::UserAgent introductory notes'
type: post
tags: [ mojolicious, perl, user agent ]
comment: true
date: 2021-02-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A few notes about [Mojo::UserAgent][].

This is *adapted* from the first example in the [SYNOPSIS][] (as of this
post's date, anyway):

```perl
my $ua = Mojo::UserAgent->new(max_redirects => 5, connect_timeout => 2);
my $res = $ua->get('docs.mojolicious.org')->res;
if    ($res->is_success)  { say $res->body }
elsif (! $res->code)      { say 'connection error' }
elsif ($res->is_error)    { say 'got error ' . $res->message }
else                      { say 'got status code ' . $res->code }
```

## Constructor

The `new` method builds a new [Mojo::UserAgent][] object and returns it.

Setting object's [ATTRIBUTES][] can be done in two ways:

- passing options directly as arguments in key/value form, e.g.:

```perl
my $ua  = Mojo::UserAgent->new(
    max_redirects   => 5,
    connect_timeout => 2,
);
```

- chaining them (each call that sets a new value returns the
  [Mojo::UserAgent][] object itself):

```perl
my $ua  = Mojo::UserAgent->new
    ->max_redirects(5)
    ->connect_timeout(2);
```

## Query execution, `res` over `result`

The query is run as soon as it is requested (at least for blocking
requests). In other terms, this generates actual traffic:

```perl
$ua->get('docs.mojolicious.org')
```

The outcome of a [get][] (or [post][], or...) is a
[Mojo::Transaction::HTTP][] (/[Mojo::Transaction][]) object, but this is
generally not what is needed.

The actual *response* to the request can be retrieved using either `res`
or `result`, which return a [Mojo::Message::Response][]
(/[Mojo::Message][]). The two are *almost* interchangeable, with the
following important note:

> `result` throws an exception if there is a connection timeout.

If all outcome checking is done explicitly, the best choice is `res`.


## Checking for errors

The main star is `is_success` - this is only true if a `2xx` is
*eventually* received. *Eventually* means that redirects were followed
if attribute `max_redirects` is set to a suitable value.

If `max_redirects` is *not* set, and a redirection is received, then
`is_success` is *false* and `is_redirect` is true.

It's possible to look at all the `is_...` methods in
[Mojo::Message::Response][].

If it is impossible to connect to the server, `code()` returns a *false*
value; hence, if `res` is used instead of `result`, it can be used to
check for connection errors.


## `body`, `content`, and `message`

With a `res`ponse at hand, chances are that its content is needed.

What is needed 80% of the times is provided by `body`. It does what
written on the can: return the `body` section of the response.

The `content` method is *rarely* what is needed. It's a lower level
interface for fiddling.

Last, `message` refers to the small text that is usually provided along
with a HTTP error code. Again, rarely what is acually needed.

# Useful links

The following pages can help a lot:

- [SYNOPSIS][]
- [Commented examples in the Cookbook][]
- [Mojo::Message][] and [Mojo::Message::Response][]




[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Commented examples in the Cookbook]: https://metacpan.org/pod/distribution/Mojolicious/lib/Mojolicious/Guides/Cookbook.pod#USER-AGENT
[SYNOPSIS]: https://metacpan.org/pod/Mojo::UserAgent#SYNOPSIS
[Mojo::Message]: https://metacpan.org/pod/Mojo::Message
[Mojo::Message::Response]: https://metacpan.org/pod/Mojo::Message::Response
[Mojo::Transaction::HTTP]: https://metacpan.org/pod/Mojo::Transaction::HTTP
[Mojo::Transaction]: https://metacpan.org/pod/Mojo::Transaction
[ATTRIBUTES]: https://metacpan.org/pod/Mojo::UserAgent#ATTRIBUTES
[get]: https://metacpan.org/pod/Mojo::UserAgent#get
[post]: https://metacpan.org/pod/Mojo::UserAgent#post
