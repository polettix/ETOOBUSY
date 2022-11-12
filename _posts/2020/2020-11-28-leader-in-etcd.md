---
title: Leader in etcd
type: post
tags: [ shell, coding, etcd ]
comment: true
date: 2020-11-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Who's the leader in [etcd][]?

As you *surely* know, [etcd][] is:

> A distributed, reliable key-value store for the most critical data of a
> distributed system.

I admit: I never used it (directly). Anyway, it happens to be the *memory*
of a [Kubernetes][] cluster, so it's good to know it exists.

Deploying [etcd][] in *high availability* mode means that there will be more
than one instance of it. As a matter of fact, it just makes sense to have an
*odd* number of instances, and most cluster I've seen settle on *three*.

At any time, the instances agree on a *leader*. They elect it autonomously,
so there's nothing to worry about. Except that, sometimes, you might want to
know *who's the leader* at the moment.

Assuming your `etcdctl` program is properly configured, this can be done
like this:

```shell
# get the identifier of the leader
leader_id="$(etcdctl endpoint status -w json | jq .[0].Status.leader)"

# now get the name and the URL of the leader
etcdctl member list -w json \
| jq -r '.members[]
         | select(.ID == '"$leader_id"')
         | .name + " (" + .clientURLs[0] + ")"'
```

Yes, this can be overkill... but good to know!

[etcd]: https://etcd.io/
[Kubernetes]: https://kubernetes.io/
