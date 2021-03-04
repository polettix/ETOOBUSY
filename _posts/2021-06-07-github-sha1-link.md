---
title: GitHub SHA1 Link
type: post
tags: [ github, blog, web ]
comment: true
date: 2021-03-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Use `y` to get a *durable* link to a file in [GitHub][].

When I write a blog post about some software of mine, I often include
links towards a file inside the relevant repository in [GitHub][] with
an explanation of what I did, how, etc.

Fact is that this explanation might be doomed to not age *exactly* well.
What if I later change my mind and implementation? Will the blog post
become stale?

This is even worse when I put a link to a specific line. What if I add
more stuff *before* that line, making it shift down? This will generate
a lot of confusion!

The obvious solution is to put a link to the representation of *that*
file in *that* moment, which in [Git][] terms means referring to a
branch that does not move (so why a branch?), or a tag (better), or as a
specific SHA1 hash.

It turns out that [GitHub][] gets you covered with a little keyboards
shortcut: `y`. When you are on the page for a specific file in a
repository, pressing `y` will automatically change the URL in the
browser's address bar to represent the file in that exact point in time
you are looking at, in SHA1 terms.

At this point, you can push whatever change you want... that URL will
always stay the same and show the file as initially intended. Nifty!

To read more:

- [Getting permanent links to files][]
- [Keyboard shortcuts][]

Stay safe!

[GitHub]: https://github.com/
[Git]: https://www.git-scm.com/
[Getting permanent links to files]: https://docs.github.com/en/github/managing-files-in-a-repository/getting-permanent-links-to-files
[Keyboard shortcuts]: https://docs.github.com/en/github/getting-started-with-github/keyboard-shortcuts
