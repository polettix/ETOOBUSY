---
title: Mac OS X caffeinate
type: post
tags: [ mac os x, shell ]
comment: true
date: 2021-03-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [caffeinate][] helps you prevent Mac OS X to go into sleep mode.

Or, in the man page own terms:

> Prevent the system from sleeping on behalf of a utility.

After setting up a monitor for my [Flaky internet connection][], I had an
issue in leaving it running while not actively using my computer - after
some time, Mac OS X goes in sleep mode and the monitor stops.

This is where I discovered [caffeinate][], which is designed exactly to
prevent this (from the command line).

Useful to remember for the future!

[caffeinate]: https://ss64.com/osx/caffeinate.html
[Flaky internet connection]: {{ '/2021/03/20/flaky-internet-connection/' | prepend: site.baseurl }}
