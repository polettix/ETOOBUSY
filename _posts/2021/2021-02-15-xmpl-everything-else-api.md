---
title: 'xmpl - the API for everything else'
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-15 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A closer look to the [implementation][code] of the other mixed APIs in
> [xmpl][]. This is a [series of posts][series].

The last three API endpoints available in [xmpl][] aim to cover a very
wide range of (possible) needs.

Well, not all of them! The simpler one is to just gather the current
date and time:

```perl
get '/now' => sub ($c) {
   $c->render(json => {now => strftime('%Y%m%dT%H%M%SZ', gmtime)});
};
```

The strength of this endpoint is that it does not rely on anything else
than a clock inside the system; it can give you an idea of whether the
process is up and running or not (as opposed e.g. to looking at some
cache!) but it does not use the key/value store, which might be in
trouble.

Moving on to more generic stuff, the following function covers *any*
HTTP verb for `/status/:code`, where `:code` must be a numerical HTTP
status code. Simply put, it will return a response with that code.

```perl
any '/status/:code' => sub ($c) {
   my $code = $c->stash('code');
   if ($code eq 204) { $c->rendered(204) }
   else { $c->render(status => $code, text => "Status code: $code\n") }
};
```

The different handling of the `204` status code is because... `204`
means *No Content*, so we cannot put some `text` in the body. Otherwise,
we just send the message stating what status code we got.

Last, as a final *catchall*, we render a boring `404` for everything
else we don't know about:

```perl
any '/*x' => sub ($c) { $c->render(status => 404, text => 'Not Found') };
```

And I guess this is it for the application, thanks for arriving up to
here and stay safe!

[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
