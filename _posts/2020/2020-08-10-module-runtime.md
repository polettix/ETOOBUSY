---
title: 'Module::Runtime'
type: post
tags: [ perl ]
comment: true
date: 2020-08-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Module::Runtime][] helps you load modules whose name you don't know
> beforehand.

Sometimes you build the name of a module you need dynamically, e.g. if
you have a little plugin system you might have this:

```perl
my $plugin = 'Foo';
my $module_name = 'My::App::' . $plugin;
```

Now you want to load it... which can be done with some text manipulation
and some help from `require`:

```perl
(my $file_name = $module_name . '.pm') =~ s{::}{/}gmxs;
require $file_name;
```
It's a bit hackish and I also guess it misses a lot of corner cases...
you get the idea.

One module to do this (and more, admittedly) is [Module::Runtime][]. I
keep forgetting its name because... well, doing this kind of dynamic
loading is not exactly something that happens too often.

The only function I use is `use_module` to be honest:

```perl
use Module::Runtime 'use_module';
my $plugin = 'Foo';
my $module_name = 'My::App::' . $plugin;
use_module($module_name);
```

It throws an exception (well, a [Perl][]ish one) if the module is not
there to be found... so I guess it's everything we need in 2020 😄

[Module::Runtime]: https://metacpan.org/pod/Module::Runtime
[Perl]: https://www.perl.org/
