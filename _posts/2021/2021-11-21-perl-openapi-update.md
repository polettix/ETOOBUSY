---
title: 'Perl OpenAPI with Mojolicious - an update!'
type: post
tags: [ perl, mojolicious, openapi, web ]
comment: true
date: 2021-11-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Mojolicious::Plugin::OpenAPI][] was updated to address Issue
> [Response reference ignored and overridden by DefaultResponse][issue],
> yay!

Recent post [Perl OpenAPI with Mojolicious][] gave a very quick overview
on how useful [Mojolicious::Plugin::OpenAPI][] is and pointed out a
small bug regarding error management.

Well... it turned out that the bug was in [JSON::Validator][] instead,
but luckily they are both under the care of [Jan Henning
Thorsen][jhthorsen], who fixed the bug in the module and bumped the
minimum needed version in the other one, so that it will not suffer from
the bug.

Thanks [Jan Henning Thorsen][jhthorsen]!

[Perl OpenAPI with Mojolicious]: {{ '/2021/11/08/perl-openapi/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Mojolicious::Plugin::OpenAPI]: https://metacpan.org/pod/Mojolicious::Plugin::OpenAPI
[JSON::Validator]: https://metacpan.org/pod/JSON::Validator
[jhthorsen]: https://github.com/jhthorsen
[issue]: https://github.com/jhthorsen/mojolicious-plugin-openapi/issues/226
