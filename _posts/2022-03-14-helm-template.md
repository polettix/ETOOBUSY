---
title: Helm template command
type: post
tags: [ kubernetes, helm ]
comment: true
date: 2022-03-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> TIL `helm template` to expand templates locally for fun and testing.

When working with [Helm][] charts it's often useful to figure out what
the expanded templates will look like, e.g. to spot errors in
indentation or values that are fit inside.

Up to now, I was relying upon running `helm install --dry-run --debug`
for this. This has the advantage of doing the most accurate simulation
possible of the installation *in a specific [Kubernetes][] cluster*, at
the expense of... *having a real [Kubernetes][] cluster* to play with.

This is not always the (well, *my*) case though, so I turned to the
mighty internet and found out about the [template][] sub-command, which
is meant exactly for this:

> **Synopsis**
>
> Render chart templates locally and display the output.
>
> Any values that would normally be looked up or retrieved in-cluster
> will be faked locally. Additionally, none of the server-side testing
> of chart validity (e.g. whether an API is supported) is done.
>
>     helm template [NAME] [CHART] [flags]

Thanks internet, and stay safe everyone!

[Kubernetes]: https://kubernetes.io/
[Helm]: https://helm.sh/
[template]: https://helm.sh/docs/helm/helm_template/
