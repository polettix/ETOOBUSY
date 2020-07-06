---
title: Posts publishing routine in a script
type: post
tags: [ blog ]
comment: true
date: 2020-07-07 07:20:20 +0200
mathjax: false
published: true
---

**TL;DR**

> Keeping lazyness levels high

After setting the [ETOOBUSY automated publishing][] system, it was only
time to turn the usual publishing routine:

* add new post to the local [Git][] repo
* commit the post with a message
* push to the *private* repo
* add the tag indicating the date for publishing
* push the tag to the *private* repo

into a script:

<script src='https://gitlab.com/polettix/notechs/snippets/1993175.js'></script>

[Local version here][local version].

I'm looking at you, future me!

[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub' : prepend: site.baseurl }}
[Git]: https://www.git-scm.com/
[local version]: https://github.com/polettix/ETOOBUSY/blob/master/publish.sh
