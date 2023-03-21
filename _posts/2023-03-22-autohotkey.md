---
title: AutoHotKey
type: post
tags: [ windows, keyboard ]
comment: true
date: 2023-03-22 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> It beats me that I had to use [AutoHotKey][] for two simple keys.

I'm Italian and I use the Italian keyboard layout. No big deal.

Up to some Windowses ago, I had to build my own custom keyboard layout
because, as it appears, neither the backtick nor the tilde are anywhere to
be found in the keyboard.

No, I don't consider typing the code on the numeric pad anything that is
meaningful to consider. *Especially* on a laptop keyboard without a separate
numeric pad.

As much as it already left me extremely dubious about the care that
Microsoft might have for foreigners, it went even beyond this. With Windows
11 (Home edition, at least) it seems that I'm **neither** able to install
the keyboard layout generator, **nor** able to install a previously cooked
layout.

So much for Windows Subsystem for Linux, right?

I looked around and found [AutoHotKey][], which is a big cannon to fire at a
mosquito, but still it's the only thing that seems to solve my problem. By
the way, these are the mappings that I added and work for me:

```
#Requires AutoHotkey v2.0
<^>!'::Send "``"
<^>!vkDD::Send "~"
```

I took inspiration from [this gist][], which in a turn of events didn't work
right off the bat for me. I don't know if it's because of the [AutoHotKey][]
version, or because quotation characters got lost in producing the gist, or
just because everything seems to necessarily be cumbersome and frustrating
when dealing with such basic needs.

My last thought is for the people who accept to type the Alt-whatever
combination on the numeric pad: there's a better way and you are encouraged
to not settle with such nonsense.

Rant concluded, stay safe folks!

[AutoHotKey]: https://www.autohotkey.com
[this gist]: https://gist.github.com/scollovati/3b4a6b44176797ff727f5c261c6b4975
