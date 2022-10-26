---
title: Light Git repository checkout
type: post
tags: [ git, the weekly challenge ]
comment: true
date: 2022-10-26 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Relatively recent [Git][] clients support getting only part of the
> files out of a repository clone.

I've been doing some housekeeping in a VM recently, and I needed some
space to do this. Stuff had piled on in time... so it was time for some
cleaning.

One thing that hit me was the size of my clone of [The Weekly
Challenge][] repository. It was about 700+ MB, out of which only about
100 MB in the `.git` repository. Hence, it's mostly the checked out
files in the working tree.

Which, of course, does not make sense in each individual's participant,
except probably [manwar][] who runs the whole show. Seriously, I never
go looking inside *most* of the directories, so why have them?

Enter [git sparse-checkout][sparse-checkout], a way that's been added
since *some time ago* to address exactly this need. I mean, not the one
with [The Weekly Challenge][] in particular, but the problem of getting
only a few files out in general.

The bottom line is that we can get to decide exactly which files can
appear in our working tree, so as long as we're happy with what we see
then [Git][] is too. Sub-command [sparse-checkout][] lets us:

- `init`ialize the whole thing
- `set` the whole list of files we want to see
- `add` elements to the list, incrementally
- `list` what's made available (and *what not*, with inverted rules)
- `reapply` the masking, in case of need
- `disable` the whole thing and see everything.

There are a few tutorials here and there, here's my *simplified* routine
that I applied to [The Weekly Challenge][].

Just before starting: I keep [my own fork][] of the [main repository][],
generating a new separate branch for each contribution and using that to
generate a *pull request* in the main repository. I guess this is pretty
much everyone else does.

First thing I did was to get rid of the previous repo checkout. There
are probably quicker ways, but it was the first time for me:

```
cd /path/before
rm -rf pwc  # this is how I call the directory
```

Then, I cloned the repo again, making sure to pass the `--sparse` option
that sets [sparse-checkout][] in a sensible default way:

```
MYFORK='git@github.com:polettix/perlweeklychallenge-club.git'
git clone --sparse "$MYFORK" pwc
cd pwc
```

The `--sparse` does two things:

- invokes the `init` command in the cloned repository, so that we don't
  have to;
- it `set`s the initial file list to only include *files* in the
  project's root directory, excluding all *sub-directories* and their
  contents.

This is what I ended up with:

```
$ ls -l
-rw-r--r--   1 poletti poletti   659 Sep  4 14:06 guests.json
-rw-r--r--   1 poletti poletti 12511 Sep  4 14:06 members.json
-rw-r--r--   1 poletti poletti  7022 Sep  4 14:06 README.md

$ git sparse-checkout list
/*
!/*/
```

As expected, files in the root directories, but no sub-directories.

Now I set the `upstream` remote pointing to the main one, so that I can
get new challenges as the are generated:

```
MAINREPO='https://github.com/manwar/perlweeklychallenge-club.git'
git remote add upstream "$MAINREPO"
git fetch
```

As of this writing, the last challenge was #180, so I decided to allow
that to be visible:

```
git sparse-checkout add /challenge-180/
```

My `master` branch in GitHub is ages behind of the main repo, because I
have actually no interest in it (in my fork, I mean). On the other hand,
I *do* care to have it in my local computer, otherwise I would not see
the scaffolding for new challenges. So it was time to align to
`upstream/master`:

```
git merge upstream/master
```

As expected, the allowed directory popped up:

```
$ git sparse-checkout list
/*
!/*/
/challenge-180/

$ ls -l
drwxr-xr-x 276 poletti poletti 12288 Sep  4 14:06 challenge-180
-rw-r--r--   1 poletti poletti   659 Sep  4 14:06 guests.json
-rw-r--r--   1 poletti poletti 12511 Sep  4 14:06 members.json
-rw-r--r--   1 poletti poletti  7022 Sep  4 14:06 README.md

$ find challenge-180 | wc -l
864
```

Did this help? Let's find out using our old friend `du`:

```
# the global occupation of the whole project, git and working tree
$ du -hs .
113M	.

# the git repo only
$ du -hs .git
109M	.git
```

Mission accomplished, stay safe and compact!



[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[The Weekly Challenge]: https://theweeklychallenge.org/
[manwar]: http://manwar.org/
[Git]: https://www.git-scm.com/
[sparse-checkout]: https://www.git-scm.com/docs/git-sparse-checkout
[my own fork]: https://github.com/polettix/perlweeklychallenge-club
[main repository]: https://github.com/manwar/perlweeklychallenge-club
