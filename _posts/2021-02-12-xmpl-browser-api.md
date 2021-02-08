---
title: xmpl - the API for browsers
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-12 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> We will take a closer look at the implementation for the API available
> to the browsers in [xmpl][]. This post is [part of a series][series].

In previous post [xmpl - the key/value API][] we took a look at the
basic API provided by [xmpl][], that is mainly geared at being consumed
in a *machine to machine* way.

An example application, though, is also something useful to look at from
the browser, which means generating HTML pages and leveraging `GET` and
`POST` methods "only" (at least if we want to avoid using Javascript to
keep things simple).

The `GET` verb is addressed by a function that gets all the key/value
pairs as a hash and calls the `render` method, which will transform
these data into a page according to the template provided by the
function `template_index`:

```perl
get '/' => sub ($c) {
   my %args = (inline => template_index(), kvstore => kvstore()->origin);
   if (! ($args{kv} = eval { kvstore()->as_hash })) {
      $args{kv} = {};
      $args{error} = 'could not read key/value pairs from store';
   }
   $c->render(%args);
};
```

We will not get into the details of the template, you an take a look at
it [here][template].

The `POST` verb is overloaded with two sub-actions, one for *adding* (or
modifying) a key/value pair, one for *deleting* it. This is tracked via
parameter `sub-action`:

```perl
post '/' => sub ($c) {
   eval {
      my $sub_action = $c->param('sub-action');
      if ($sub_action eq 'delete') {
         kvstore()->remove($c->param('key'));
         $c->flash(info => 'element removed');
      }
      else {
         kvstore()->set($c->param('key'), $c->param('value'));
         $c->flash(info => 'element added');
      }
      1;
   } or $c->flash(error => 'action failed');
   $c->redirect_to('/');
};
```

This always redirects to the `GET`, so that we keep it simple.

The last part is the overriding of the `favicon.ico` icon, to add some
sugar (the `favicon` function can be seen [here][favicon]):

```perl
get '/favicon.ico' => sub ($c) {
   $c->render(
      status => 200,
      data => favicon(),
      format => 'png',
   );
};
```

Except that... *this does not work*.

[Mojolicious][] generats a *favicon* by itself, and the request never
gets to hit the route above (which is somehow weird, in my opinion). The
solution is to explicitly get rid of the internally generated one:

```perl
delete app->static->extra->{'favicon.ico'};
```

That's it! An ugly, bare-bones, very 90-esque page that is shown in a
real browser!


[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl - the key/value API]: {{ '/2020/02/06/xmpl-kv-api/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
[xmpl - the key/value API]: {{ '/2021/02/06/xmpl-kv.api.md' | prepend: site.baseurl }}
[xmpl - in-memory key/value store]: {{ '/2021/02/07/xmpl-kv-memory.md' | prepend: site.baseurl }}
[Mojo::File]: https://metacpan.org/pod/Mojo::File
[template]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl#L236
[favicon]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl#L309
