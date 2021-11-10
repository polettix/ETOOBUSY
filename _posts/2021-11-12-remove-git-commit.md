---
title: Removing a Git commit
type: post
tags: [ git ]
comment: true
date: 2021-11-12 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Obliterating a Git commit][] is gold.

From it:

> Sometimes you accidentally commit a change to a Git repository and you
> later want to literally obliterate (remove all traces) of it.

This happened to me a few days ago. I added and committed a few
not-so-light files in the repository, only to figure out that they were
duplicates a little after.

[That post][Obliterating a Git commit] hit the nail right in the head.

By default (for me, at least!) [Git][] repository have a reflog, so this
is how the *obliteration* should work (blatantly copying from the
original post, for sake of quick preservation):

```
# blow away last commit
git reset --hard HEAD^

# if you were on main branch, for example, kill that reflog
rm .git/logs/refs/heads/main

# and the HEAD reflog as well
rm .git/logs/HEAD

# now git-prune will get rid of everything you don't want
git prune

# do a repack for good measure, then garbage collect
git repack -a -d
git gc
```

Thanks, [Obliterating a Git commit][]!

[Obliterating a Git commit]: https://wincent.com/wiki/Obliterating_a_Git_commit
[Git]: https://git-scm.com/
