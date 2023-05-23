---
title: Relying on CPAN modules
type: post
tags: [ perl ]
comment: true
date: 2023-05-23 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An [interesting article][] by [Dave Cross][].

I recently read [Mission (Almost) Accomplished][interesting article] by
[Dave Cross][] and it resonated so much. Both in the general sense of
contributing to open source at large, both in contributing to [Perl][]
modules.

Anyway, I was struck by the closing words:

> But I do think that relying on CPAN modules has got harder over the last
> few years. And it’s not going to get easier any time soon.

Here, I think, a lot of people will resonate. Combined with the rest of the
article, especially the parts where it's apparently *very* difficult to get
a module updated (or even get the small bit of attentions for that), started
a train of thoughts.

The CPAN is structured in a first-come, first-served approach. Do you want
to release `Foo::Bar::Baz`? Just go, as long as it's not already used
somewhere else. This worked mostly fine for a long time, but it's also prone
to some modules just left rotting there, abandoned. 

It struck me that there's another *thing* that is basically just names in
the internet, that is domain names. Sure they have some similarities
(they're hierarchical in shape) and many differences (being in hierarchy
might or might not mean anything, and controlling a "base" module does not
give any control over sub-modules).

Fact is that domain names were immediately recognized as a scarce resource,
which meant they were monetized (which is... not that good, IMHO) but also
somehow regulated. I mean this in the sense that you *at least* have to put
some little effort every now and then to keep the domain name.

It would be interesting to "claim" a name but only get to keep it as long as
you're willing to at least show some care. Which does not necessarily mean
releasing a new version; just that you put some small effort to say *I'm
here and I'm still interested into managing this module*.

I'd like to be able to mark my modules as "voluntarily relinquished unless a
box was ticked within some time", or something like this. Just like you have
to login and confirm your presence in a lot of services around.

This is just an idea. Something that might start telling what's being thrown
in a black hole and what is at least worth considering because you might
eventually take over instead of forking.

OK, enough for one s(im\|tu)p(le\|id) idea... stay safe everybody!


[Perl]: https://www.perl.org/
[interesting article]: https://perlhacks.com/2023/05/mission-almost-accomplished/
[Dave Cross]: https://perlhacks.com/about/
