---
title: Print all resources in a Kubernetes namespace
type: post
tags: [ kubernetes, shell ]
comment: true
date: 2020-10-27 22:01:02 +0100
mathjax: false
published: true
---

**TL;DR**

> A little helper to print all [Kubernetes][] resources in a namespace.

Here it is:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2033506.js"></script>

[Local version here][].

It is actually a refinement of [this answer][] on [StackOverflow][],
with the following additions:

- defaults to namespace `default`;
- does not print anything if there are no resources of a given kind,
  producing a more compact output.

The downside of the second bullet is that it is most probably not
exactly the best thing for very crowded namespaces.

The script doubles down as a library and a script that can be executed,
in pure [POSIX shell modulino][] spirit.

[Kubernetes]: https://kubernetes.io/
[Local version here]: {{ '/assets/code/kga' | prepend: site.baseurl }}
[this answer]: https://stackoverflow.com/a/55796558/334931
[StackOverflow]: https://stackoverflow.com/
[POSIX shell modulino]: https://gitlab.com/polettix/notechs/-/snippets/1868379
