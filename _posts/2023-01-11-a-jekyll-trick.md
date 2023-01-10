---
title: A Jekyll performance trick
type: post
tags: [ blog, jekyll ]
comment: true
date: 2023-01-11 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I discovered a performance trick for [Jekyll][].

As the blog was growing, I observed increasing times for re-generating
the whole thing. You might remember [Faster Jekyll][], for example,
where I already discussed about it.

My solution at the time was to have a faster and limited re-generation
for looking at new posts quickly, while leaving the slower generation to
a secondary process.

Then came [Blog posts rearrangement][], where I moved most of the posts
into ad-hoc directories, while still leaving more than 3 hundred posts
in the main directory, because it was november.

At the beginning of the year, I made a similar rearrangement to
"archive" 2022, and I noted a considerable boost in site regeneration
speed.

So, I guess, *moving stuff in sub-directories and leaving fewer posts in
the main directory will probably help*. Good to know!

Stay safe and... have fun!

[Jekyll]: https://jekyllrb.com/
[Faster Jekyll]: {{ '/2021/05/18/faster-jekyll/' | prepend: site.baseurl }}
[Blog posts rearrangement]: {{ '/2022/11/13/blog-posts-rearrangement/' | prepend: site.baseurl }}
