---
title: 'Doubting about Accounting::Kitty'
type: post
tags: [ perl ]
comment: true
date: 2021-10-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I have some doubts about the worth of [Accounting-Kitty][].

After one exact month since writing [Accounting::Kitty on GitHub][],
little to nothing changed.

Well, actually...

- the project did not advance
- I discovered [Ledger & co.][] and found it great, cleaner, you name it
- I discovered some *future bugs* in the module.

The last bullet deserves some explanation for future me:
`Accounting::Kitty` was born out of some specific code to cope with a
specific project, trying to make it general. It turns out that there are
things that are not so *strictly* bound to a project, and risk to mess
things up as soon as multiple projects and quotas are brought on the
scene.

For this reason, there's no *immediate* but in what I'm using (which is
not based on `Accounting::Kitty` and is actually a predecessor), but
using `Accounting::Kitty` in its full *promised power* is likely to let
the bug(s) emerge.

So I'm wondering... is it worth to invest some time on it, or should I
aim for something different?


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Accounting-Kitty]: https://github.com/polettix/Accounting-Kitty
[Accounting::Kitty on GitHub]: {{ '/2021/09/17/kitty-on-github/' | prepend: site.baseurl }}
[Ledger & co.]: {{ '/2021/09/18/ledger/' | prepend: site.baseurl }}
