---
title: Remove objects from an array with jq
type: post
tags: [ jq, json ]
comment: true
date: 2021-11-19 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> This took me a while.

So I had a [JSON][] file with an array containing multiple objects, and
I wanted to remove all that *did not* have a specific key. The internet
was not *so generous* this time, as I found a lot of half solutions (to
which I cannot point right now).

Eventually, I found two ways of doing this... so be my guest, future me:

<script id="asciicast-449986" src="https://asciinema.org/a/449986.js" async></script>

I hope it will be useful for other people using [jq][] too... stay safe!

[JSON]: https://www.json.org/
[jq]: https://stedolan.github.io/jq/
