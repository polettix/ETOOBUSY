---
title: 'Evolving App::Easer'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-02-04 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm playing with some ideas to evolve [App::Easer][].

[App::Easer][] has a solid fanbase: me. I'm using it quite extensively
right now, and that's very good because I'm both enjoying it *and*
collecting constructive criticism about it.

You know, by me.

Anyway, there are two applications that started separated and I'm
thinking about joining (placing one under the other). For this reason,
I'm playing with some ideas to *extend* the current hierarchy definition
interface so that a few things can be done easily.

This is somehow at the border between the bloating and the actual
usefulness. On the one hand the system as-is allows me to do the merge
quite easily; on the other, there's some risk that this operation
creates a very big definition hash, which might play against
readability.

I already put some mechanisms to allow breaking the definition of
commands and put them elsewhere. I just feel that there might be
something more to it, so if I come up with a clean and easy way to do
this I'll add it.

In the meantime, I figured that it's quite easy to define the hierarchy
by placing commands definitions *directly* inside the `children` array
reference. This led to the current TRIAL release, with [minimal][]
[intervention][]. Andrew Harlan would be proud, I hope.

Well, enough rambling... stay safe everyone!


[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[minimal]: https://github.com/polettix/App-Easer/commit/20f583e46edd61aa9b0c7b5ee4fef9382957780a
[intervention]: https://github.com/polettix/App-Easer/commit/2f59aa09e1c439dff969e00531b88e97cc8e6175
