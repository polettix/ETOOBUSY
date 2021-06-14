---
title: The real PAUSE workaround
type: post
tags: [ perl, cpan ]
comment: true
date: 2021-06-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The *real* [PAUSE workaround][].

After my post [PAUSE workaround][], where I tell a little story of how I
tripped onto [PAUSE][]'s indexer and how I worked that around in a terrible
(although admittedly effective) way, [Joel Berger][] gently pointed me to the
*real* way of addressing that problem:

> I think you can use this
> [https://metacpan.org/pod/CPAN::Meta::Spec#no_index](https://metacpan.org/pod/CPAN::Meta::Spec#no_index)
> to tell PAUSE to ignore the offending package

And, of course, Joel is 100% right.

The *last mile* (why is there always a last mile?!?) was to figure out how to
set it up in [Dist::Zilla][]/[Milla][]. Luckily, this was easy thanks to
[Dist::Zilla::Plugin::MetaNoIndex][]:

```
[MetaNoIndex]
package = CPAN::Modulelist
```

So I reverted the change to the module, used the plugin... and it works!

Thanks [Joel Berger][] 😄

[PAUSE workaround]: {{ '/2021/06/14/pause-workaround' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[PAUSE]: https://pause.perl.org/
[CPAN]: https://metacpan.org/
[Joel Berger]: https://jberger.github.io/
[Dist::Zilla]: https://metacpan.org/pod/Dist::Zilla
[Milla]: https://metacpan.org/pod/Milla
[Dist::Zilla::Plugin::MetaNoIndex]: https://metacpan.org/pod/Dist::Zilla::Plugin::MetaNoIndex
