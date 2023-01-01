---
title: 'App::Easer - more tests for V2'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-03-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Moving on with tests in [App::Easer][] V2.

I finally restarted porting tests from V1 to V2 in [App::Easer][]. While
I'm already using V2 from the repository now, I'm not really comfortable
in releasing it without having a similar level of testing in V2 as it's
already available in V1.

Most of the structure of the tests is just moved on from V1, although
there's been some interface changing that needs to be fixed (V2 was
never meant to be a drop-in replacement). So it requires... work.

Anyway, I'm pretty happy that I've added four more test files in the
last day:

![Four more tests]({{ '/assets/images/app-easer-v2-more-tests.01.png' | prepend: site.baseurl }})

Stay safe folks!

[Perl]: https://www.perl.org/
[App::Easer]: https://github.com/polettix/App-Easer
