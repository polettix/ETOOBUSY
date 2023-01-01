---
title: 'Local to remote port forwarding with socat'
type: post
tags: [ socat, networking, linux ]
comment: true
date: 2022-03-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Using [socat][] to listen on a local port and send the traffic to a
> remote host/port.

Often times I work in a [Linux][] VM in a Mac (using [VirtualBox][]),
doing some remote connectivity from within the VM.

I'm lazy though, so I never fiddled too much with the graphics setup
inside the VM. As a result, stuff in the browser might appear a bit
*little*, and I like using the browser on the Mac side using some port
mapping in [VirtualBox][].

Recently I wanted to see a *remote* destination to which I can connect
only from the [Linux][] VM. I was wondering on connecting to the VM via
SSH and do some port forwarding, but then it occurred to me that
[socat][] could *surely* help me with this.

And it surely did:

```
socat TCP-LISTEN:54321,fork TCP:remote.example.com:12345
```

This opens *local* port `54321` listening for incoming connection,
replicating and stitching them with a connection to port `12345` in
remote host `remote.example.com`.

At this point, I only had to map local port `54321` from the [Linux][]
VM to the Mac and I could use the browser on the Mac to see
`remote.example.com:12345`, passing through the connection set up by the
VM.

I hope you can find this useful too, stay safe everybody!

[VirtualBox]: https://www.virtualbox.org/
[socat]: http://www.dest-unreach.org/socat/
[Linux]: https://www.kernel.org/
