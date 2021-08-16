---
title: 'Template::Perlish enhancement'
type: post
tags: [ perl ]
comment: true
date: 2021-08-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An enhancement (bugfix!) of [Template::Perlish][].

So it happens that releasing the [trial][] for [App::Easer][] there was
something wrong:

![weird characters in POD]({{ '/assets/images/20210817-weird-pod.png' | prepend: site.baseurl }})

Those question marks should be opening `«` and closing `»`!

Long story short, [Template::Perlish][] is to blame. It actually tries
to do the right thing by assuming that utf8 is as good a default as
anyting else, with a few advantages that are out of sight here, hence
the error.

This prompted... [Template::Perlish trial release][ntrial], then! Now
the `utf8` option is documented, as well option `binmode` that has been
added in the implementation (which, in turn, inhibits the automatic true
value for option `utf8`).

Keep safe and enjoy everyone!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
[trial]: https://metacpan.org/release/POLETTIX/App-Easer-0.003-TRIAL
[App::Easer]: https://metacpan.org/pod/App::Easer
[ntrial]: https://metacpan.org/release/POLETTIX/Template-Perlish-1.55-TRIAL
