---
title: 'Bump Kubernetes services'
type: post
tags: [ kubernetes ]
comment: true
date: 2022-05-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Sometimes you just have to bump!

Some time ago one test Kubernetes cluster suddenly stopped listening to
us. No big deal actually, just the need to refresh the certificates
after one year.

We were back and the API server was friendly again, nodes were up, Pods
poddish, etc.

Only thing that the cluster was not listening to us. An update to a
deployment? Nope. Killing a Pod? The replacement was nowhere to be seen.

And yet the nodes were all up!

Long story short, both the scheduler and the controller-manager were not
able to authenticate. They were insisting on using the previous
certificates, in spite of the updated configuration files. So... they
had not been restated, it seems.

Killing them did suffice, luckily, so we were back on the driver's seat.

This is an exceptional reminder to the fact that [Kubernetes][] is an
interesting yet complicated beast, which can drag a lot of time in the
lifecycle management of the cluster itself even for a secondary test
installation to get acquainted with the tool.

To some extent it reminds me of [Linux][] and the surrounding ecosystem
of applications, because doing things from scratch is instructive but
time consuming and most of the times one is better off with a
distribution.

So... if your cluster seems a bit deaf, take a look at the logs of the
scheduler and the contoller-manager!

[Kubernetes]: https://kubernetes.io/
[Linux]: https://www.kernel.org/
