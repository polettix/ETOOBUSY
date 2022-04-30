---
title: 'Curious about Dungeons & Dragons'
type: post
tags: [ rpg ]
comment: true
date: 2022-04-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm curiuos about Dungeons & Dragons and Role-Play Gaming at large.

Curiosity does not mean I will like it, anyway, especially considering
that it seems to require quite some time and I'm not sure I even have
that time to invest.

So I'm looking for some smaller experience to get the taste of it and
decide whether to go more in depth or not. To this regard I thought to
start with a *Play-by-Post* site, so that I will not waste anyone else's
time either, and I found [this post on Reddit][] about a Discord server.

Being a total newbie, this was a bit... *daunting*. Lot of jargon,
instructions seem clear although a bit blunt and the reliance on outside
tools like [D&D Beyond][beyond] and [Avrae][] just add to the
complexity.

Even following the instructions and sticking with some of the more
*beginner-friendly* things is prone to roadblocks. As an example, I
chose to be a *dwarf* (remember [Urist McLumberjack][umc]?!?) and had to
choose between one from the *hills* and one from the *mountain*. Then,
at some time, it becomes clear that telling the game I'm a
*Mountaindwarf* will get me nowhere:

![Mountaindwarf is nowhere to be found]({{'/assets/images/mountaindwarf-error.png' | prepend: site.baseurl }})

So it seems that I can access what goes under the name of [Systems
Reference Document][srd], which includes *dwarves*, *hill dwarves* but
**not** *mountain dwarves*. What The... Fiction!

It then turned out that it's possible to import additional stuff of this
like (I'm not even sure what this stuff will be used for), by using the
following JSON as a *global variable* in [Avrae][]:

```json
[
 {
  "name":"Mountain Dwarf",
  "counters":[],
  "cvars":{
   "race":"Mountain Dwarf",
   "speed":"25 ft.",
   "languages":"Common, Dwarvish",
   "size":"Medium",
   "creatureType":"Humanoid",
   "resist":"Poison",
   "immune":"",
   "cimmune":"",
   "vuln":"",
   "senses":"Darkvision 60 ft."
  }
 }
]
```

I could not find it anywhere else, so there you go.

So far I'd say that this experience is not encouraging. I'll probably
better find something less *computerish* to get started and have an
idea, we'll see.

Stay safe everybody!

[this post on Reddit]: https://www.reddit.com/r/pbp/comments/ua3r9r/myths_of_trye_discord_5e_dnd_server/
[beyond]: https://www.dndbeyond.com/
[Avrae]: https://avrae.io/
[umc]: {{ '/2019/12/07/urist-mclumberjack/' | prepend: site.baseurl }}
[srd]: https://dnd.wizards.com/resources/systems-reference-document
