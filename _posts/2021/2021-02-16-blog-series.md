---
title: Added series to the blog
type: post
tags: [ blog, jekyll ]
comment: true
date: 2021-02-16 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I added the [series][] to this [blog][].

This pretty much says it.

Well... not exactly. I copied the basics of series handling from here:
[Adding Post Series to Jekyll Site][] (by [Dmitry Rogozhny][]). This now
allows me to have a list of the posts inside a series inside each post,
so that it's possible to easily jump through all of them (something that
I did manually so far, if ever).

I then added a specific page to list all [series][], just in case you
get bored and want to get *more bored* by reading my repeated babbling
about a single topic.

Stay safe!

[blog]: {{ '/' | prepend: site.baseurl }}
[series]: {{ '/series/' | prepend: site.baseurl }}
[Adding Post Series to Jekyll Site]: https://dmitryrogozhny.com/blog/adding-post-series-to-jekyll-site
[Dmitry Rogozhny]: https://dmitryrogozhny.com/
