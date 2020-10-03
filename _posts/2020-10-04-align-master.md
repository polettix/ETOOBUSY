---
title: 'Blog: align master to commit'
type: post
tags: [ blog, git ]
comment: true
date: 2020-10-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Saving some typing when dealing with the blog.

From time to time I have to fix some error in a post of the blog, which
can cause some *major* annoyances if I already canned some future post.
Luckily, this is a solved problem ([Rebase and retag, automatically][]).

When I do this, I usually want the changes to appear as soon as
possible, without waiting for the automatic publishing to kick in
(usually the next morning). So I switch temporarily to `master`, align
it to the remote, .... **wait**! Why do **I** do this?

Long story short, when I want to align `master` to a specific commit
(which is `devel` by default), I use this:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2021674.js"></script>

This [script][] is also available in the [repository][].

Aaaaaand... some typing is saved for greater good!

[Rebase and retag, automatically]: {{ '/2020/06/12/rebase-auto-retag' | prepend: site.baseurl }}
[script]: https://github.com/polettix/ETOOBUSY/blob/master/c2master.sh
[repository]: https://github.com/polettix/ETOOBUSY/
