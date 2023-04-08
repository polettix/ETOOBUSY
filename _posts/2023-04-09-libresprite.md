---
title: LibreSprite
type: post
tags: [ graphics, pixel ]
comment: true
date: 2023-04-09 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [LibreSprite][] is useful for drawing pixel art, like icons/avatars/etc.

From the website:

> LibreSprite is a free and open source program for creating and animating
> your sprites.

So well, it's a bit *more* than just drawing pixel art, because it supports
animation easily as well, but we still have to start drawing the first
screen, right?

As a total novice in the field, and an easily distracted one, I found out
about [LibreSprite][] by means of this video: [The Best FREE Software for
Game Development! (In my Opinion)][video].

I installed it in Windows in a pretty big resolution screen, and I
immediately stumbled upon a bump because the program looked *tiny*.

I thought it had to do with some scaling in high-DPI screens and tried to
move a couple of knobs in the windows preferences for the executable, but to
no avail. Then I tried to search the internet - guess what? To no avail.

Then I tried to see if it has something *inside* the program to help us, and
*presto!* It has a useful `Edit`/`Preferences...`/`General` section with
**two** ways to tweak the appearance like this:

![Scaling in LibreSprite has two separate magnification options]({{ '/assets/images/libresprite-scaling.png' | prepend: site.baseurl }})

My next hurdle was figuring out how to *zoom out*. It turned out to be quite
embarassing, to be honest: when the magnifier tool is selected (with `Z`),
the left button zooms in, while the right button zooms out. To be honest,
I'd much more prefer to have keyboard shortcuts for these two operations,
like we have e.g. in [GIMP][]. Maybe it's just something I still have to
find anyway.

I suffered a bit the checked background, so I wanted to disable it. It seems
that there's no option to *directly* do this; I resorted to setting the same
color for both square positions and call it a day.

The animation world is new to me so I might suffer from inexperience, but
I would have liked to see the possibility to move frames around in a few
more places (e.g. in the contextual menus). I was about to abandon the
moving of a frame, when my mouse went *exactly* over the few pixels that
allow to do this movement with drag and drop. You first have to select the
frame, then place the mouse in the line between the frame number and
whatever it has under it, like in the screenshot below:

![The spot for moving a frame]({{ '/assets/images/libresprite-move-frame.png' | prepend: site.baseurl }})

There are a couple of glitches here and there, but nothing that prevented me
from doing an awful yet satisfying little animated GIF ![Terrible animation,
yet it's mine!]({{ '/assets/images/libresprite-test.gif' | prepend:
site.baseurl }})

I was a bit dubious (/curious) about the lack for support of animated PNG
(APNG) format though, nor I seem to find out anything about it around. It
seems that the latest version of [ImageMagick][] can do the conversion,
although the resulting image ![Terrible animation as an APNG file]({{
'/assets/images/libresprite-test.apng' | prepend: site.baseurl }}) is a
whopping 10x+ with respect to the starting GIF file, which does not seem to
be an improvement.

I'm expecially confused by the fact that [ImageMagick][] actually required
me to install [ffmpeg][] to do the conversion. I figured that I could
just use it directly:

```
ffmpeg -i input.gif -f apng -plays 0 output.apng
```

It turns out that *it works* ![Terrible animation as an APNG file, from
ffmpeg]({{ '/assets/images/lstest.apng' | prepend: site.baseurl }}) and the
image size is *smaller* than the GIF.

Well, this was my adventure in doing some pixel art... or at least
getting ready to do it. Stay safe!

<span title="This is the 1024th consecutive day of posting, which is 2^10.
Now it's really time to move on, write less obsessively and start exercising
again!">![Note]({{ '/assets/images/note.apng' | prepend: site.baseurl
}})</span>

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[LibreSprite]: https://libresprite.github.io/
[video]: https://www.youtube.com/watch?v=SBmeEQOh20A
[GIMP]: https://www.gimp.org/
[ffmpeg]: https://ffmpeg.org/
[ImageMagick]: https://imagemagick.org/index.php

