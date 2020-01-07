---
title: Quick note on kubectl taint
type: post
tags: [ kubernetes, taint ]
comment: true
date: 2020-01-09 08:00:00
published: false
---

**TL;DR**

> The main page about [Taints and Tolerations][k8s-tt] in [kubernetes][]
> does not go into some corner cases of how you can set or remove *taints*,
> so here we are.

The aim of *taints* and *tolerations* in [Kubernetes][] is described well in
the documentation:

> Taints \[...\] allow a node to repel a set of pods.
>
> Taints and tolerations work together to ensure that pods are not scheduled
> onto inappropriate nodes. One or more taints are applied to a node; this
> marks that the node should not accept any pods that do not tolerate the
> taints.

Basically:

- you set *taints* on nodes to mark them as having some "bad disease" that
  everyone should keep away from;
- you set *tolerations* onto resources that are allowed to deal with those
  "diseases" and should therefore be admitted in the node even though it has
  the *taint*.

The documentation (including the [manual page][man-taint]) describe how to
set and remove taints, but I've found that they don't tell 100% of the
story.

The following is valid as of early January, 2020.

## Structure of a Taint

The generic syntax of a *taint* is the following:

```
key=value:effect
```

The *key* is like the name of the disease on the node. It can be further
specialized with a *value*, to allow for finer selection granularity,
although setting it is optional (i.e. you can leave it empty).

The *effect* is what consequence the *taint* has. You can set the following
effects:

- `NoSchedule`: prevent scheduling of new Pods;
- `PreferNoSchedule`: avoid as much as possible scheduling of new Pods (this
  is a *soft* alternative of the previous effect);
- `NoExecute`: prevent execution of Pods.

So the main goal of setting a *taint* is to affect either scheduling or
execution, nothing more.

For example, setting the following *taint* on a node:

```
has-feature=sriov:NoSchedule
```

means that, unless Pods are able to deal with `has-feature=sriov` (via a
suitable *toleration*), they will not be scheduled on the node. Something
similar would happen with this *taint*:

```
has-sriov=:NoSchedule
```

only that in this case there's an empty value associated to the
`has-sriov`. How you want to use all of this (i.e. with a value or not) is
totally up to you.

## Setting taints

You can set a *taint* with the [kubectl taint][man-taint] command. The
generic syntax is as follows:

```
kubectl taint node <node> <key>=[<value>]:<effect> [...]
```

You can use `nodes` instead of `node` if you wish.

> We will assume to work on node whose name is in environment variable
> `NODE` from now on. If you set it to the string `--all`, the operation
> will apply to all nodes.

Example:

```
# set taint NoSchedule associated to key 'has-feature' and value 'sriov'
kubectl taint node "$NODE" has-feature=sriov:NoSchedule
```

Setting a taint with an empty value always requires the equal sign:

```
# THIS GIVES AN ERROR
kubectl taint node "$NODE" has-feature:NoSchedule

# this is correct and associates an empty value to key 'has-feature'
kubectl taint node "$NODE" has-feature=:NoSchedule
```

## Removing taints

Removing a *taint* can be as easy as setting it, just append a minus sign
(`-`) at the end of the effect to indicate that you want to get rid of it.

The following gets rid of the first *taint* set in the previous section:

```
kubectl taint node "$NODE" has-feature=sriov:NoSchedule-
```

It works also for empty *taints* of course:

```
kubectl taint node "$NODE" has-feature=:NoSchedule-
```

While you must be very precise when setting a *taint* (i.e. you always have
to put a value, even if it's empty, and always specify an effect), you
can be more liberal when removing them. Suppose you set the following two
*taints* associated to key `somekey`:

```
kubectl taint node "$NODE" somekey=val1:NoSchedule somekey=val2:NoExecute
```

You can remove all of them in a single sweep by just "removing" the key:

```
kubectl taint node "$NODE" somekey-
```

This will work whatever value and/or effect were set for that key.

## A real world example

This post started from reading the [ovn-kubernetes][] documentation, that
contains the following:

    On Kubernetes master, label it to run daemonsets.
    
    ```
    kubectl taint nodes --all node-role.kubernetes.io/master-
    ```

Now I understand that:

- by default, *master* nodes are set with *taint*
  `node-role.kubernetes.io/master=:NoSchedule`, i.e. with key
  `node-role.kubernetes.io/master`, empty value and effect of
  `NoSchedule`;
- the command above removes all *taints* with the specific key, including
  the default one above;
- removing that *taint* means that everything can be scheduled on all nodes
  (unless there are additional *taints* resulting in `NoSchedule`, of
  course).


## Time's up

This is all I had to write about for this post. One final observation
though: you should not normally need to *remove a taint*, you probably want
to *set the right tolerations* on the resources. Read the [Taints and
Tolerations][k8s-tt] page to learn more!

[k8s-tt]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[kubernetes]: https://kubernetes.io/
[man-taint]: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#taint
[ovn-kubernetes]: https://github.com/ovn-org/ovn-kubernetes
