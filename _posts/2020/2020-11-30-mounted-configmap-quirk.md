---
title: Mounted ConfigMap quirks
type: post
tags: [ kubernetes ]
comment: true
date: 2020-11-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Mounting a [Kubernetes][] [ConfigMap][] as a volume in a [Pod][] might
> enable getting updates as the [ConfigMap][] is changed. With some
> exceptions.

To make a long story short:

- what you find in [ConfigMap][] is *mostly* true: mounting it as a volume
  will give you the benefits of having updated stuff when you change the
  contents of the [ConfigMap];
- when you use `subPath` to mount a *file* in a specific location, though,
  [another piece of documentation][no-update] clarifies that:

> A container using a ConfigMap as a subPath volume will not receive
> ConfigMap updates.

So... you have been warned, *future me*!

[Kubernetes]: https://kubernetes.io/
[ConfigMap]: https://kubernetes.io/docs/concepts/configuration/configmap/
[no-update]: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#mounted-configmaps-are-updated-automatically
[Pod]: https://kubernetes.io/docs/concepts/workloads/pods/
