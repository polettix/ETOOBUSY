---
title: Mininet polygon topology
type: post
tags: [ mininet, python, sdn ]
comment: true
date: 2021-03-19 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A polygonal topology for [mininet][].

I'm studying a course about [Software Defined Networking][SDN] and I'm
enjoying [mininet][] to do the lab sessions:

> Mininet creates a realistic virtual network, running real kernel, switch
> and application code, on a single machine (VM, cloud or native), in
> seconds, with a single command.

It's easy to create different *topologies* (e.g. a linear arrangement of
switches, or a tree) and it's also easy to add more topologies. Here, we're
talking about adding a loopy topology that implements a polygon.

Consider the following `polygon.py`:

```python
from mininet.topo import Topo

class Polygon(Topo):
    def __init__(self, n = 3, **kwargs):
        super(Polygon, self).__init__(**kwargs)

        first_switch = None
        last_switch  = None
        for i in range(n):
            s = self.addSwitch('s' + str(i + 1))
            h = self.addHost('h' + str(i + 1))
            self.addLink(s, h)
            if last_switch:
                self.addLink(last_switch, s)
            else:
                first_switch = s
            last_switch = s

        # close the loop if it makes sense...
        if n > 2:
            self.addLink(last_switch, first_switch)

topos = { 'polygon': ( lambda *args, **kwargs: Polygon(*args, **kwargs) ) }
```

The implementation is *nearly* straightforward, although it contains
something that I didn't find elsewhere and that took me some time to create,
because I'm not much fluent in Python:

```python
topos = { 'polygon': ( lambda *args, **kwargs: Polygon(*args, **kwargs) ) }
```

This last line adds the `polygon` topology so that it can then be retrieved
while calling the [mininet][] executable:

```shell
$ sudo mn --custom /path/to/polygon.py --topo polygon ...
```

What took me time is how to pass optional parameters to the lambda function.
In hindsight, I should have looked for `lambda` immediately, as this has
more to do with Python than with [mininet][]; in reality, though, I wasted
time under the (wrong) assumption that *there has to be an example to do
this somewhere in internet*.

Well... today there is one such example 😎

Stay safe!


[mininet]: http://mininet.org/
[SDN]: https://en.wikipedia.org/wiki/Software-defined_networking
