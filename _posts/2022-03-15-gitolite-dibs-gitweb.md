---
title: 'Gitolite image - Gitweb'
type: post
tags: [ gitolite, git, perl, gitweb ]
comment: true
date: 2022-03-15 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added [Gitweb][] to the [gitolite-dibs][] image.

After starting [Gitolite - a dibs repository][] (available at
[gitolite-dibs][]) and using it a bit, *of course* I also wanted some
minimal web access to the repositories.

I know... *just use [Gitea][]!* Well no, we're still experimenting and
I'm having fun! So I added [Gitweb][] to the image.

It turns also out that a lot of the appearance of the website can be
customized... so I found about [gitweb-theme][], which I like very much
and I included it inside the image.

Enough for today... say safe!

[Perl]: https://www.perl.org/
[Gitolite]: https://gitolite.com/gitolite/
[Docker]: https://www.docker.com/
[Kubernetes]: https://kubernetes.io/
[dibs]: https://github.com/polettix/dibs
[Helm]: https://helm.sh/
[Gitolite - a dibs repository]: {{ '/2022/02/21/gitolite-dibs/' | prepend: site.baseurl }}
[gitolite-dibs]: https://gitlab.com/polettix/gitolite-dibs
[Gitweb]: https://git-scm.com/docs/gitweb
[Gitea]: https://gitea.io/
[gitweb-theme]: https://github.com/kogakure/gitweb-theme
