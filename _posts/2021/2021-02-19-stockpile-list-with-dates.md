---
title: Stockpile of posts gets dates in listing
type: post
tags: [ blog, shell ]
comment: true
date: 2021-02-19 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A little enhancement to the listing of stockpiled blog posts.

In previous post [Stockpiling blog posts][] we took a quick look at
[stockpile.sh][], a small shell program that helps me write blog posts
in advance and park them until I need them.

In time, in addition to keeping a few *filler posts*, I also found it
useful to store other more serious ones, just to avoid scheduling too
much stuff in advance. Who knows... I might find some very interesting
topic that I want to anticipate, and decide to defer a post or two.

On the other hand, I like to at least *guess* the publishing date right,
so I usually try to assign a reasonable date anyway. Which has become
increasingly difficult lately, because I'm putting more posts and I have
to always look at what the next date should be.

This is further made difficult by the [Perl Weekly Challenge][], by the
way, because I try to reserve a couple of dates per week to those posts.

In summary... *a mess*.

In trying to make things a bit easier, I enhanced the `list` sub-command
of [stockpile.sh][] to also include the *date* set for all stockpiled
posts. This allows me to have the information quickly, and ease my
routine.

For the curious, this is the new command implementation:

```shell
command_list() {
   local branch rest
   git branch \
      |  sed -ne '/^..stockpile\/item-/s/^..//p' \
      |  while read branch rest ; do
            git diff "$branch^..$branch" \
               | sed -ne '/^+---/,/^+---/{s/^+//;p}' \
               |  awk '
                     /^title:/ { $1 = ""; title = $0 }
                     /^date:/  { date = $2 }
                     END       { print date " " title }
                  ' \
               | sed -e "s#^#$branch  #"
         done \
      |  nl
}
```

The first two commands (`git` and `sed`) make sure to only isolate
stockpile items and provide a list of branches related to a stockpiled
post.

The big `while` loop that follows gets the branch name into variable
`branch` and extracts the date and the title out of it.

These two pieces of information are put inside the initial *front
matter* of the post, which is a YAML fragment delimited by the
conventional `---` lines. The `sed` command makes sure to only isolate
those lines. And yes, if there's anything like that in the following of
the post... I'm pretty much in trouble. Something to do for future me, I
suppose.

The `awk` part takes care to only get the date and the title, and print
them in this order; it is followed by a last `sed` command that adds the
branch name at the beginning.

Last, for good measure I threw a `nl` to all of this, because... it will
come useful.

Stay safe, protect yourself!

[Stockpiling blog posts]: {{ '/2020/10/07/stockpiling-posts/' | prepend: site.baseurl }}
[stockpile.sh]: https://github.com/polettix/ETOOBUSY/blob/master/stockpile.sh
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
