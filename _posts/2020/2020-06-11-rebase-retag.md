---
title: Rebase and retag
type: post
tags: [ git, blog, tag, rebase ]
comment: true
date: 2020-06-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Sometimes I need to rebase and move tags too. I'm talking of [Git][],
> of course.

If you have been bor**COUGH**following this blog, you might have noticed
that I started from a very basic configuration ([Jekyll blog on GitHub
Pages][]) to allowing for scheduled publishing and notifications
(respectively [ETOOBUSY automated publishing][] and [Notifications for
busypub][]). What I *still* like about it is that it's all
*incremental*: you can still just fiddle with the blog in [GitHub][]
and, in case, *temporarily* lose some of the automations.

But I'm digressing 🙄


# A glimpse on busypub way of working

The [busypub][ETOOBUSY automated publishing] system allows me to prepare
a few posts beforehand in a *private* repository, and then push them
over to the public one at the right time. The right commit to *move*
from the *devel* branch to the *master* branch is detected through a tag
that carries the date for publishing, like in the following example:

```text
├─[2020-06-04]──New post: setting env vars in Dokku──(8595329)
├─[2020-06-05]──New post: Timezone notes──(d91dbd5)
├─[2020-06-06]──New post: busypub publishing time──(e2ca970)
├ Upgrade github-related stuff for Jekyll──(ec97a89)
├ Add link to genehack's article──(adb9efa)
├─[2020-06-07]──New post: Black lives matter──(ccb44e4)
├─[master]──[remotes/origin/HEAD]──[remotes/origin/master]──[2020-06-08]──New post: Some CC0 images──(3a57f22)
├─[2020-06-09]──New post: pgal──(1a253a3)
└─[HEAD]──[devel]──[remotes/gitlab/devel]──[2020-06-10]──New post: Path::Tiny──(bbf3baa)
```

Note that:

- the *master* branch is at the same spot as tag `2020-06-08`
- the *devel* branch is a direct descendant of *master*
- the *devel* branch contains two additional tags for the following
  posts to be published.


The second bullet deals with a restriction I put explicitly: no
*complicated* merges, i.e. only fast-forwards are allowed. This allows
me to be sure that there will be absolutely *no* issue in the merge, i.e
no conflict at all.

# Patching

This simplicity in merges comes at a cost, though. When a post is
published, I might notice a typo, or a bug, or have the need to add
something afterwards. Here, I have two choices:

- either I introduce the patch in the *devel* branch, where I'm staying
  at the moment, and it will *eventually* be included. Here, the more I
  move forward in writing, the higher lagging I'll have to endure;
- or I make the change on the *master* branch, bumping the *devel*
  branch out of *master*'s future.

All in all, it's a matter of what I have at the moment (more or less
posts already scheduled) and how annoyed I am at delaying the bugfix.
Oh, of course... I'm also lazy.

Choosing the second option means that I have to do a `git rebase` of the
*devel* branch to put it *back to the future* of *master*. It is
normally as easy as:

```shell
git checkout devel
git rebase master
```

If it was *just* a typo fix, it will not have conflicts and things will
proceed smoothly.

Or will they?

Let's add a commit to *master* to show what goes on:

```text
├─[2020-06-07]──New post: Black lives matter──(ccb44e4)
├─[remotes/origin/HEAD]──[remotes/origin/master]──[2020-06-08]──New post: Some CC0 images──(3a57f22)
├─╮
│ ├─[2020-06-09]──New post: pgal──(1a253a3)
│ └─[HEAD]──[devel]──[remotes/gitlab/devel]──[2020-06-10]──New post: Path::Tiny──(bbf3baa)
└─[master]──A patch on fakemaster!──(81c614e)
```

Now let's do the rebasing:

```text
$ git checkout devel
$ git rebase master
First, rewinding head to replay your work on top of it...
Applying: New post: pgal
Applying: New post: Path::Tiny
#...
├─[2020-06-07]──New post: Black lives matter──(ccb44e4)
├─[remotes/origin/HEAD]──[remotes/origin/master]──[2020-06-08]──New post: Some CC0 images──(3a57f22)
├─╮
│ ├─[2020-06-09]──New post: pgal──(1a253a3)
│ └─[remotes/gitlab/devel]──[2020-06-10]──New post: Path::Tiny──(bbf3baa)
├─[master]──A patch on fakemaster!──(81c614e)
├ New post: pgal──(53c54c7)
└─[HEAD]──[devel]──New post: Path::Tiny──(0293a13)
```

As expected, the rebase was successful and gave no trouble. But... the
publishing tags are still bound to the older commits! This will not work
with the automated publishing... ouch! 🤭

# Move the tags, then!

Moving tags in a [Git][] repository is generally *not* a good idea. They
*should* be written in the stone, marking conditions that you decide to
*freeze*. If you change them, chaos can arise, especially if you publish
your tags and others get them.

In this case, anyway, I'm sort of abusing them to flag stuff in the
future, which is bound to change. Additionally, changing tags is not a
big deal, because the blog is a standalone project and it's not likely
to confuse anyone. For this reasons, doing this would be OK:

```shell
# first, move the relevant tags
git tag -f 2020-06-09 53c54c7   # new id of 'New post: pgal'
git tag -f 2020-06-10 0293a13   # new id of 'New post: Path::Tiny'

# now push the tags to the remote private repository
git push -f private-repository 2020-06-09 2020-06-10
```

# Time's up

Well, it works and allows me to introduce patches quickly while still
preserving the automatic publishing system.

Am I happy about it? Totally not! The computer should do the tags
moving! If I fiddle with it, I'm bound to mess it up!

So... stay tuned 😄

[Git]: https://www.git-scm.com/
[Jekyll blog on GitHub Pages]: {{ '/2019/09/29/jekyll-ghp/' | prepend: site.baseurl }}
[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub/'  | prepend: site.baseurl }}
[Notifications for busypub]: {{ '/2020/06/02/busypub-notifications/' | prepend: site.baseurl }}
[GitHub]: https://github.com/
