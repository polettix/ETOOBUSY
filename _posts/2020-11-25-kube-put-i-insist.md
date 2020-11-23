---
title: Put a file in a Kubernetes Pod, I insist
type: post
tags: [ kubernetes, shell ]
comment: true
date: 2020-11-25 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> What if you want to put a file in a container inside a [Kubernetes][]
> [Pod][] but it does not have a shell?

In [Put a file in a Kubernetes Pod][] we saw that if [`kubectl cp
...`][kubectl-cp] fails you because the target container does *not* have
`tar` installed, it's still possible to try a work-around if there is at
least a *shell*.

What if you don't have the shell and you need one to take a look around?

> **CAVEAT** take everything that follows with a grain of salt.

# Mudding your hands

Assuming that the underlying containerization scaffolding is based on
[Docker][], we can attempt at accessing its filesystem *directly from the
host*.

So, assuming you have the container identifier at hand (more on this later),
you can first get the *process identifier* it is associated to:

```shell
pid="$(sudo docker inspect "$cid" | jq '.[0].State.Pid)"'
```

If you don't have [jq][] installed, the following should get you up to speed
anyway:

```shell
sudo docker inspect "$cid" | grep Pid
pid='...' # read from previous output
```

Now the trick is this: *you can access the container's root directory via
`/proc/$pid/root`*. Yes, it's as simple as this.

So you want to put a file there? Copy it to destination! E.g. put it in the
container's root directory:

```shell
sudo cp /path/to/source/file "/proc/$pid/root/"
```

# Adapting to Kubernetes

The technique above is pretty low-level and needs some additional machinery
to be adapted to [Kubernetes][].

Let's recap our starting point in the previous section: we must be in the
right host (i.e. the one where the container is running) and we know the
identifier for the container we are after.

Let's assume that we have our [Pod][] name in variable `pod`, the
*namespace* in variable `ns`, the *container* name in `container`. This is
all we need to query our [Kubernetes][] cluster for the additional
information we are after.

## Locating the host

First of all, let's find out where the [Pod][] is running (i.e. the *worker
node*'s IP addres):

```
worker_ip="$(kubectl get -o jsonpath='{.status.hostIP}' \
             -n "$ns" "pod/$pod)"
```

Now that I notice it, this might be a wonderful alias or shell function:

```
alias worker_of="kubectl get -o jsonpath='{.status.hostIP}'"
```

## Locating the container

Now let's find out the container identifier:

```shell
# container identifier query
ciq="{.status.containerStatuses[?(.name == \"$container\")].containerID}"
cid="$(kubectl get -o jsonpath="$ciq" -n "$ns" "pod/$pod" \
       | sed -e 's#^docker://##')"
```

If you're not sure what the target container is named like, you can print
them all:

```shell
# container identifier list query
cilq='{range .status.containerStatuses[*]}{.name} {.containerID}{"\n"}{end}'
kubectl get -o jsonpath="$cilq" -n "$NAMESPACE" "pod/$POD_ID"
cid='...' # set from output of command above
```

Now we're all set!

# Conclusions

Putting a file in a container inside [Kubernetes][] can be a daunting
process if the container is not cooperating... but there are definitely ways
to do this!

[Put a file in a Kubernetes Pod]: {{ '/2020/11/24/kube-put/' | prepend: site.baseurl }}
[Kubernetes]: https://kubernetes.io/
[Pod]: https://kubernetes.io/docs/concepts/workloads/pods/
[kubectl-cp]: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#cp
[Docker]: https://www.docker.com/
[jq]: https://stedolan.github.io/jq/
