---
title: Peek in containers
type: post
tags: [ docker, shell ]
comment: true
date: 2020-11-29 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Sometimes you might want to see *inside* a [Docker][] container's
> networking stack but you might not even be able to run a shell inside the
> container, or lack basic tools like `ip`, `ss`, `tcpdump`.

I'm grateful that [this question on StackOverflow][question] got interesting
answers. In particular, the one referring to `nsenter` was particularly
interesting for me... because I happened to actually *have* it available
inside the host machine.

So here's `peek`, which requires `nsenter` and `sudo` to work properly:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2043119.js"></script>

[Local version here][]. It can be used as a script or as a library, in full
[POSIX shell "modulino"][] style.

It can be used like this:

```shell
$ container='<container name or id...>'

$ peek "$container" ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: eth0@if119: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1430 qdisc noqueue state UP group default
    link/ether 92:97:6d:91:ee:52 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.245.176/32 scope global eth0
       valid_lft forever preferred_lft forever

$ peek "$container" ss -tunapl
Netid  State   Recv-Q  Send-Q  Local Address:Port  Peer Address:Port
udp    UNCONN  0       0       127.0.0.1:32264     0.0.0.0:*          users:(("perl",pid=...
tcp    LISTEN  0       5       *:47683             *:*                users:(("perl",pid=...

$ peek "$container" tcpdump -i any
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
```

Note: the last command listens to traffic in *localhost* too!

Happy peeking!

[question]: https://stackoverflow.com/questions/31265993/docker-networking-namespace-not-visible-in-ip-netns-list
[Docker]: https://www.docker.com/
[Local version here]: {{ '/assets/code/peek' | prepend: site.baseurl }}
[POSIX shell "modulino"]: https://gitlab.com/polettix/notechs/-/snippets/1868379
