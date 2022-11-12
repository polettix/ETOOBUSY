---
title: xmpl - enhancements by Mark Lawrence
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-05-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Mark Lawrence][mlawren] enhanced [xmpl][], thanks!

After having written [so much][series] about [xmpl - an example web
application][], I thought that even a casual reader would be pretty
bored about it.

Well, not so for [Mark][mlawren] it seems. He provided improvements to
the project, by making sure to return a better status code in some cases
(they were all squashed onto `500` before), as well as providing
automatic tidying capabilities and a new endpoint for describing the
available routes.

The last one prompted me to re-read the documentation for
[Mojolicious][] and figure that it's possible to add *names* to *routes*
and these names need not be tokens. Hence Mark set them to give a
concise explanation of the endpoint and make the day. Brilliant!

As an example, route `GET /visible` becomes this:

```perl
get '/visible' => sub ($c) {
   my @targets = split m{\n+}mxs, $c->param('targets');
   $c->render(json => check_visible(@targets));
} => 'Check server visibility of target URLs';
```

A function `endpoints` takes care to collect them all:

```perl
sub endpoints {
   state $e = do {
      my %endpoints;
      my $msub =
        Mojolicious::Routes::Route->can('via')
        ? 'via'
        : 'methods';

      for my $route (app->routes->children->@*) {
         my $pattern = $route->pattern->unparsed || '/';
         my $methods = $route->$msub;
         for my $m (!$methods ? ('*') : $methods->@*) {
            $endpoints{$pattern}{$m} = $route->name;
         }
      }

      \%endpoints;
   };
}
```

This is consumed in the new endpoint `GET /sitemap`:

```perl
get '/sitemap' => sub ($c) {
   my %args = (
      inline    => template_index(),
      cnf       => {page_config()},
      kvstore   => kvstore()->origin,
      kv        => {},
      identity  => identity(),
      endpoints => endpoints(),
   );
   $c->render(%args);
} => 'Displays a summary of HTTP targets & methods (this page)';
```

which expands the common template as for the main entry point, only to
show these routes.

Thanks [Mark][mlawren]!

[xmpl - an example web application]: {{ '/2021/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[mlawren]: https://metacpan.org/author/MLAWREN
