---
title: 'App::Easer priorities in options collection'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-05-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I settled on a design for giving priorities during option values
> collection in `App::Easer` V2.

After the initial thoughts expressed in [App::Easer options
collection][prev], this is the design I adopted (text coming straight
from the to-be documentation, just for sake of laziness):

> Each source can be set either as a `$locator` string or as an array
> reference with the following structure:
>
>     [ $locator, @args ]
>
> The `$locator` can be a reference to a sub, which is used as the source
> itself, or a string that allows getting the source sub to handle the
> specific source. Strings starting with the `+` character are reserved for
> sources provided by `App::Easer::V2` out of the box.
>
> If `$locator` is a plain string, it is possible to set the priority directly
> inside it with `=NN` (e.g. `+Default=100`). It's not necessary to set the
> priority; if missing, it will be assumed to be 10 more than the previous
> one (with the first item starting at 10).
>
> The `@args` part can provide additional arguments to the specific source;
> its applicability is dependent on the source itself. As the only
> exception, if the first item of `@args` is a hash reference, it will be
> removed from the array and used to gather additional meta-options used
> directly by `App::Easer`. At the moment, this is an alternative way to set
> the priority of the specific source using the key `priority`. This means
> that the following examples are equivalent:
>
>     # priority in source name, like anywhere else
>     [ '+FromTrail=90', qw< defaults foo baz > ],
>
>     # priority in meta-options first-arguments hash reference
>     [ '+FromTrail', {priority => 90}, qw< defaults foo baz > ],
>
> It's not necessary to set the `sources` explicitly, as by default the
> following configuration is assumed:
>
>     +CmdLine +Environment +Parent=70 +Default=100
>
> where the respective priorities are, in order, 10, 20, 70, and 100.

Next in line will be the design of some *rational* way to test the
alternatives and cases that can arise... wish me luck! Or time! Or will!

Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[prev]: {{ '/2022/04/28/app-easer-options-collections/' | prepend: site.baseurl }}
