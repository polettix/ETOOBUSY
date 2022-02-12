---
title: "App::Easer V2 - let's start!"
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-02-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I started working on the next iteration for [App::Easer][].

I told it, and I'm doing it.

The first move has been to move the currently published stuff to
`App::Easer::V1` and defaulting to it. I'm not really required to keep
backwards compatibility, but it's an interesting occasion for study.

Unfortunately, it's also a pretty narrow one, because the same reason
why I don't have to keep backwards compatibility (i.e. lack of adoption
of the module) puts me in a solitary echo chamber in which I can only
spot shortcomings that might come from... me. Which puts me back to
square one, because I'm also in the solitary echo chamber of people
eager to migrate to the new version `¯\_(ツ)_/¯`.

> This is getting on my nerves, this guy keeps repeating what I say.

Anyway, I also started fleshing out V2, porting the code from V1 and
adopting a new interface that I like better:

- it's properly object-oriented, with less stuff flying around, proper
  methods and hopefully full openness for overriding. I'm not sure how
  it's going to play with [Moo][]/[Moose][], V2 is definitely more
  opinionated but not *this* opinionated.
- It's still possible to define commands using hashes with data inside.
  Actually, it's possible to mix the two things, setting the static part
  in a hash reference and the dynamic part in overridden methods.
- The children hierarchy is now automatically learned, while it's still
  possible to push things inside though. While I still think that it was
  not *that* hard for the application writer to do this one-time
  housekeeping task, there's definitely a sane way to make the computer
  do this so why not.
- Initial tests are encouraging, I also managed to port the example
  application and I like what has come out.

If you're curious... [the current status][].

[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[Moose]: https://metacpan.org/pod/Moose
[Moo]: https://metacpan.org/pod/Moo
[the current status]: https://github.com/polettix/App-Easer/blob/725edd8ec95e393304fb37881a4904fa743cebea/lib/App/Easer/V2.pm
