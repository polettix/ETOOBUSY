---
title: 'Term::StatusBar'
type: post
tags: [ perl ]
comment: true
date: 2021-05-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I took a look at [Term::StatusBar][].

Miguel Prz keeps a series of [metacpan][] weekly reports in the
interesting blog [niceperl][]. It's interesting to take a look to what
moves in the [CPAN][metacpan] world from time to time.

I was intrigued by [Term::StatusBar][]:

> [Term::StatusBar][] provides an easy way to create a terminal status
> bar, much like those found in a graphical environment.

This is a first try:

<script id="asciicast-EiUHKurmKytVMpoYX7LsheJpA" src="https://asciinema.org/a/EiUHKurmKytVMpoYX7LsheJpA.js" async></script>

The colors are nice and the aspect is tweakable, only I really don't
like/understand why the default placement is not... just on the line
where the cursor happens to be in the very first place.

The default of jumping to the top of the terminal only makes sense if
the screen is cleared before, and jumping to the bottom - while visually
better - seem to *waste* some space. Personal taste, anyway.

I think there might also be a bug when using the *non-linear* update
method, which can be handy when the different *items* might come in
chunks (like e.g. reading a file where we know the total size, but each
line might have a different number of characters).

While the thing seems to work *by itself*, it also seems that it has a
bad interaction with the *linear* way of doing stuff:

<script id="asciicast-P12ot7ZnooR8G6WjRGyfKpKZ3" src="https://asciinema.org/a/P12ot7ZnooR8G6WjRGyfKpKZ3.js" async></script>

I think it might be that the `reset` method forgets to remove some
previous state and this has... *consequences*. I opened a [ticket][] for
this - although I wonder if it's just *out of time* 😅

If you'd like to give the examples a try, you can find them in [this
gist][].

All in all it seems nice but I don't think that I will use this module.

Stay safe!

[Term::StatusBar]: https://metacpan.org/pod/Term::StatusBar
[niceperl]: https://niceperl.blogspot.com/
[metacpan]: https://metacpan.org/
[ticket]: https://rt.cpan.org/Ticket/Display.html?id=136456
[this gist]: https://gist.github.com/polettix/4a62bc344638a88ee64d5193029cf397
