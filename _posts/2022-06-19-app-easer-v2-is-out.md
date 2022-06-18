---
title: 'App::Easer V2 is out... and can be improved!'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2022-06-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I finally released V2 of [App::Easer][].

And it can be improved, of course! Like... documentation, more tests,
etc. etc. The usual elephants in the room, you know.

Anyway, I've been using it for some time in an ever-growing command-line
application, and I like using it. It gets reasonably out of the way by
providing what I need, so good job past me.

There are a couple of areas that might need some more thinking though.
One is the fact that options can be be inserted at many different
levels, namely at each tier of the hierarchy. So you might end up with a
command line like this:

```shell
foo --yadda --ook 10 bar --ahoy baz --no-galook
```

Remembering where the different options should be placed might be a
hassle, so I usually spill them from *parent* to *child* so that you can
put them wherever you want and leave with that:

```shell
foo bar baz --yadda --ook 10 --ahoy --no-galook
```

There's already a sophisticated mechanism that lets children inherit
only a part of the options, because others might not make sense in a
specific branch of the hierarchy. I'm not 100% convinced of the
interface though.

If you give it a try, please ring a bell and tell me what you think. But
above all, stay safe!

[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
