---
title: Command-line editing
type: post
tags: [ terminal ]
comment: true
date: 2023-03-25 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> `Ctrl-X Ctrl-E` for the win!

So everyone knew except me. I blame you all for this.

I mean, I *knew* that there was such a thing like [Command-line
editing][cle], **but** I thought it was limited to `Ctrl-r` to search
backwards.

To my surprise (why was I surprised?), I eventually discovered `Ctrl-X
Ctrl-E`, which brings the *editing* part to its extreme: open the editor
and leave it the heavylifting.

Which is both genius, obvious **and** infuriating. (I know, *both* is for
two, but it was infuriating anyway 🤬).

As an added bonus, I also discovered about `Ctrl-X *`. If you're wondering,
it expands a glob into the corresponding list directly on the command line.
It's a bit of a niche use case, but it can be useful when you have a bunch
of files you want to work on and you *only* want to get rid of a couple
before running your command. Although, admittedly, I'll probably have
forgotten about it by tomorrow 🙄.

So there you go, future me: you will not be able to say I didn't tell you!

[cle]: https://www.gnu.org/software/bash/manual/bash.html#Command-Line-Editing
