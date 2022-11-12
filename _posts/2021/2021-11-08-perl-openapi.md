---
title: Perl OpenAPI with Mojolicious
type: post
tags: [ perl, web, mojolicious ]
comment: true
date: 2021-11-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Using [OpenAPI][] in [Perl][] will hopefully be fun with
> [Mojolicious::Plugin::OpenAPI][].

The module seems to provide what's needed to parse an
[OpenAPI][]-compatible definition and provide routes definition as well
as validation.

Using [OpenAPI][] tends to be on the verbose side, which might be
intimidating but it's for... *a good cause* (documentation and openness)
and in addition it's a sort of one-time effort. On the other hand... I
hope what comes out will not be hard to maintain.

I hit a small roadblock while trying to define my custom `responses`,
which resulted in Issue [Response reference ignored and overridden by
DefaultResponse][] in the [GitHub repository][]. I hope I managed to
clearly explain my problem, for the moment I adopted a work-around.

I used the [Swagger Editor][] so far and it seems to work fine, apart
that it's not possible to split stuff into multiple files *easily*.
Again... let's see, maybe I'll switch to something different.

I guess it's enough pointers for today... thanks to the [module
authors][] and stay safe everyone!



[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Mojolicious::Plugin::OpenAPI]: https://metacpan.org/pod/Mojolicious::Plugin::OpenAPI
[OpenAPI]: https://www.openapis.org/
[Response reference ignored and overridden by DefaultResponse]: https://github.com/jhthorsen/mojolicious-plugin-openapi/issues/226
[GitHub repository]: https://github.com/jhthorsen/mojolicious-plugin-openapi/
[Swagger Editor]: https://editor.swagger.io/
[module authors]: https://metacpan.org/pod/Mojolicious::Plugin::OpenAPI#AUTHORS
