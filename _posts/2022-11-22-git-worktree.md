---
title: Git worktree
type: post
tags: [ git ]
comment: true
date: 2022-11-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [git worktree][] rocks.

I was *so sure* I had already written about this that I went looking for
this post. Except that I had **not** already done that, so I found
nothing.

So... [git worktree][]. Much like sliced bread.

The main selling point is: keep multiple working directories out of a
single repository, so that we can work on them in parallel.

Many people praise this for being able to quickly work on a critical fix
in a branch without having to mess with their current working directory.
The stuff that was mainly addressed with `git stash` up to some time
ago, except that now it seems everybody secretly hated that.

For starters, I think that `git stash` is cool. Maybe outdated by
multiple working trees, but still cool.

Second, I'm the main consumer of my stuff. OK, the **only** consumer of
my stuff. So I don't have this urge to fix stuff in older branches and
save the day. But still [git worktree][] is *extremely* useful.

Consider, for example, [Codeberg Pages][]. Many times we keep *sources*
for a static generator in the `main` branch, while the published stuff
lives in the `pages` branch. So... why not have *both* checked out at
the same time?

Keeping in mind that we can only checkout a branch only once (i.e. we
can't have to separate working directories for e.g. branch `main`), we
can do as little as:

```
git worktree add somepath somebranch
```

As an example, in a [Jekyll][] project hosted in [Codeberg Pages][] we
might do the following:

```
rm -rf _site
git worktree add _site pages
```

Now every time we regenerate the site locally, the changes get directly
inside the working directory aligned with the `pages` branch. When we're
ready... we can just go into that working directory, commit and push:

```
cd _site
git add .
git commit -m 'Regenerate site'
git push
```

Nifty!

Stay safe folks!

[git worktree]: https://git-scm.com/docs/git-worktree
[Codeberg Pages]: {{ '/2022/07/09/codeberg-pages/' | prepend: site.baseurl }}
[Jekyll]: https://jekyllrb.com/
