---
title: Things to study
type: post
tags: [ perl ]
comment: true
date: 2022-02-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Taking note of a few things to study.

After using [App::Easer][] for a bit I'm quite happy with the thing -
usable and gets reasonably out of the way. But, of course, there's
always space for improvement, *especially* if it's an occasion to learn
more.

Things that, at this point, I think would be cool:

- making it possible to encapsulate each command inside its own package
  very, very easy. This does not mean that I want to give up on the
  *everything in a hash* approach, which I still think is great for
  small applications; just to make it super-slick to do otherwise.
- Ease attaching application as sub-commands of other applications.
- Make it possible to define package-based applications as [modulino][]s
  too.
- Probably coalesce the definition of the application and the definition
  of the command(s). In a lot of places in the code the application acts
  as a fallback for stuff that can be in the command specification too,
  so I might consider making it simpler.
- Probably adopt a proper OO-oriented style. The current implementation
  is *sort-of* object oriented, much like you would do in C: keep track
  of stuff in an "object", passed as the first argument to functions.
- Think about a proper interface for callbacks. At the moment they're
  more or less the same, i.e. "pass everything because everything can
  come handy". I still think this flexibility is a value, just probably
  it can be turned into something more reasonable.
- Migrate to a versioning for the API provided by the module, so that it
  will be possible to migrate across different versions.

Well, not necessarily in this order - e.g. the migration to a versioning
system is somehow a pre-requisite to keep backwards compatibility.

> Please note that I'm not deluding myself about the **need** to keep
> backwards compatibility. It's just an occation to learn how to do
> things properly!

One thing that I *think* will come handy is the mechanism that is used
e.g. by [Role::Tiny][] to augment a class of role-based methods. I took
a look at the module, but a lot of the stuff there is to turn a package
*into* a role, which will eventually do its magic when included in
another class. An interesting read, anyway.

[Perl]: https://www.perl.org/
[modulino]: https://gitlab.com/polettix/notechs/-/snippets/1868370
[Role::Tiny]: https://metacpan.org/pod/Role::Tiny
[App::Easer]: https://metacpan.org/pod/App::Easer
