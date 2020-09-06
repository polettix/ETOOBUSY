---
title: CORS quick note
type: post
tags: [ web, mojolicious, perl ]
comment: true
date: 2020-09-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A quick note on [CORS][] for my future self.

From time to time, I try to program a frontend/backend pair with a
[JavaScript][]-based part in the browser and a [Perl][]-based backend on
some server.

And I regularly hit against the [CORS][] wall. Yes, *Cross-Origin
Resource Sharing*.

So, it's time to jot down a few notes that will help my future self
figure things out quicker this time:

- [CORS][] is a protection mechanism meant to help browsers *dp the
  right thing* when a page on domain `visible.to-user.com` tries to
  consume an API from `behind.the-courtains.org`.
- By default these calls would be blocked by the browser because the two
  domains are different.
- To allow this traffic, the API-providing host can say that it's OK to
  receive calls that come from a *different origin*, i.e. that come from
  a resource in a different domain than the API. In the specific
  example, host `behind.the-courtains.org` might signal that it's OK to
  receive requests that are originated from `visibile.to-user.com`.
- This *green light* is provided by means of a header
  `Access-Control-Allow-Origin`, to be set by the serving side in the
  response.
- When in the conditions of doing a *cross-origin* request, browsers
  usually do a *preflight* request to figure what's OK to request via
  the API, by means of an `OPTIONS` query. For this reason, it's better
  to also support `OPTIONS` requests.

In [Mojolicious][] this can be a *quick and dirty* proof of concept:

```perl
# handle CORS from the server side, i.e. in behind.the-courtains.org
options '/path/to/resource' => sub ($c) {
    $c->res->headers->header(
        'Access-Control-Allow-Origin' => 'visible.to-user.com');
    $c->render(code => 204);
};
post '/path/to/resource' => sub ($c) {
    $c->res->headers->header(
        'Access-Control-Allow-Origin' => 'visible.to-user.com');
    return $c->render(json => {everything => 'OK'});
};
```

Last, if you want your API consumable everywhere by anybody... use `*`
instead of the server's domain name.

[CORS]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
[Perl]: https://www.perl.org/
[JavaScript]: https://en.wikipedia.org/wiki/JavaScript
[Mojolicious]: https://metacpan.org/pod/Mojolicious
