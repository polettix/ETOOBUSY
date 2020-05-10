---
title: Content negotiation in Mojolicious
type: post
tags: [ mojolicious, perl ]
comment: true
date: 2020-05-10 07:00:00 +0200
published: true
---

**TL;DR**

> Enabling *content negotiation* in [Mojolicious][] is extremely easy.

A couple of years ago I wrote about [ordeal][], a simple web application
to help [invent stories][]. The [code is available][], of course.

The web application generates HTML pages, which are useful for
*immediate consumption*. I was playing with the idea to transform it
into a webservice, i.e. serve JSON answers for programs.

This is the whole modification I had to introduce:

```perl
diff --git a/app b/app
index 7915482..abecba8 100755
--- a/app
+++ b/app
@@ -55,10 +55,13 @@ get '/e' => sub ($c) {
    return $err
      ? $c->redirect_to(
       $c->url_for('emod')->query(expression => $expr, error => 1))
-     : $c->render(
-      template   => 'expression',
-      cards      => \@cards,
-      expression => $expr,
+     : $c->respond_to(
+         html => {
+            template   => 'expression',
+            cards      => \@cards,
+            expression => $expr,
+         },
+         json => {json => {cards => \@cards, expression => $expr}},
      );
 };
```

So, instead of the previous call to `render`:

```perl
$c->render(
   template   => 'expression',
   cards      => \@cards,
   expression => $expr,
);
```

we now have a call to `respond_to`, providing the alternatives to use in
`render` depending on the specific request from the client:

```perl
$c->respond_to(
   html => {
      template   => 'expression',
      cards      => \@cards,
      expression => $expr,
   },
   json => {json => {cards => \@cards, expression => $expr}},
);
```

The `html` alternative is the same as in the previous call, to preserve
the interface for humans. The `json` alternative takes care to pack a
hash with the `cards` and the `expression` as a JSON file. The first
`json` is for selection by content negotiation, the second one is for
`render` to figure out that JSON encoding is required.

While more *standard* content negotiation usually relies on HTTP headers
(e.g. see [Content negotiation][] as explained in [MDN][]),
[Mojolicious][] makes it easier to the API consumer by also allowing a
`format` parameter in the POST or GET request, like this:

```
$ curl 'https://ordeal.introm.it/e?expression=d6g@1&format=json'
{"cards":[{"id":"d6_green_1_svg","url":"cards\/d6-green\/1.svg"}],"expression":"d6g@1"}
```

Very good!

For all the details, look in the [detailed documentation][].

[invent stories]: https://blog.polettix.it/invent-stories/
[ordeal]: https://ordeal.introm.it/
[code is available]: https://github.com/polettix/ordeal-webapp
[Content negotiation]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation
[MDN]: https://developer.mozilla.org/en-US/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[detailed documentation]: https://mojolicious.org/perldoc/Mojolicious/Guides/Rendering#Content-negotiation
