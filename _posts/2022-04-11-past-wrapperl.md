---
title: 'Wrapperl, from the past'
type: post
tags: [ perl ]
comment: true
date: 2022-04-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I was reminded of [wrapperl][].

Some years ago I had pretty much the same problems as today about
messing up with `@INC` *properly*. At the time I was usually interested
into compiling my own [Perl][], which today I mostly don't do,
leveraging system `perl` with custom libraries kept in `local`.

In [Using ongoing developed libraries][] I tried to elaborate a bit on
the pain points I have today, which to some extent overlap with those at
the time. So, *techinically speaking*, that solution should work today
as well. It's called [wrapperl][] and I thank a gentle commenter for
letting me remember about it.

I eventually stopped using it because the whole [Docker][] distribution
model made it somehow obsolete. Additionally, I probably prefer
something more DWIMmy, like directories are inferred from a few hints
and presence/absence of directories, instead of being strictly
configured (which, of course, has its own merits).

Anyway, I see that I did put some love in documenting [wrapperl][], so
you might be interested into taking a look if you share a similar need.

Stay safe!

[Using ongoing developed libraries]: {{ '/2022/04/10/using-ongoing-libs/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[wrapperl]: https://wrapperl.polettix.it./
[gw]: https://github.com/polettix/wrapperl
[Docker]: https://www.docker.com/
