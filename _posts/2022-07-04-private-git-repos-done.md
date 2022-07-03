---
title: Private git repos (settled!)
type: post
tags: [ git, gitolite ]
comment: true
date: 2022-07-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I eventually settled on using [Gitolite][].

After [thinking a bit about private git repos][ppost], I eventually
settled on using [Gitolite][] in an ad-hoc user.

Fiddling with 2FA seemed a bit brittle, also considering my level of
knowledge of all the different shadings (read: level zero). As I said,
the solution with a different user allowed me to adopt an already
established solution for restricting access to [Git][] operations only.

After a few months, I must say that it's been easy to use [Gitolite][].
I mostly copied from my past work, and reading the [page about
permissions][] was easy and interesting.

Cheers!

[Perl]: https://www.perl.org/
[ppost]: {{ '/2022/07/03/private-git-repos/' | prepend: site.baseurl }}
[Gitolite]: {{ '/2022/02/19/gitolite/' | prepend: site.baseurl }}
[Git]: https://www.git-scm.com/
[page about permissions]: https://gitolite.com/gitolite/conf-2
