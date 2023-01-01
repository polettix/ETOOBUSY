---
title: 'Gitolite - automatic main branch detection'
type: post
tags: [ gitolite, git, perl ]
comment: true
date: 2022-02-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A small script that can set the default branch in [Gitolite][] newly
> created repositories.

One thing that [Gitolite][] does is create repositories *automatically*
based on a few rules (which might be the explicit addiition in the
configuration file or by setting up some [wild stuff][].

There's one catch though: the *default* branch is set when the
repository is created (with `git init --bare`) and depends on the
configurations on the server hosting `gitolite`. Hence, if we have this:

```
[user]
   email = urist@example.com
   name  = urist
# ...
[init]
   defaultBranch = main
```

then the default branch name will be... `main`.

Many times, though, the *users* will have a different setup in their own
machines. They might be relying on `master`, which has been the default
for a lot of time. They might have opted for `trunk`, remembering their
days in CSV/SVN. They might have settled for `production`, or `prod`.

Fact is that in this case, they can surely `push` stuff to the brand
new, empty remote repository:

```
alice$ git remote add myrepo git@gitolite-host:public/foo
alice$ git push myrepo production
Initialized empty Git repository in /home/urist/repositories/public/foo.git/
Counting objects: 2, done.
Writing objects: 100% (2/2), 160 bytes | 0 bytes/s, done.
Total 2 (delta 0), reused 0 (delta 0)
To git@gitolite-host:public/foo
 * [new branch]      production -> production
```

and this *will work* for sure, saving the precious data in the remote.
On the other hand, someone else `clone`-ing the project might have a
funny surprise:

```
berto$ git clone git@gitolite-host:public/foo
Cloning into 'foo'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
warning: remote HEAD refers to nonexistent ref, unable to checkout.
```

How come?

The misunderstaning stems from the fact that the default branch in the
remote repository is `main` (as set from the server's configuration
during bare repo creation) *but* the `main` branch has never been pushed
to the repo, because the user adopted a different choice.

This is the gist of [this question here][].

The solution to this is to set the default branch in the bare repository
in  the server to a value that reflects this user's choice. This, in
turn, requires that this choice is *known*.

One approach is to set it explicitly after the bare repository has been
created or immediately after. As it's `alice` that is pushing, most
probably `alice` is also issuing the command:

```
$ ssh git@gitolite-host symbolic-ref public/foo HEAD refs/heads/production
```

This in turn requires that the `symbolic-ref` wrapper shipped with
[Gitolite][] is enabled in the configuration file `.gitolite.rc`:

```perl
# ...

    ENABLE => [

        # COMMANDS

            # These are the commands enabled by default
            'help',
            'desc',
            'info',
            'perms',
            'writable',

            'symbolic-ref',   # <--- ADD THIS ----<<<

#...
```

This is, not surprisingly, a drag. I mean, things will work fine for
`alice` after the `push`, and this added command is so easy to forget...
and so easy to automate.

This leads us to the following [trigger][], which is [Gitolite][]'s
equivalent of the *hook* system in [Git][]:

```shell
#!/bin/sh

info() { printf >&2 %s\\n "$*" ; }

die()  { info "$*" ; exit 1 ; }

ensure_HEAD() {
   [ "$1" = 'POST_GIT' ] || die "unsupported trigger '$1'"

   cd "$GL_REPO_BASE/$2.git"

   # everything OK if the default in HEAD points to a real branch
   git show-ref --quiet --verify "$(git symbolic-ref HEAD)" && return 0

   # there *might* be a mismatch, so let's find out a real branch
   local head
   head="$(git show-ref --heads | head -1 | sed -e 's/^.* //')"

   # the repo might still be empty
   [ -n "$head" ] || return 0

   # we have a default branch that we can set here
   info "setting HEAD to <$head>"
   git symbolic-ref HEAD "$head" -m "Default HEAD to branch <$head>"
}

set -eu

ensure_HEAD "$@"
```

> The script above is a reshuffling of an original idea from
> [Gitolite][]'s author, as [described here][]. It tries to use only
> [Git][] commands instead of fiddling with the internals of how the
> `.git` directory is organized.

If this file is saved as `~/local/triggers/auto-default-branch`, we can
then configure it in the `~/.gitolite.rc` file:

```perl
#...

        # this one is managed directly on the server
        LOCAL_CODE                =>  "$ENV{HOME}/local",

# ...

    POST_GIT => [
        'auto-default-branch',
    ],

# ...
```

The first configuration for `LOCAL_CODE` makes sure that the local
triggers are properly found, the second for `POST_GIT` adds the specific
program to be called when the `POST_GIT` trigger is run.

So now this is what happens:

```
alice$ git remote add myrepo git@gitolite-host:public/bar
alice$ git push myrepo production
Initialized empty Git repository in /home/urist/repositories/public/bar.git/
Counting objects: 2, done.
Writing objects: 100% (2/2), 160 bytes | 0 bytes/s, done.
Total 2 (delta 0), reused 0 (delta 0)
setting HEAD to <refs/heads/production>
To git@gitolite-host:public/bar
 * [new branch]      production -> production
```

It's a bit lost in the messages, but our program was definitely called:

```
setting HEAD to <refs/heads/production>
```

Let's see it from `berto`'s side now:

```
berto$ git clone git@gitolite-host:public/bar
Cloning into 'bar'...
remote: Enumerating objects: 2, done.
remote: Counting objects: 100% (2/2), done.
Receiving objects: 100% (2/2), done.
remote: Total 2 (delta 0), reused 0 (delta 0), pack-reused 0
```

No more complaining, yay!


[Perl]: https://www.perl.org/
[wild stuff]: https://gitolite.com/gitolite/wild.html
[Gitolite]: https://gitolite.com/gitolite/index.html
[this question here]: https://groups.google.com/g/gitolite/c/yAIHybz3H18/m/iVLQPt8tAgAJ
[Git]: https://www.git-scm.com/
[trigger]: https://gitolite.com/gitolite/triggers
[described here]: https://groups.google.com/g/gitolite/c/NwZ1-hq9-9E/m/mDbiKyAvDwAJ
