---
title: Git sparse-checkout caveats
type: post
tags: [ git ]
comment: true
date: 2023-06-10 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [`git sparse-checkout`][gsc] can have some surprises for future me.

Some time ago I wrote about [`git sparse-checkout`][gsc] in [Light Git
repository checkout][]. It's been nice to discover this sub-command and I'm
not regretting it.

As [The Weekly Challenge][] goes on, though, I gradually *include* more
directories and I eventually decide to *prune* some of the older ones (in
addition to the much older ones I was already ignoring). Which got me in a
little rabbit hole.

First thing, the command has an `add` sub-command, but no `remove`. There
seem to be good reasons for this, so I looked around and found a solution
where you edit the `$GIT_DIR/info/sparse-checkout` file manually, remove the
directories manually, then run a low-level `git` command to make it happy
again.

Ugh.

After doing this, because I was in a hurry, I started wondering about a
*better* solution. Which I found pretty quickly: after the manual editing of
the `$GIT_DIR/info/sparse-checkout` file (which is needed for `git
spare-checkout` reasons, anyway), it suffices to run the `reapply`
sub-command and the tool will do what's needed, Much cleaner.

Then I got a bit into the documentation, which at the moment is for [`git
sparse-checkout` in release 2.41.0][gsc241], and *oh boy this is scaring* (I
put some parts in bold to add emphasis):

> When changing the sparse-checkout patterns in cone mode, Git will inspect
> each tracked directory that is not within the sparse-checkout cone to see
> if it contains any untracked files. **If all of those files are ignored
> due to the .gitignore patterns, then the directory will be deleted**. If
> any of the untracked files within that directory is not ignored, then no
> deletions will occur within that directory and a warning message will
> appear. If these files are important, then reset your sparse-checkout
> definition so they are included, use git add and git commit to store them,
> then remove any remaining files manually to ensure Git can behave
> optimally.

I frequently have ignored files around, not because they're not important
but mostly because they don't belong to the repository. So... *what?*

I did some tests with my version 2.30.2 and... *nope* this is not what I
saw! Back to the docs, its seems that the passage above was added *some time
later*, so this is a fantastic little bomb waiting to explode for me when I
will eventually land on an updated version of git some time in the future.

*Good luck, future me!*

[gsc]: https://www.git-scm.com/docs/git-sparse-checkout/
[gsc241]: https://www.git-scm.com/docs/git-sparse-checkout/2.41.0
[Light Git repository checkout]: {{ '/2022/10/26/light-git-pwc/' | prepend: site.baseurl }}
[The Weekly Challenge]: https://theweeklychallenge.org/
