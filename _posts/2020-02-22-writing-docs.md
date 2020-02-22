---
title: Writing Documentation
type: post
tags: [ perl, coding ]
comment: true
date: 2020-02-22 13:25:51 +0100
preview: true
---

**TL;DR**

> Time and again, I figure that writing documentation is so important. But
> citing Michael Stevens of [Vsauce][]: *... or is it?!?*

I have a small library of functions/algorithms in [Perl][] on GitHub, named
[cglib-perl][]. I coded it specifically as a tight library of copy-and-paste
functions, which is not the best in terms of good coding practices but is
basically the only thing you can do when you solve problems in
[CodinGame][].

I'm partly proud and partly ashamed of that library. On the one hand, it is
(hopefully!) correct, very compact and... useful. The code is on the brink
of becoming the despised line noise that much took from [Perl][], but I
daresay still readable and understandable when you *already* know what the
specific function is supposed to do. On the other hand, it's terribly
under-documented.

So I happened to complete the documentation for one of the
modules/functions, namely [DepthFirstVisit][]. The [documents are
here][dfv-docs], by the way. And I happened to notice that the whole
function fits in a screen in both my editor and in the GitHub page at
[DepthFirstVisit][], while the docs definitely don't!

Is it still worth writing docs in this case? Wouldn't it just be easier to
read the code? Remember, the way these functions are supposed to be used is
by copy-pasting them!

I would argue that it still makes sense. If anything, it makes total sense
to provide a few things:

- a working example that shows the function in action, in true SYNOPSIS
  spirit

- a few words to explain the underlying data model where the function works
  on, so you don't have to re-figure it out from scratch.



[Vsauce]: https://www.youtube.com/user/Vsauce
[Perl]: https://www.perl.org/
[cglib-perl]: https://github.com/polettix/cglib-perl
[CodinGame]: https://www.codingame.com/
[DepthFirstVisit]: https://github.com/polettix/cglib-perl/blob/master/DepthFirstVisit.pm
[dfv-docs]: https://github.com/polettix/cglib-perl/blob/master/DepthFirstVisit.pod
