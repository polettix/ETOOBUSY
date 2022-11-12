---
title: Hanging Persistent Volumes in Kubernetes
type: post
tags: [ kubernetes, perl ]
comment: true
date: 2020-11-15 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Sometimes [Kubernetes][] [Persistent Volumes][] are a bit too...
> *persistent*.

It occurred to me that some [Persistent Volumes][] in [Kubernetes][] were
not properly released. It turned out that these were associated to [Volume
Attachments][] that  were not released as well, even in the face of the
associated volumes not existing any more in Openstack/Cinder. Go figure.

This program goes through the list of [Persistent Volumes][] and detects the
*hanging* ones, printing out the name of the Volume Attachment they are
associated to (in    addition to their name too). In this context, *hanging*
is defined as having a reclaim policy of `Delete` (i.e. the persistent
volume should be deleted after it is       released by a claim) and a status
in phase `Released`. This usually appears as `Terminated` in the normal
output of `kubectl get pv`.

<script src="https://gitlab.com/polettix/notechs/-/snippets/2039172.js"></script>

[Local version here][].

The astute reader will surely recognize this line of code as familiar:

```
         my $ref_to_key = reduce(sub { \($$a->{$b}) }, \$_, @path);
```

It's the same trick as described in previous post [Pointer to element][].

I'm not sure of how scalable this solution is: if there are *a lot* of
[Persistent Volumes][] and/or [Volume Attachments][], I fear that
[JSON::PP][] might not be up to the task. I'll have to do some testing one
of these days, but until then it works fine in the clusters I'm playing
with.

Cheers!

[Kubernetes]: https://kubernetes.io/
[Persistent Volumes]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
[Volume Attachments]: https://www.k8sref.io/docs/config-and-storage/volumeattachment-v1/
[Local version here]: {{ '/assets/code/kts-vat' | prepend: site.baseurl }}
[Pointer to element]: {{ '/2020/11/14/pointer-to-element/' | prepend: site.baseurl }}
[JSON::PP]: https://metacpan.org/pod/JSON::PP
