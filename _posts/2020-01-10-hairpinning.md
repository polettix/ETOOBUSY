---
title: Hairpinning
type: post
tags: [ ]
comment: true
date: 1972-11-09 07:30:00
published: true
---

**TL;DR**

> Curious about what *hairpinning* stands for? Look no further!

I recently re-discovered what *hairpinning* is in the context of networking.
So I thought it better to write a little post about it, just to fix it in my
memory once and for all!

## It's easier with a picture

Let's consider the following example setup:

![hairpinning example]({{ '/assets/images/2020-01-hairpinning.png' | prepend: site.baseurl | prepend: site.url }})

We have:

- two servers *Server 1* and *Server 2*
  - *Server 1* exposes a service *srv1* on port 54321 from its local address
    10.0.0.2
  - *Server 2* exposes a service *srv2* on port 12345 from its local address
    10.0.0.3
- a load balancer/proxy that exposes the two services via NAT and port
  translation:
  - *srv1* is exposed on port 5432 from the external address 1.0.0.1
  - *srv2* is exposed on port 1234 from the external address 1.0.0.1

As an example, when a client connects to the external endpoint 1.0.0.1:5432,
the load balancer/proxy will forward this connection towards 10.0.0.2:54321.

## How does *Server 1* access *srv2*?

It's pretty easy to see that *Server 1* can reach *srv2* on the other server
by just connecting to 10.0.0.3:12345 - after all, both servers are connected
on the same internal network 10.0.0.0/24 and can thus reach each other
directly.

This might not always be doable or easy to accomplish, though. As an
example, *Server 1* might discover about *srv2* in the same way as external
clients would, hence it might not know that *srv2* is also accessible from
the internal network.

The situation in which *Server 1* tries to reach *srv2* from its *externally
visible* endpoint (i.e. 1.0.0.1:1234) instead of the directly connected one
is called **hairpinning**. Yes, it's as simple as this.

Depending on the load balancer/proxy, this might actually work or not. In
other terms, hairpinning must be supported by it, and possibly also be
configured to work. Beware!

## Enough said...

... comments welcome!
