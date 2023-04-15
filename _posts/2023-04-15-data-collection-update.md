---
title: Data collection update
type: post
tags: [ web, perl, tracking ]
comment: true
date: 2023-04-15 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I did a bit of scouting but decided to roll my own.

After [Thinking on a data collection API][] a bit, I ventured into the
internet to find out ready-made things.

In recent years, [Time-series databases][] have become a hot topic, and yet
I feel they're not really the right thing for my low-spec requirements:
collect some data every now and then, for a handful of people.

Many of them, for example, are optimized for collecting data like crazy and
support different levels of aggregation. This makes sense when there's a lot
of data coming, of course. On the other hand, I anticipate very sparse data,
so I'm more worried about pre-allocating all the space over 50 years or so
than about data possibly exploding in time.

Hence, for the time being I'll be collecting and tracking individual data
points in a traditional RDBMS with a simple API; in case scale will ever by
an issue, I'll figure out how to ingest all the collected data in a new
system.

Stay safe!

[Perl]: https://www.perl.org/
[Thinking on a data collection API]: {{ '/2023/04/12/data-collection-api/' | prepend: site.baseurl }}
[Time-series databases]: https://en.wikipedia.org/wiki/Time_series_database
