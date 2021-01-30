---
title: Cardstom - more flexible
type: post
tags: [ perl, board game, svg ]
series: Playing Cards with SVG
comment: true
date: 2020-08-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Cardstom][initial-cs] was a bit stiff, let's make it a bit more
> flexible.

One defect of the [initial version of cardstom][initial-cs] was that it
generated a whole bunch of red clubs and spades cards, as well as black
hearts and diamonds.

There's an idea that goes on in my mind with labels and so on, but to
start easy I thought about implementing the generation of multiple
smaller series from the same configuration file.

So, the current configuration file for the example has this shape:

```text
 1 {
 2    "card-config": {
 3       "width": "62mm",
 4       "height": "88mm"
 5    },
 6    "output": "output",
 7    "A": [
 8       {"-name":"A","-path":"input/alphanum/A-uppercase.svg"},
 9       {"-name":"2","-path":"input/alphanum/2-digit.svg"},
10       {"-name":"3","-path":"input/alphanum/3-digit.svg"},
11       {"-name":"4","-path":"input/alphanum/4-digit.svg"},
12       {"-name":"5","-path":"input/alphanum/5-digit.svg"},
13       {"-name":"6","-path":"input/alphanum/6-digit.svg"},
14       {"-name":"7","-path":"input/alphanum/7-digit.svg"},
15       {"-name":"8","-path":"input/alphanum/8-digit.svg"},
16       {"-name":"9","-path":"input/alphanum/9-digit.svg"},
17       {"-name":"T","-path":"input/alphanum/10-pair.svg"},
18       {"-name":"J","-path":"input/alphanum/J-uppercase.svg"},
19       {"-name":"Q","-path":"input/alphanum/Q-uppercase.svg"},
20       {"-name":"K","-path":"input/alphanum/K-uppercase.svg"}
21    ],
22    "led1":[
23       {"-name":"_"},
24       {"-name":"hops","-path":"input/game-icons/delapouite/hops.svg","-scale":1}
25    ],
26    "led2":[
27       {"-name":"_"},
28       {"-name":"corn","-path":"input/game-icons/delapouite/corn.svg","-scale":1}
29    ],
30    "led3":[
31       {"-name":"_"},
32       {"-name":"acorn","-path":"input/game-icons/lorc/acorn.svg","-scale":1}
33    ],
34    "sequence": [
35       {
36          "color": [
37             {"-name":"red","value":"#900"}
38          ],
39          "B": [
40             {"-name":"hearts",  "-path":"input/game-icons/skoll/hearts.svg"},
41             {"-name":"diamonds","-path":"input/game-icons/skoll/diamonds.svg"}
42          ]
43       },
44       {
45          "color": [
46             {"-name":"black","value":"#000"}
47          ],
48          "B": [
49             {"-name":"clubs",   "-path":"input/game-icons/skoll/clubs.svg"},
50             {"-name":"spades",  "-path":"input/game-icons/skoll/spades.svg"}
51          ]
52       }
53    ]
54 }
```

Everything at the higher level is still taken as the *default* stuff. If
a `sequence` key is present, it is iterated specializing the
configuration for each round; otherwise, only the upper level
configuration is used, to retain backwards compatibility.

Now it generates the regular French cards out of the box!

[initial-cs]: https://github.com/polettix/cardstom/tree/5bb521323cceb3d6576bbeae9552aa680e744e22
[this-cs]: https://github.com/polettix/cardstom/tree/a49d21f6acfc706eb8702793a287639c78e8517d
