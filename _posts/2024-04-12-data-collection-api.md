---
title: Thinking on a data collection API
type: post
tags: [ web, perl ]
comment: true
date: 2023-04-12 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm thinking on an API for collecting a few data.

I'd like to collect some data about things I do, from sports to getting good
habits, and so far I used a few apps like Habitica.

But... this does not really thrill me from a privacy standpoint. Which meant
that I eventually settled on [Loop Habit Tracker][], because it only works
locally.

But... I'd really like to use a *web* application, because who needs all
those stinkin' apps? Only... self-hosted.

I'm sort of bouncing like a flipper ball here. On the one hand, I'd go to a
solution like [Prometheus][] -- at the end of the day, we're collecting
metrics here, right? Yet, it seems overkill for collecting data of one or
two people.

In pure wheel-reinventing spirit, then, I'll probably settle for doing it
myself and come out with some half-baked solution that will fail me at some
time. Optimism time!

We'll see where it takes me, in the meantime stay safe!

[Perl]: https://www.perl.org/
[Loop Habit Tracker]: https://loophabits.org/
[Prometheus]: https://prometheus.io/
