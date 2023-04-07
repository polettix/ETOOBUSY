---
title: CPAN Testers rock!
type: post
tags: [ perl ]
comment: true
date: 2023-03-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [CPAN Testers][] rock!

As I [already mentioned][post], [CPAN Testers][] rock.

In this case, it spotted an error in a test of mine, where I was
assuming that module [Ouch][] would always be present, while in the code
I was allowing for it to be missing.

Unfortunately I had some troubles accessing their website lately, both
for single reports and the more general pages, despite the service being
marked as *green MANAGEABLE* (I can't understand what it means in its
full extent, probably). This extends to the help pages, unfortunately,
where I was looking for some info about how to help out.

I hope the access issues are restricted and... a big thank you to [CPAN
Testers][]!!!


[Perl]: https://www.perl.org/
[post]: {{ '/2022/01/18/data-tubes-release/' | prepend: site.baseurl }}
[CPAN Testers]: https://cpantesters.org/
[Ouch]: https://metacpan.org/pod/Ouch
