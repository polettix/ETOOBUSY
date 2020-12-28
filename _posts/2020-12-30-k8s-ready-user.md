---
title: Create a Kubernetes-ready user
type: post
tags: [ kubernetes, shell ]
comment: true
date: 2020-12-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Easily create a [Kubernetes][]-ready user with a basic script.

This program creates a new user's credentials that are (well, should be) valid
for a [Kubernetes][] cluster where the CA certificate and key have a known
position in the filesystem.

<script src="https://gitlab.com/polettix/notechs/-/snippets/2054897.js"></script>

[Local version here][].

Creating a user is only one half of the solution - it will then need to be
associated with proper permissions through [Roles][] and [ClusterRoles][] and
their respective *bindings*. Anyway... it's a start.

Use it like this:

```
k8s-new-user <username> [<group> [<group> [...]]]
```

The output will be a file named `<username>.kubeconfig` that is suitable for
being used instead of the default `~/.kube/config` (e.g. it might be provided
to the target user).

```shell
export KUBECONFIG="$PWD/$USERNAME.kubeconfig"
kubectl get pod ....
```

Using this script is not very secure because it makes sure to also generate the
user's private key. In a more secure process, each user would generate its own
key/CSR pair and provide the CSR to the CA for signing.

Again... it's a start 🤓

[Kubernetes]: https://kubernetes.io/
[Roles]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-example
[ClusterRoles]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#clusterrole-example
[Local version here]: {{ '/assets/code/k8s-new-user' | prepend: site.baseurl }}
