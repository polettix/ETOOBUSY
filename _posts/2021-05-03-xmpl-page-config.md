---
title: xmpl - the page configuration API
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-05-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A closer look to the page configuration API in [xmpl][]. This is a
> [series of posts][series].

Sometimes it happens that an example might come handy to both show that
it is capable of doing something, as well as being configured to do
something. Not clear? Well... you have to be in that situation to
understand 😄

[xmpl][] allows you to set up a quick webbish example application that
provides, at its basic level, a key-value store. With time, it has grown
to support a few additional integrations, e.g. it supports
[Prometheus][]-compatible [metrics][] and [Kubernetes][]-compatible
"[healtz][]" endpoints.

Now suppose that you need this application to test how to deploy
something automatically. Many applications will need some day-0
configuration (i.e. configuration that is injected just when it is
created), as well as day-1 configurations (to set the right *parameters*
of customization for your application), as well as day-N configurations
(e.g. to evolve the customizations).

[xmpl][] already provided something to simulate day-1 (and, by
extension, day-N) configurations, i.e. its [identity API][]. Setting a
different identity is a configuration... right?

# Adding MOAR configuration

I wanted to add something that would make it a little bit more
*evident*, so [xmpl][] now supports a new `/page-config` endpoint that
lets you manipulate a simple configuration for the appearance of the web
page exposed by the [browser API][]. Nothing too fancy:

- you can now set a `title` - this should be a sufficient demonstration,
  right?
- you can set a different background color via `bgcolor` - how to better
  give a sense of *customization* than to set the page to a dark color?
- you can set a different `font` family - this can add some spice...
- you can set a totally custom `css` definition.

The API to configure the page is a bit basic but it should be easy to
consume programmatically. It is possible to `GET` the current
configuration as a [JSON][]-formatted object:

```shell
$ curl -s http://localhost:3000/page-config | json_pp
{
   "title" : "Example Application",
   "bgcolor" : "#eeffee",
   "font" : "sans-serif"
}
```

It is also possible to `PUT` the configuration, passing a new
[JSON][]-formatted object:

```shell
$ curl -s http://localhost:3000/page-config -X PUT -d '{"title":"Whateeeevah!"}' | json_pp
{
   "bgcolor" : "#eeffee",
   "title" : "Whateeeevah!",
   "font" : "sans-serif"
}
```

The new object *mostly overrides* the previous one - in the sense that
the three keys `bgcolor`, `title` and `font` will *always* have a
non-null value. Apart from this, it's a complete replacement.

# Implementation

The implementation is not complicated, let's take a look:

```perl
########################################################################
#
# Page configuration manipulation
#
get '/page-config' => sub ($c) { $c->render(json => {page_config()}) };
put '/page-config' => sub ($c) {
    return $c->render(json => {page_config($c->req->json)});
};

# ...

sub page_config ($new = undef) {
   state $defaults = {
      title => 'Example Application',
      bgcolor => '#eeffee',
      font => 'sans-serif',
   };
   state $config = {$defaults->%*};
   if ($new) {
      $config->%* = $new->%*;
      while (my ($key, $value) = each $defaults->%*) {
         $config->{$key} //= $value;
      }
   }
   return $config->%*;
}
```

The two endpoints are trivial wrappers around the `page_config()`
function. The `GET` verb just returns a [JSON][] rendition of the
current configuration, while the `PUT` verb installs a new one.

The real action is inside `page_config()`, which acts as a *sort of
singleton object* to some extent. I mean... I tried to avoid having a
global variable and resorted to the same trick adopted for `identity()`,
`kvstore()` etc.

The actual configuration is stored in `state` variable `$config`; the
other `state` variable holds the default values that will be injected in
lack of a proper value for the corresponding keys (i.e. we insist that
these keys are present and point to a defined value).

The function returns the list of key/value pairs in the configuration,
for external consumption.

# Final remarks

And now, just before closing this post... I can hear a big elephant
question in the room:

> Why not use the [key/value API][] to add a few pairs and show that the
> automatic system works?!?

Sure, that would have demonstrated a successful interaction... but it
would have been *so cheap*!!!

[xmpl]: https://gitlab.com/polettix/xmpl
[Prometheus]: https://prometheus.io/
[metrics]: {{ '/2021/02/14/xmpl-metrics-api/' | prepend: site.baseurl }}
[healtz]: {{ '/2021/02/13/xmpl-healthz-api/' | prepend: site.baseurl }}
[identity API]: {{ '/2021/03/01/xmpl-identity-api/' | prepend: site.baseurl }}
[browser API]: {{ '/2021/02/12/xmpl-browser-api/' | prepend: site.baseurl }}
[key/value API]: {{ '/2021/02/06/xmpl-kv-api/' | prepend: site.baseurl }}
[JSON]: https://www.json.org/json-en.html
[Kubernetes]: https://kubernetes.io/
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
