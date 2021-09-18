---
title: 'Wider List::Util'
type: post
tags: [ perl ]
comment: true
date: 2021-09-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I discovered that [List::Util][] became wider and I think it's a good
> thing.

I remember that, some time ago (*vague*), [List::Util][] in [Perl][] was
a useful although a bit tight collection of functions.

I also remember that somebody wanted more utilities to end up there,
others were against this and eventually frustration led to
[List::MoreUtils][], sadly not in CORE.

I can only imagine how much self-control (or smoothing through time)
went into the following terse description that we find today:

> **List::MoreUtils** provides some trivial but commonly needed
> functionality on lists which is not going to go into [List::Util][].

Anyway, fast-forward to today, I notice that *both* modules kind of
exploded! This is good IMHO.

I'm particularly happy about a few additions in the CORE module, of
course, because it's *CORE* and we can count on it everywhere we find
[Perl][]. Well, unless your Linux distribution decides to redefine what
CORE means... This is sadly another story.

I like the appearance of [sample][], to get some distinct items out of a
list:

```perl
use List::Util 'sample';
my $password = join '-', sample 4, @dictionary;
```

([You know about passwords, right?][xkcd936])

I'm a bit doubtful about [head][] and [tail][] though, to be honest, for
a couple of reasons:

- it seems to me that it's *extremely* easy to just use [splice][] for
  this;
- I'm not sure to follow the logic by which both functions accept a
  negative value to go "from the other end".

I guess that the answer is probably *enhance readability* for the first
doubt (and ease of use, think [shift][] and [pop][] for example), as
well as consistency for the second. Still...

Well, nitpicking apart I'm happy that there are more cards up a Perler's
sleeve! Thanks [Perl][] folks and, in this case, even more thanks to
[Paul Evans][] I guess!

Stay safe folks, please!



[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[List::Util]: https://metacpan.org/pod/List::Util
[List::MoreUtils]: https://metacpan.org/pod/List::MoreUtils
[sample]: https://metacpan.org/pod/List::Util#sample
[xkcd936]: https://xkcd.com/936
[Paul Evans]: https://metacpan.org/author/PEVANS
[head]: https://metacpan.org/pod/List::Util#head
[tail]: https://metacpan.org/pod/List::Util#tail
[splice]: http://perldoc.co.uk/functions/splice.html
[shift]: http://perldoc.co.uk/functions/shift.html
[pop]: http://perldoc.co.uk/functions/pop.html
