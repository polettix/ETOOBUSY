---
title: Rebase and retag, but manually
type: post
tags: [ git, blog, tag, rebase, coding ]
comment: true
date: 2020-06-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Moving tags manually sucks. [Git][] hooks help.

In previous post [Rebase and retag][], we saw that doing post patching
on the spot (i.e. in the *master* branch, which is also the published
one) is a bit at odds with the automatic publishing system
(as described by [ETOOBUSY automated publishing]). 

We also saw that, if there is a need for quick patching a post, the best
option is to apply the patch on the *master* branch and then rebase the
*devel* branch onto it, and then move all date-shaped tags onto the
newly created commits (matching with the old ones). Totally *uncool*.

# Git hooks

When [Git][] does... what it does, it goes through a series of steps
and, in some cases, you can insert some execution between two of these
steps. You do this using [git hooks][].

Each hook is a program with the right name (depending on the specific
command/steps you want to plug into), the right execution bits (i.e. it
can be *executed*), living in the right place (`<GIT-DIR>/hooks`).

The hook that we are interested into in this case is named
`post-rewrite`. Here is an extract from the docs:

> This hook is invoked by commands that rewrite commits ([...]
> `git-rebase` [...]). Its first argument denotes the command it was
> invoked by: currently one of `amend` or `rebase`.
>
> The hook receives a list of the rewritten commits on stdin, in the
> format:
>
> `<old-sha1> SP <new-sha1> [ SP <extra-info> ] LF`

This is interesting because it is triggered by the `rebase` *and* gives
us the exact mapping between the old commits and the new commits. With
them, we can:

- look at the old commit and see if it has a date-shaped tag attached to
  it
- if it has one, move that tag onto the new commit

Yay!

# Let's code the hook

The code for the hook is the following:

<script src='https://gitlab.com/polettix/notechs/snippets/1984708.js'></script>

[Local version here][].

Line 5 makes sure that we only act upon a `rebase` action (i.e. we avoid
doing stuff for an `amend` action, or whatever else might come in the
future).

The loop in lines 7 to 15 goes over all the input lines, storing the
`old-sha1` in variable `pre` and `new-sha1` in variable `post`. Variable
`rest` collects anything else in the line, should the optional
`extra-info` be present (it's not as of this post).

Line 9 turns the SHA1 digest of the *previous* commit into a list of
tags that are attached to it. Finding this command proved to be very
challenging for me - it seems that my websearching-fu was quite weak to
this extent!

In case of errors, we just don't do anything - this is the reason of the
`|| printf \\n` in line 9.

Tags are printed one per line, which is where `grep` shines. For this
reason, line 10 allows us to only keep tags that look like a date in
`YYYY-MM-DD`.

At this point, we have everything we need: the `ŧag` (read in at line
11) and the new commit that it should be attached to (in variable
`post`), so we just have to force the tag on it (line 12).

It's also useful to print out the list of tags that were moved (line 13
and, later line 16), so that we can later use it for pushing the tags to
the remote repository.

# Time to use it

Now, let's use it:

```shell
$ git rebase master
First, rewinding head to replay your work on top of it...
Applying: Another commit
Applying: Another prime (5 was not!)
Applying: Now I put 7
 2020-06-05 2020-06-06
```

Now we can copy that last line and easily build a command to push these
changed tags towards the private repository:

```shell
$ git push -f private-repository 2020-06-05 2020-06-06
```

And this is, finally, it!


[Rebase and retag]: {{ '/2020/06/11/rebase-retag/' | prepend: site.baseurl }}
[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub/'  | prepend: site.baseurl }}
[Local version here]: {{ '/assets/code/rebase-auto-retag/post-rewrite' | prepend: site.baseurl }}
[Git]: https://www.git-scm.com/
[git hooks]: https://git-scm.com/docs/githooks
