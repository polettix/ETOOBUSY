---
title: 'WebService::Fake update'
type: post
tags: [ perl, cpan, mojolicious ]
comment: true
date: 2021-03-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [WebService::Fake][] is being updated due to changes in
> [Mojolicious][].

It so happens that [Mojolicious][] has its deprecation cycle *and* that
sometimes it can hit you. It also happens that awesome people [tell you
about it][issue-5] but you don't get it the first time 🙄

No worries: changes are included in the [Upgrading][] page.

In my case, the *barely-above-code-noise* module [WebService::Fake][]
was hit by the [Routing methods cleanup][]; the instructions on what to
change are clear, and they will hopefully also prove effective. Only
time will tell!

For now, [release 0.005-TRIAL][trial] has been uploaded to [CPAN][] to
see if anything else broke on the way. If not... I'll release more noise
in the coming days.

[WebService::Fake]: https://metacpan.org/pod/WebService::Fake
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Upgrading]: https://github.com/mojolicious/mojo/wiki/Upgrading
[Routing methods cleanup]: https://github.com/mojolicious/mojo/wiki/Upgrading#routing-methods-cleanup
[trial]: https://metacpan.org/pod/release/POLETTIX/WebService-Fake-0.005-TRIAL/lib/WebService/Fake.pod
[CPAN]: https://metacpan.org/
[issue-5]: https://github.com/polettix/WebService-Fake/issues/5
