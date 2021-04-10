---
title: PlantUML Docker image
type: post
tags: [ uml, graph, plantuml, docker ]
series: PlantUML
comment: true
date: 2021-04-13 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It's easy to run a personal version of the [PlantUML][] [online
> server][].

In previous post [PlantUML Online Server][] we saw how easy it is to
generate a diagram online with [PlantUML][] and possibly embed it in a
page.

This, of course, assuming that the [online server][] is... online.

If you want to keep your diagrams super-secret, or simply can't access
*the outside* from where you want to place your links to a diagram,
there's a solution: a personal installation of the online server using
the [PlantUML Docker image][].

It is easily run, e.g. this starts it locally and lets you point the
browser to [http://localhost:8080](http://localhost:8080):

```
docker run -d -p 8080:8080 plantuml/plantuml-server
```

I tried it and... it works!

[PlantUML]: https://plantuml.com/
[online server]: http://www.plantuml.com/plantuml/uml/
[PlantUML Online Server]: {{ '/2021/04/12/plantuml-online-server/' | prepend: site.baseurl }}
[PlantUML Docker image]: https://hub.docker.com/r/plantuml/plantuml-server
