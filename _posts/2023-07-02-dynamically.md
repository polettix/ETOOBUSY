---
title: dynamically
type: post
tags: [ perl ]
comment: true
date: 2023-07-02 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I discovered about [Syntax::Keyword::Dynamically][].

So it seems that we're about to receive a big gift, i.e. [Perl][] version
5.38 with its shiny new CORE & modern object system.

> I like the minimalism of the traditional object system, but it's more of a
> **framework** considering how many systems have been built upon it.

So I thought of giving *a read* to [Object::Pad][]'s documentation, which
apparently is the precursor of the system. It's been a nice read but of
course it amounted to about 0 because I will not know anything until I try
that out. Anyway, at least I know that there's documentation about *stuff*.

While reading through it, I discovered [Syntax::Keyword::Dynamically][],
which lets us introduce a `dynamically` keyword that is kind of a
super-duper `local`, but including lexicals and lvalues as well. Well, how
cool!

So well, I'm not sure I'm going to use it in the future, because I also
rarely use `local` itself and the SYNOPSIS example is barely applicable in
my case (it assumes lvalues for setting a logging level, and [my favourite
logging module][Log::Log4perl::Tiny] does not support it 😅) and I would
probably go for a [Guard][] instead.

> Despite what might seem from the last paragraph, I do find
> [Syntax::Keyword::Dynamically][] brilliant and I'm not trying to upset
> [Paul Evans][]!

[Perl]: https://www.perl.org/
[Syntax::Keyword::Dynamically]: https://metacpan.org/pod/Syntax::Keyword::Dynamically
[Object::Pad]: https://metacpan.org/pod/Object::Pad
[Guard]: https://metacpan.org/pod/Guard
[Paul Evans]: http://www.leonerd.org.uk/
[Log::Log4perl::Tiny]: https://metacpan.org/pod/Log::Log4perl::Tiny
