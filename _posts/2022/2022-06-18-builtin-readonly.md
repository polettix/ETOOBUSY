---
title: 'A builtin::readonly?'
type: post
tags: [ perl ]
comment: true
date: 2022-06-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Wondering whether `builtin::readonly` will ever appear.

Today I was looking at the [changes in Perl v5.36][] and I was somehow
surprised that there's no `builtin::readonly`.

I know there's no `readonly` elsewhere in CORE, so it's definitely
different from e.g. `refaddr` and `blessed` (which, by the way, is very
good to have at hand and avoid the *go to the beginning, import
`Scalar::Util`, go back to the place* that lost me about 60 seconds of
overall programmer life), but I'd argue that `true` and `false` aren't
either, at least that I know of.

I also know that I should probably use read-only variables more, because
I'm getting older and memory might start failing me any time soon.

Last, I know that... *wait, what was I talking about?*

Oh, yes, read-only variables. Well, I guess we will stick with
[Readonly::Tiny][] for some time more. Luckily there's [a post about
it][post].

Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[changes in Perl v5.36]: https://metacpan.org/release/RJBS/perl-5.36.0/view/pod/perldelta.pod
[Readonly::Tiny]: https://metacpan.org/pod/Readonly::Tiny
[post]: {{ '/2021/04/09/readonly-tiny/' | prepend: site.baseurl }}
