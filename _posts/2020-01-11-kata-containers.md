---
title: Kata Containers
type: preview
tags: [ container, linux, kubernetes, gist ]
comment: true
published: true
date: 2020-01-11 08:00:00
---

**TL;DR**

> I recently looked into [Kata Containers][], it's interesting to see what
> they are for.

Container-based technologies are amazing and eased the evolution of a lot of
interesting stuff. We'll not talk about it here!

One popular simplification is that containers fit in a lot of places where
some years ago you would have probably used a virtual machine, where:

- containers are much faster to spin up and shut down;
- virtual machines allow a better isolation of workloads.

The goal of [Kata Containers][] is to try to keep the isolation provided by
the virtual machines, while still benefitting of way faster start-up times.

I think that the definition given at the beginning of [this video][kc-video]
is extremely helpful:

> What are Kata Containers?
>
> You're taking your container and we're looking to add an extra layer of
> isolation. So we're not saying that containers are terrible, it's just we
> think that defence at depth makes a lot of sense, depending on your
> security profile. So what we do on a per-container basis, or per-Pod if
> you're in the Kubernetes space, is launch a lightweight virtual machine
> and inside of that instantiate your container, and the rest of it is just
> us doing plumbing so that way it's not a lot of overhead for you and that
> just works.

One interesting aspect of [Kata Containers][] is that the machinery to bring
them up closely mimics that of spinning up containers as done by
[runc][]. This means that - from what I understood - it provides a drop-in
replacement for [runc][] and also that all higher level machinery - notably,
[kubernetes][] - should *just work*.

## Want to know more?

There's a lot to read around about [Kata Containers][]. An interesting
article, providing a view about the history of the project, is this: [Kata
Containers: Secure, Lightweight Virtual Machines for Container
Environments][kc-other].

Happy reading!

[Kata Containers]: https://katacontainers.io/
[kc-video]: https://www.youtube.com/watch?v=FZr1v08Oyic
[kc-other]: https://thenewstack.io/kata-containers-secure-lightweight-virtual-machines-container-environments/
[runc]: https://github.com/opencontainers/runc
[kubernetes]: https://kubernetes.io/
