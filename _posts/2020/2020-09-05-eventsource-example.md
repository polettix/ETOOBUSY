---
title: EventSource example
type: post
tags: [ mojolicious, web, perl ]
comment: true
date: 2020-09-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An alternative example for the [EventSource web service][].

In previous post [Fixing an example in Mojolicious][] I bragged about
how fixing a small issue in an example makes me feel part of the
community. By the way, I think you should participate in the community
and brag about it too!

I was looking at that example because I was interested into the
[EventSource][] API for a small project involving a game, rolling some
dice on the web and being able to play at a distance with physical stuff
(apart from the dice, of course). Hopefully more on this in the future.

I modified the example in the [Mojolicious][] [Cookbook guide][] to fit
my example, here's the code:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2011120.js"></script>

I guess you know how to start it, so I won't bother you here.

After the program is started, you can try it on the local host like
this:

- decide a name for your *box*, for example `foo`
- point a couple of browser windows to
  [http://127.0.0.1:3000/box/foo](http://127.0.0.1:3000/box/foo) - you
  should see that a number between 0 and 99 (included) is shown in both
  (the same number);
- use another browser window, or a command line `curl` command, to
  trigger the generation of a new value using url
  [http://127.0.0.1/tickle/foo](http://127.0.0.1/tickle/foo) - you
  should see it appear in both windows
- open another browser window to
  [http://127.0.0.1:3000/box/foo](http://127.0.0.1:3000/box/foo) - you
  should just see the last number that was generated in it

If you use `bar` instead of `foo` you will look into a different
*box*... with a different sequence of numbers.

I know, I know... I should have used a POST and not a GET... but it's a
proof of concept!

[EventSource web service]: https://metacpan.org/pod/Mojolicious::Guides::Cookbook#EventSource-web-service
[Fixing an example in Mojolicious]: {{ '/2020/09/04/drop-by-drop'| prepend: site.baseurl }}
[Cookbook guide]: https://metacpan.org/pod/Mojolicious::Guides::Cookbook
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Perl]: https://www.perl.org/
[EventSource]: https://en.wikipedia.org/wiki/Server-sent_events
