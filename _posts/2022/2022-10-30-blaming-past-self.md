---
title: Blaming past self
type: post
tags: [ perl ]
comment: true
date: 2022-10-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> My past self is lucky to not be around here.

In a post from a long, long time ago ([A Quiz from my past self][ppost])
I complained against my *then* past self about being sloppy and not
including the documentation about a specific implementation decision.

So far so good.

So I stumbled again on that post, and read on. Oh, there's some caching
to be done, good. Uh, I tried to optimize the cached parameters in order
to minimize the rejection rate, wise. Aha... there are some
consideration about how many bits can be considered fine, interesting.

Then, of course, I looked at the code:

```perl
if (keys($cache->%*) <= CACHE_SIZE) {
   while (($nbits * $M / $reject_threshold) > ($nbits + 1)) {
      $nbits++;
      $M *= 2;
      $reject_threshold = $M - $M % $N;
   }
}
```

At this point, I was like 🤦 with **both** *remote-past me* and
*close-past me*.

**Where is the caching?!?**

So, this is what I think it should have been:

```perl
if (keys($cache->%*) <= CACHE_SIZE) {
   while (($nbits * $M / $reject_threshold) > ($nbits + 1)) {
      $nbits++;
      $M *= 2;
      $reject_threshold = $M - $M % $N;
   }
   $cache->{$N} = [$nbits, $reject_threshold];
}
```

So well... *hello future me, where did present me mess up this time?!?*

[Perl]: https://www.perl.org/
[ppost]: {{ '/2020/05/19/quiz-from-my-past-self/' | prepend: site.baseurl }}
