---
title: Cloudflare caching
type: post
tags: [ cloudflare, web, Mojolicious ]
comment: true
date: 2023-04-16 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Beware of caching by [Cloudflare][].

I activated [Cloudflare][] as a frontend for a few toy web applications,
mostly because it's free (although I'm not 100% convinced about it as of
every concentration of power. Anyway...).

While happily updating my application, I tried to change a few things in a
stylesheet, mostly to figure out if I was getting my changes in the right
place. Anyway, I could change the stylesheet like crazy, but I still got the
same in the browser, even with the `Shift+Ctrl-R` which should be me begging
for all caches to stay out of the way.

It turns out that [Cloudflare][] does indeed cache *aggressively*, so the
solution I found around is to let it think that the URL is a dynamic one,
like adding a query part that always changes. So I have something like this
in my [Mojolicious][] layout template:

```
<link rel="stylesheet" href="/style.css?foo=<%= time() . rand() %>">
```

I feel lucky to have thought about it to be honest: I was reminded about
putting these services behind [Cloudflare][] only a few days ago, so it
somehow stuck to my mind for the right amount of time.

If you have a similar problem... it might be something in the middle that
you might not be aware of!

[Cloudflare]: https://www.cloudflare.com
[Mojolicious]: https://metacpan.org/pod/Mojolicious
