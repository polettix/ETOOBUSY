---
title: Lured by overengineering
type: post
tags: [ perl, coding ]
comment: true
date: 2022-11-15 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I did it again.

I'm working on a little website for helping people getting started and
up to speed in using [The GNU Privacy Guard][gnupg].

My idea is to generate many little pages with one or a few sentences
each, then creating *trails* connecting them together for explaining the
different tasks. As an example, *receiving* stuff will mean installing,
creating a key pair, providing the public key to the Sender, receiving
encrypted stuff and decrypting it. On the other hand, *sending* has some
overlapping (like installing and generating a key pair) and other steps
that are peculiar.

Of course this means I'd like to reuse stuff as much as possible across
the different trails, which means *some coding needed*. Which, in turn,
means *wheel reinventing and overengineering season is officially open,
folks!*.

To my defense, I tried *hard* (about 1 hour) to look into systems that
*already* do this. The best thing I could find is *interactive fiction*
programs that target HTML, but still most of them seem to target
HTML+Javascript actually, while I'm aiming at a purely-static site
experience.

If I'm not too ashamed, I'll share something about this new wheel in the
coming days. For now... stay safe!

[Perl]: https://www.perl.org/
[gnupg]: https://www.gnupg.org/
