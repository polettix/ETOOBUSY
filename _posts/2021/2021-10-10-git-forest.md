---
title: Git Forest
type: post
tags: [ git ]
comment: true
date: 2021-10-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> `git-forest` from [hxtools][] is nice.

I like to look at a [Git][] repository using some kind of
*pseudo-graphical* representation of the hierarchy. The bottom line
visualizer is usually the following alias in `~/.gitconfig` (I usually
put it all in one line, I don't know if `\\` works!):

```
lg = log --graph --abbrev-commit --date=relative --date-order \
    --format=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr)%Creset %Cred<%an>%Creset'
```

This produces something like this (I don't have much hierarchies in my
blog...):

![Git graphical log, basic]({{ '/assets/images/git-lg-simple.png' | prepend: site.baseurl }})

But... when there's [Perl][] and the possibility to install [the Git
module][], I also like to use the utility `git-forest` from [hxtools][],
setting the alias like this instead:

```
lg = !"git-forest --reverse --sha --style 10"
```

This yields the following (the items are in reversed order for my local
choice):

![Git graphical log, with git-forest]({{ '/assets/images/git-lg-forest.png' | prepend: site.baseurl }})

This is very nifty in my opinion!

I know there is also a [git-foresta][] project, which is apparently an
evolution of the initial project with the nice added benefit of being
*fatpacked*, so batteries included! I'll probably give it a try...

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[hxtools]: http://inai.de/projects/hxtools/
[Git]: https://git-scm.com/
[the Git module]: https://metacpan.org/pod/Git
[git-foresta]: https://github.com/takaaki-kasai/git-foresta
