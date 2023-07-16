---
title: PlantUML starter
type: post
tags: [ uml, graph, plantuml ]
series: PlantUML
comment: true
date: 2023-07-15 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A starter graph that suits my needs.

Some days ago I had to draw a sequence diagram and my tool of choice is
[PlantUML][]. So there I went.

Only there's *always* something that I want to do, that is disable the boxes
at the bottom (*foot boxes*). This can be done by adding `hide footbox` at
the beginning, and I go looking for this option every single time.

Last time, though, I figured that I had been smart enough to write about
[PlantUML][pu], so I also included a starting example that was good for me,
*right*?

***No**, but this ends here.*

```
@startuml
hide footbox
actor "Foo" as p1
participant Bar as p2
control "Some Control" as c1

p1 -> p2: one message
p2 -> c1: another message
@enduml
```

![Starting image](//www.plantuml.com/plantuml/png/FOv12i8m44NtSufFzoxQPHTI5Bo09nZJqGQQ_92CuF4D5LpEUs_WBysr-ZljiiNLy2JzmOzeS5OCDtA0DfHHIizYY4MpuwBre9C4Pg_SCToP3DVVTRo4KQICE9rxDeFPaAmrVPcKgTFkPsYcRrR_Ph6yzYbV)

[Start a new diagram from this example][starter].

*There you go, slacker past me... was this so difficult?!?*

[PlantUML]: {{ '/2021/04/11/plantuml/' | prepend: site.baseurl }}
[starter]: https://www.plantuml.com/plantuml/umla/FOv12i8m44NtSufFzoxQPHTI5Bo09nZJqGQQ_92CuF4D5LpEUs_WBysr-ZljiiNLy2JzmOzeS5OCDtA0DfHHIizYY4MpuwBre9C4Pg_SCToP3DVVTRo4KQICE9rxDeFPaAmrVPcKgTFkPsYcRrR_Ph6yzYbV
[pu]: https://plantuml.com/
