---
title: Updating GitHub Pages stuff
type: post
tags: [ blog ]
comment: true
date: 2020-10-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An annoying (but useful) message from [Dependabot][] required me to do
> some updating of the [GitHub Pages][] machinery, which in turn
> triggered an update on [dokyll.sh][]. Oh my!

The solution to my problem was to run a `bundle update --all`, which in
turn updates the `Gemfile.lock` that is analyzed by the [Dependabot][].
All of this thanks to [this answer in Stack Overflow][solution].

> Of course the problem is *not* the alert from [Dependabot][], but you
> get the idea.

The bottom line is that now [dokyll.sh][] has a new sub-command
`build-update`:

```shell
# ...
case "$1" in

   (bundle-update)
      DOKYLL_PRE='' dokyll bundle update --all
      exit $?
      ;;

    ...
```

This does the update and - hopefully - solve the issue raised by
[Dependabot][]. Hopefully!


[Dependabot]: https://dependabot.com/
[GitHub Pages]: https://pages.github.com/
[dokyll.sh]: https://github.com/polettix/ETOOBUSY/blob/master/dokyll.sh
[solution]: https://stackoverflow.com/a/63366973/334931
