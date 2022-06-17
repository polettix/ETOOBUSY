---
title: 'The Foo::Bar mystery in Strawberry Perl'
type: post
tags: [ perl, windows ]
comment: true
date: 2022-06-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> There is (was?) something weird going on with package `Foo::Bar` in
> [Strawberry Perl][].

When I put [App::Easer trial release 2.001][trial1] in CPAN, I was
surprised to see *three failures* in three releases of [Strawberry
Perl][].

Looking at the test reports, it seems that the tests expected to find an
example `Foo::Bar` package containing a sub-command, but it was not
supporting the `new` method to instantiate it.

In [App::Easer][] V2 terms with the old test, this means that
`Foo::Bar`package was actually in scope, but did not support a `new`
method. Only... I did not put it there.

This seems to be confirmed by the fact that I've since changed the
package prefix to `Foo::SubCmd` instead of plain `Foo::`, and tests now
work like a charm (see [this][trial2]).

So the only conclusion that I can draw is that [Strawberry Perl][]
installations that participate in CPAN::Testers actually come with some
`Foo::Bar` package, which messed up my tests. My next step will be to
try and install [Strawberry Perl][] and see what's going on - unless
some wise person can tell me what's going on!

Stay safe and... cheers!

[Perl]: https://www.perl.org/
[trial1]: http://matrix.cpantesters.org/?dist=App-Easer%202.001-TRIAL
[trial2]: http://matrix.cpantesters.org/?dist=App-Easer%202.001001-TRIAL
[Strawberry Perl]: https://strawberryperl.com/
[App::Easer]: https://metacpan.org/pod/App::Easer
