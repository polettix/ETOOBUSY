---
title: Command-line programs containerization
type: post
tags: [ container, command line ]
comment: true
date: 2023-05-14 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some reflections about containerizing command-line applications.

In time I've found useful to put some command-line applications in a
container (e.g. [graffer][]), because I think it's a cool way to pack all
dependencies together and make life easier for the recipients. To some
extent, it mimics MacOS's way of having tightly packaged applications.

In time, this led me to develop some intermediate layers in the form of
elaborate *entrypoint* programs, which are most of the times shell programs
that support invoking several different facilities inside the container, be
it dispatching a call to the right internal tool (when I package more than
one, like again in [graffer][]) or accessing ancillary stuff (e.g. help
text, etc.).

And yet, this is still *not perfect*. One thing that might hit is that,
sometimes, it can be useful to have *common* stuff consumed by these images.
At the moment, I have *fonts* in mind, which are usually *not* something
that you need a specialized version for, so it's perfectly acceptable to get
them from the *host* instead of getting them from the container.

This is usually addressed in the *driver* shell program that wraps the call
to the container image, making sure to e.g. mount the current directory
somewhere *inside* the container, so that files can be read and written.
It's probably a matter of adjusting those wrappers, although this puts the
game at a totally different level, because things like fonts might be spread
all over the place and exposing them to the container would mean getting in
the semantics of this.

Maybe the solution might be to have some *specific* shell tools that can
help these wrapper scripts to solve this kind of problems, solving the
specific issue once and for all (e.g. providing a way to mount all available
font directories, or whatever), without reinventing too many wheels.

Time will tell, stay safe!

[Perl]: https://www.perl.org/
[graffer]: {{ '/2020/10/17/graffer/' | prepend: site.baseurl }}
