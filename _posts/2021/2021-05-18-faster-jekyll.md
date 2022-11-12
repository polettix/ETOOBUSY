---
title: Faster Jekyll
type: post
tags: [ blog, jekyll ]
comment: true
date: 2021-05-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A way to speed-up local re-generation of [Jekyll][] sites.

As this blog goes on, I notice that the time to re-generate the whole
thing increases. While it was not that big of an issue when it was
around a handful of seconds, lately it's come to about 18-20 seconds,
which is *annoying*.

Then I asked the mighty internet and came up with [Speed up Jekyll site
regeneration][] - it's possible to limit the rendering to only the last
ones with option `--limit_posts`. This prompted me to add the following
sub-command in `dokyll.sh` ([A shell helper for dokyll][]):

```shell
# case ...
   (qbuild)
      DOKYLL_PRE='' dokyll bundle exec jekyll build \
         $multiconfig --watch --future --limit_posts 5
      exit $?
      ;;
```

I decided to *add* a target `qbuild` instead of changing the original
`build` because I still liked the idea to re-generate the whole thing
(e.g. if I do a fix in a previous post).

The speed-up is tangible, as it's dropped below 5 seconds again. Still,
now I would be left with only a few posts rendered.

Then it occurred to me that I can leave **both** `qbuild` and `build`
running. The former provides the fast feedback that I look for when
writing posts, while the latter re-generates the whole thing taking its
time.

Take care folks!

[Jekyll]: http://jekyllrb.org/
[Speed up Jekyll site regeneration]: https://www.marcusoft.net/2015/11/speed-up-jekyll-site-regeneration.html
[A shell helper for dokyll]: {{ '/2020/05/27/dokyll-shell-helper/' | prepend: site.baseurl }}
