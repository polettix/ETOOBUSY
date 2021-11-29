---
title: 'Feature creeping in App::Easer'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2021-11-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added a feature into [App::Easer][].

Well, it *had* to happen.

Just after I resolved to start writing a tutorial for [App::Easer][]
(most probably in [Markdown][], [remember][]?), I thought that it would
be nice to let users also split their application into sub-modules.

I know... *that's what [App::Cmd][] is for, isn't it?!?*

Well, yes and no. I still stand by my considerations laid out in past
post [App::Easer][post]: I don't particularly like how things *MUST* be
structured, and there's a hell lot of dependencies.

The approach here is more [Mojolicious][]-like: you can start with
something very limited and self-contained, with the option to grow and
divide (part of the) stuff into modules as you go and like it.

So... I did it. The gist of it is in the new test
[15-spec-from-hash-or-mod.t][]: set `specfetch` to
[`+SpecFromHashOrModule`][sf], and modules will be searched in addition
to sub-keys inside the `commands` hash in the application specification:

```
my $app = {
   configuration => {
      'auto-leaves' => 1,
      specfetch => '+SpecFromHashOrModule',
      ...
```

This means later that this list of children:

```
children => [qw< Foo bar >]
```

will trigger looking for `Foo::spec`, i.e. a `spec` function living in
module `Foo`:

```
package Foo;
sub spec {
   return {
      help        => 'sub-command foo',
      description => 'first-level sub-command foo',
      supports    => ['foo', 'Foo'],
      options     => [
         {
            getopt => 'hey|h=s',
         },
      ],
      children        => ['Baz'],
      'default-child' => 'Baz',
   };
}
```

The same applies to `Baz` here.

There's no urge to call this `spec`, because the usual mechanism for
*executables* is used, so this would do what you think:

```
children => [qw< Galook#the_specification_sub >]
```

It's higly probably that some additional testing can help, we will see.
In the meantime... stay safe!


[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[remember]: {{ '/2021/11/29/tutorials-for-modules/' | prepend: site.baseurl }}
[Markdown]: https://daringfireball.net/projects/markdown/
[App::Cmd]: https://metacpan.org/pod/App::Cmd
[post]: {{ '/2021/07/03/app-easer/' | prepend: site.baseurl }}
[15-spec-from-hash-or-mod.t]: https://github.com/polettix/App-Easer/blob/f25a8d349d7ca2660957fbfef11e2fa2e2a1a870/t/15-spec-from-hash-or-mod.t
[sf]: https://github.com/polettix/App-Easer/blob/f25a8d349d7ca2660957fbfef11e2fa2e2a1a870/t/15-spec-from-hash-or-mod.t#L11
[Mojolicious]: https://metacpan.org/pod/Mojolicious
