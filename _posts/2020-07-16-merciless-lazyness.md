---
title: 'Blog post publishing: merciless lazyness'
type: post
tags: [ blog, coding ]
comment: true
date: 2020-07-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I think there's too many ways to be lazy.

In [Posts publishing routine in a script][] I described a small shell
script to help me with the usual routine to publish a new post: add to
git, commit, tag with date, push everything...

With a script, I can provide the date, the commit message and the paths
all at once, and get the job done. Lazyness for the win!

And then it hit me: *Flavio, you can do less* 🧐

I mean, it's everything there right? The date, the post title for the
commit message, the list of new posts... let the computer do its job!

So there you get it, the new shiny [publish.sh][], now with:

- automatic grabbing of `date` and `title` (thanks to [teepee][]);
- serial publishing of multiple days (under conditions);
- so many seconds spared!!!

So yes, I can write multiple posts and put them in the publishing
pipeline with a single command, provided that there are only post files
in the invocation. There's even a `--all` option to publish everything
that is available.

Even though I feel like a lone man in the desert here in this blog...
enjoy!


[Posts publishing routine in a script]: {{ '/2020/07/07/publish-post' | site.baseurl }}
[teepee]: http://blog.polettix.it/teepee/
[publish.sh]: https://github.com/polettix/ETOOBUSY/blob/master/publish.sh
