---
title: 'Coding discipline: resist premature generalization'
type: post
tags: [ perl, coding ]
comment: true
date: 2023-05-28 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Another epiphany about coding discipline: get to something that actually
> works  before generalizing it.

I've always been a fan of refactoring, to the point that I'm often inclined
to *factor* instead of *re-factor*.

What I mean is that I think about doing something --let's say the sum of two
and three-- and my brain immediately starts with generalization challenges,
like *what about summing any two integers*? *Why not numbers in general*?
*Hey, what about complex numbers, or any possible field*? *Why are we
considering sum only, and not any possible binary operation*? You get the
idea.

Result: I'm down a rabbit hole when I only needed to sum two and three, and
I definitely hear *five* laughing somewhere out there.

So, in addition to [premature optimization is the root of all evil][po],
I'll add *premature generalization is pretty bad too*. To some extent, a
generalization can be seen as an optimization, so it's nothing new right?

As a discipline, I'll try to reach *something working* as soon as possible,
and then *consider* if generalizing it makes sense or not. At least I will
have something, shut the vicious *five* up and feel less frustrated!

Cheers!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[po]: https://wiki.c2.com/?PrematureOptimization
