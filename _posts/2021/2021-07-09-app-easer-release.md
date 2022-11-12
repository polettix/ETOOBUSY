---
title: 'App::Easer released on CPAN'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2021-07-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [App::Easer][] is now on [CPAN][].

So I eventually wrote some additional documentation for [App-Easer][],
added a fair number of tests and eventually released it on CPAN. It's
available as [App::Easer][].

And, of course, the first release didn't *exactly* go well: I got a lot
of pushback from CPAN Testers. They were right, of course, because I
forgot to indicate a couple of testing modules as required to do the
testing (I had them as requirements for development). No big deal
though, [Milla][] is extemely friendly.

As indicated in the module, it's still something that should be
considered *alpha*. I mean, it works and does a lot of things, and it's
probably also supposed to be *bundled* with the actual application code,
so there should be no big problems in some interface changing here and
there. Moreover, so few people use my stuff that I'm solving an
inexistent problem 😂

In particular I'm pondering on making configuration `auto-leaves` as a
true value by default, so that a command is considered a leaf unless
there's an explicit indication that it has children. We'll see.

In the meantime... stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[CPAN]: https://metacpan.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[App-Easer]: https://github.com/polettix/App-Easer
[Milla]: https://metacpan.org/pod/Dist::Milla
