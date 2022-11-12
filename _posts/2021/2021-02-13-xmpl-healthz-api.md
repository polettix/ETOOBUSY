---
title: 'xmpl - the "healthz" API'
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A closer look to the [implementation][code] of the "healthz" API in
> [xmpl][]. This is a [series of posts][series].

In applications that aim to be deployed in [Kubernetes][], it is often
good to provide an endpoint that the external platform can call to
figure out whether the application is *feeling good* or not. In case it
does not... the system will figure out.

This interface does not need to be anything complicated: setting the
right HTTP status code suffices. In our case, we will provide back a
`204` (*No Content*) when the health check is successful, and a `500`
when it is not:

```perl
get '/healthz' => sub ($c) {
   if (is_healthy()) { $c->rendered(204) }
   else { $c->render(status => 500, text => "Internal Server Error\n") }
};
```

As we can see, the whole health check is encapsulated into a call to
function `is_healthy`: depending on the outcome, we give back the
relevant HTTP status code.

But... we are in an example application that should be useful for
testing, right? What if we want to test the outer platform, then?

It's useful to be able to tell the application to *always* appear as
either healthy or unhealthy; for this reason, we can leverage the
endpoint for the `PUT` verb:

```perl
put '/healthz' => sub ($c) {
   is_healthy(($c->req->text // '') =~ s{\A\s+|\s+\z}{}grmxs);
   $c->rendered(204);
};
```

This calls the same `is_healthy` function, this time passing a
value (taken from the body by stripping leading and trailing spaces) to
*set* the desired output. This gives us a handle to externally control
what the `GET` endpoint will respond back.

Now, of course, it's time to take a look at `is_healthy`:

```perl
sub is_healthy {
   state $h;
   $h = shift if @_;
   defined($h) && length($h) ? $h : kvstore()->is_healthy;
}
```

It's *like* a little singleton object with one single method, right? If
the value of the internal state (`$h`) is set to a non-empty string,
then it will be used as a regular [Perl][] boolean; otherwise, the
health of the key/value store will be assessed. This behaviour on an
empty string allows *resetting* the behaviour from the `PUT` endpoint
(i.e. just pass an empty body in the HTTP PUT request).

Stay healthy!

[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
