---
title: Release time!
type: post
tags: [ perl ]
comment: true
date: 2023-03-11 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm in the middle of a few releases.

I've been somehow *active* lately on CPAN, yay!

[Data::Resolver][] now includes the new object-oriented interface; it's
working, although not entirely *definitive* (as everything), as the
functional interface is still implemented on its own. Plans here are to
re-implement it leveraging the object-oriented one, or to deprecate it away.
Time will tell; in the meantime, this will hopefully spur some activity on
[PDF::Collage][], which is [Data::Resolver][]'s main client.

[Template::Perlish][] is now at version `1.60`. This is one my favourite
modules of mine, because it does what I need exactly the way I want. I can't
believe it's not used by anybody else! Well, I *do believe* it, as there's a
plethora of templating modules in CPAN and I'm not the best at marketing.
Still... good job *past me*, your efforts are quite appreciated here in 2023 😁

Last, thanks to the infaticable [djerius][], a lot of bugs were unearthed
for [App::Easer][] and are now hopefully fixed. I'll wait the usual
roundtrip with [CPAN Testers][] to get some feedback all around the
platforms, then I'll release it; at the moment we're still at the [trial
phase][].

Stay safe!

[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
[App::Easer]: https://metacpan.org/pod/App::Easer
[djerius]: https://github.com/djerius
[CPAN Testers]: https://cpantesters.org/
[trial phase]: https://metacpan.org/release/POLETTIX/App-Easer-2.007-TRIAL
[PDF::Collage]: https://metacpan.org/pod/PDF::Collage
