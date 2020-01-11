---
title: Kubernetes operators
type: post
tags: [ kubernetes, operator, gist ]
comment: true
date: 2020-01-12 08:00:00 +01:00
preview: true
published: false
---

**TL;DR**

> [Kubernetes][kubernetes] gradually introduced and enhanced support for
> [operators][], a way to support custom-defined domain-specific
> applications that are managed as any other [kubernetes][] resource via API
> extension.

As you might have probably guessed by now, I'm looking a lot into
[kubernetes][] lately, collecting definitions and interesting pieces of data
as I read around.

Being about the third time I stumble upon [operators][], I thought it best
to write something for when my future self will be looking around this piece
of information time and again.

## What is an Operator?

I think the following definition from [What is an Operator][what-is] is
quite clear and to the point:

> The goal of an Operator is to put operational knowledge into software.
> Previously this knowledge only resided in the minds of administrators,
> various combinations of shell scripts or automation software like Ansible.
> It was outside of your Kubernetes cluster and hard to integrate. With
> Operators, CoreOS changed that.
>
> Operators implement and automate common Day-1 (installation,
> configuration, etc) and Day-2 (re-configuration, update, backup, failover,
> restore, etc.) activities in a piece of software running inside your
> Kubernetes cluster, by integrating natively with Kubernetes concepts and
> APIs. We call this a Kubernetes-native application. With Operators you can
> stop treating an application as a collection of primitives like Pods,
> Deployments, Services or ConfigMaps, but instead as a single object that
> only exposes the knobs that make sense for the application.

As indicated in the explanation above, it was all started by [CoreOS][] in
their blog post [Introducing Operators: Putting Operational Knowledge into
Software][coreos-post]:

> An Operator is an application-specific controller that extends the
> Kubernetes API to create, configure, and manage instances of complex
> stateful applications on behalf of a Kubernetes user. It builds upon the
> basic Kubernetes resource and controller concepts but includes domain or
> application-specific knowledge to automate common tasks.

## How is it realized?

[Kubernetes][kubernetes] releases gradually eased and streamlined the
definition and support for [operators][] (or, at least, this is how I
understand it). From the documentation as of January 2020:

> Operators are software extensions to Kubernetes that make use of [custom
> resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
> to manage applications and their components. Operators follow Kubernetes
> principles, notably the [control
> loop](https://kubernetes.io/docs/concepts/#kubernetes-control-plane).

[Custom
resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
are extensions of the Kubernetes API, which usually address two different
halves, i.e. defining how the API is extended (in terms of endpoints) and
what actions should be done to ensure that the new resources follow the same
principles of *declaration-based behavior* as all built-in resources.

## So... packing applications? Again?

At this point, it's easy to remain confused and ask how do [operators][]
play against e.g. [Helm][]. The [original article][coreos-post] has a
specific question-and-answer to this:

> Q: How is this different than Helm?
>
> A: Helm is a tool for packaging multiple Kubernetes resources into a
> single package. The concept of packaging up multiple applications together
> and using Operators that actively manage applications are complementary.
> For example, traefik is a load balancer that can use etcd as its backend
> database. You could create a Helm Chart that deploys a traefik Deployment
> and etcd cluster instance together. The etcd cluster would then be
> deployed and managed by the etcd Operator.

As I read it, they can be considered somehow complementary, to the point
that - probably - [Helm][] is a bit more flexible to play around, while
[operators][] fit better when technologies are more stable. This is totally
my opinion!

## Summary

We're just scratched the surface, but you should now have a clearer idea of
what [operators][] are and what purpose they serve. Please comment!


[kubernetes]: https://kubernetes.io/
[operators]: https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
[what-is]: https://operatorhub.io/what-is-an-operator
[CoreOS]: https://coreos.com
[Helm]: https://helm.sh/
[coreos-post]: https://coreos.com/blog/introducing-operators.html
