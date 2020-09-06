---
title: EventSource and buffering
type: post
tags: [ mojolicious, web, perl, Dokku ]
comment: true
date: 2020-09-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> If your application serving the [EventSource web service][] is behind
> a (reverse) proxy, you might want to know how to disable buffering.

After talking about the [EventSource web service][] in previous post
[EventSource example][], I went on to use that idea for a little project
of mine that is hosted on a [Dokku][] instance.

Which happens to serve the stuff behind an [nginx][] instance.

The bottom line was that I wasn't seeing any pushed message. But...
after about a one-minute timeout on the session, I saw *all* of the
pushes. So... I was suffering from buffering. (By the way, definitely
check out the totally unrelated [Suffering from Buffering?][] article
from some years ago).

So, it turned out that this issue can be solved *in the code itself* by
adding a couple of headers, which I prompty did. So we moved from *just*
setting the Content-Type to `text/event-stream`on to the following:

```perl
   my $headers = $c->res->headers;
   $headers->content_type('text/event-stream');
   $headers->cache_control('No-Cache');
   $headers->header('X-Accel-Buffering' => 'no');
```

Yes, the `X-Accel-Buffering` is recognized by most reverse-proxy
technologies to disable buffering, which makes our push message be
delivered as soon as they are produced.

[EventSource web service]: https://metacpan.org/pod/Mojolicious::Guides::Cookbook#EventSource-web-service
[EventSource example]: {{ '/2020/09/05/eventsource-example' | prepend: site.baseurl }}
[nginx]: https://www.nginx.com/
[Suffering from Buffering?]: https://perl.plover.com/FAQs/Buffering.html
[Dokku]: http://dokku.viewdocs.io/dokku/
