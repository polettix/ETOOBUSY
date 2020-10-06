---
title: Stockpiling blog posts
type: post
tags: [ blog, git ]
comment: true
date: 2020-10-07 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Sometimes I can write a few posts ahead of time... but stockpile them
> for publishing when I run out of time. [Git][] helps.

Writing posts ahead of time in this blog allows me to keep up with a
self-promise of publishing one post per day. Which is a reasonable proxy
for *writing* one post per day, at least on average.

This leads me to a little issue though. If I have a few canned posts -
let's say three - it means that if I discover something cool I'll
publish about it only later than three days.

Now, admittedly some posts here have a sort of... *filler taste*, if you
will, so it's better to have two different speeds and leave the filler
stuff for when I'm short with time.

The solution I though about is the following:

- Write these fillers and set to a time very ahead in the future - like
  200 years from now. This guarantees me that it appears on top of the
  list;
- Save each of these posts in a branch of itself, like
  `stockpile/item-d-x` where the `d` is a date and `x` is a
  progressive integer (it will usually be `0`);
- When I need it, get an element from this *stockpile*, change the date
  and publish it.

To help me with this process, script [stockpile.sh][] helps a lot:

- The `add` sub-command works much like [publish.sh][], only saving the
  new post(s) inside its(/theirs) own branch;
- The `get` sub-command takes an item and puts it into the current
  branch (usually `devel`)
- For good measure, the `list` sub-command does what you think.

I somehow feel that this blog is growing and growing, but until it's
still capable of letting me do stuff from the web should I need it...
it's fine.

[Git]: https://www.git-scm.com/
[stockpile.sh]: https://github.com/polettix/ETOOBUSY/blob/master/stockpile.sh
[publish.sh]: https://github.com/polettix/ETOOBUSY/blob/master/publish.sh
