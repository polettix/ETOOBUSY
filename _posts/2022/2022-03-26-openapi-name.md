---
title: OpenAPI with Mojolicious - using name for default_response
type: post
tags: [ perl, web, mojolicious ]
comment: true
date: 2022-03-26 20:30:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Using `name` for `default_response` in
> [Mojolicious::Plugin::OpenAPI][].

I know this sounds criptic... let's go in order. As you might remember,
I'm trying some [Perl OpenAPI with Mojolicious][].

I was trying to use something along the lines of the following
specification:

```yaml
openapi: 3.0.0
info:
  title: Example Web API
  version: 0.0.1
  description: PoC definition
components:
  schemas:
    base:
      type: object
      properties:
        status:
          type: integer
    exception:
      type: object
      allOf:
        - $ref: '#/components/schemas/base'
        - type: object
          required: [ reason ]
          properties:
            reason:
              type: string
paths:
  /item/{id}:
    get:
      x-mojo-name: item
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/base'
```

The goal of defining `#/components/schemas/exception` is to use it as
the schema for... *exceptions*, using the handy `default_response`
capability conveniently provided by [Mojolicious::Plugin::OpenAPI][].

The way I found to do this was a bit hacky: load the specification as a
[Perl][] data structure and then use `schema` to refer to it, like this:

```perl
...
my $spec = YAML::LoadFile('api-spec.yaml');
plugin OpenAPI => {
   url => 'api-spec.yaml',
   default_response => {
      schema => $spec->{components}{schemas}{response_error},
...
```

It's *hacky* because the specification is loaded twice... but no problem
for me!

Fact is that this arrangement does *not* work because in this way the
code expects that the provided `schema` is *self-contained*, and in my
example the schema for `exception` isn't (it references
`#/components/schemas/base` in the `allOf` section). [Ouch][].

But fear not, [module author to the rescue][issue-answer]! With this
suggestion that is **slightly redacted to match the example above**:

> Another solution \[...\] is to simply load the plugin with `name`
> instead of `schema`:
>
>     plugin OpenAPI => {default_response => {name => 'exception'}, ...};

Well... let's try it:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use Mojolicious::Lite -signatures;
use Mojo::JSON 'encode_json';

get "/item/:id" => sub ($c) {
   $c->openapi->valid_input or return;
   my $id = $c->param('id');
   if ($id == 404) {
      $c->render(
         status  => 404,
         openapi => {status => 404, reason => 'Not Found'},
      );
   } ## end if ($c->param('id') > ...)
   elsif ($id == 500) {
      $c->render(
         status  => 500,
         openapi => {status => 500, reason => 'Internal Server Error'},
      );
   } ## end if ($c->param('id') > ...)
   else {
      $c->render(
         status  => 200,
         openapi => {status => 200},
      );
   } ## end else [ if ($c->param('id') > ...)]
  },
  'item';


plugin OpenAPI => {
   url => "data:///api.yaml",
   default_response => { name => 'exception', },
   renderer => sub ($c, $data) {
      $c->res->headers->content_type('application/json');
      return encode_json($data);
   },
};
app->start;

__DATA__
@@ api.yaml
openapi: 3.0.0
info:
  title: Example Web API
  version: 0.0.1
  description: PoC definition
components:
  schemas:
    base:
      type: object
      properties:
        status:
          type: integer
    exception:
      type: object
      allOf:
        - $ref: '#/components/schemas/base'
        - type: object
          required: [ reason ]
          properties:
            reason:
              type: string
paths:
  /item/{id}:
    get:
      x-mojo-name: item
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/base'
```

It works, yay!

I thought that `name` as a way to give a name to some section that would
be added to the definition (and it is, when `schema` is provided), but I
didn't think to short-circuit the whole thing and use *something that is
already in the specification*!

Thanks [Jan Henning Thorsen][jhthorsen]!

[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Mojolicious::Plugin::OpenAPI]: https://metacpan.org/pod/Mojolicious::Plugin::OpenAPI
[OpenAPI]: https://www.openapis.org/
[Response reference ignored and overridden by DefaultResponse]: https://github.com/jhthorsen/mojolicious-plugin-openapi/issues/226
[GitHub repository]: https://github.com/jhthorsen/mojolicious-plugin-openapi/
[Swagger Editor]: https://editor.swagger.io/
[module authors]: https://metacpan.org/pod/Mojolicious::Plugin::OpenAPI#AUTHORS
[Ouch]: https://metacpan.org/pod/Ouch
[issue-answer]: https://github.com/jhthorsen/mojolicious-plugin-openapi/issues/235#issuecomment-1079616122
[Perl OpenAPI with Mojolicious]: {{ '/2021/11/08/perl-openapi/' | prepend: site.baseurl }}
[jhthorsen]: https://github.com/jhthorsen
