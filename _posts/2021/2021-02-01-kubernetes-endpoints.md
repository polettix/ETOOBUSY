---
title: Kubernetes Endpoints
type: post
tags: [ kubernetes ]
comment: true
date: 2021-02-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> SDAIL: name [Kubernetes][] [Endpoints][] the same as the [Service][]
> they are tied to.

You might be wondering what I mean with SDAIL: it's Some Days Ago I
Learned. This is because there's some lagging between when I actually
*learned* that thing and when I'm publishing it... and I like to be
accurate if possible 😅

Well, enough of meta now.

[Endpoints][] are a kind of [Kubernetes][] resource that one has rarely
to deal with. This is because *usually* they are automatically created
and managed *behind the scenes* to implement the underlying mechanisms
of a [Service][], so they are not immediately visible.

They can come *explicitly* handy in some situations, though.

One example I had to deal with was representing the [etcd][] cluster of
the [Kubernetes][] instance *within* the instance itself. I mean, a
[Kubernetes][] instance usually relies on [etcd][], right? This is
something that is *external* to the stuff managed by that specific
[Kubernetes][] instance, so it does not normally appear as a [Service][]
visible from the inside.

Well, [Endpoints][] come handy in these situations where you have
something that is *external* to the [Kubernetes][] instance, but you
want to represent as if it were an *internal* thing behind a
[Service][].

There are two halves to do this. First, we can create the [Service][],
being careful to **not** associate it to anything (i.e. leave out any
*selector*):

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: default
  name:      etcd-supporting-kubernetes
spec:
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 2379
      targetPort: 2379
```

This [Service][] `etcd-supporting-kubernetes` *lives* inside namespace
`default`, so it is readily accessible to all [Pods][] in that
namespace.

Fact is... there is nothing *behind* this service. I mean, when this
service is contacted, it turns and... there's nothing actually listening
to the `targetPort`.

This is where [Endpoints][] come to the rescue, because we can define
them *explicitly* to point towards the addresses of where our *external*
[etcd][] instance is running:

```
apiVersion: v1
kind: Endpoints
metadata:
  namespace: default
  name:      etcd-supporting-kubernetes
subsets:
  - addresses:
      - ip: 10.20.30.40
      - ip: 10.20.30.41
      - ip: 10.20.30.42
    ports:
      - port: 2379
```

Although it might be *obvious* in hindsight, to make [Service][]
`etcd-supporting-kubernetes` figure out the correct [Endpoints][]
resource, *this MUST be named the same as the [Service][]*, i.e.
`etcd-supporting-kubernetes`.

In practice, `name` and `namespace` from the [Service][] definition MUST
be copied to the [Endpoints][] definition.

Good to know!


[Kubernetes]: https://kubernetes.io/
[Endpoints]: https://kubernetes.io/docs/reference/kubernetes-api/services-resources/endpoints-v1/
[Service]: https://kubernetes.io/docs/concepts/services-networking/service/
[etcd]: https://etcd.io/
[Pods]: https://kubernetes.io/docs/concepts/workloads/pods/
