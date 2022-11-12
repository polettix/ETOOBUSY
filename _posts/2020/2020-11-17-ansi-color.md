---
title: ANSI Color
type: post
tags: [ shell, color ]
comment: true
date: 2020-11-17 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A nice shell script to showcase coloring the output.

The [Inconsolation][] series of posts is excellent for wasting a *lot* of
your time, if you want to know. But who knows? One of these gems might come
handy one day or another.

I can't remember how to find the exact post there, but I found an
interesting script to colorize the output in the shell... find it here:
[ANSI colorschemes scripts][].

The script there suffers from pasting the contents inside a web page, in
that the value of variable `esc` inside function `initializeANSI` is lost. I
took the liberty of putting an alternative way to populate it with the right
value, in a way that's POSIX compliant and also easily copy-pasteable. You
can find an easily transferable copy here (yes, copy and paste works too
with this script):

<script src="https://gitlab.com/polettix/notechs/-/snippets/2039857.js"></script>

[Local version here][].

The trick is all in line 14: thanks to the excellent tips in [Rich’s sh
(POSIX shell) tricks][rich] (covered in the [same-named post here][post]),
we are able to avoid putting the *binary* value for the escape character and
populate environment variable `env` with the right value by only using
printable characters. Yay!

If you trust yours truly (and [GitLab][], for what I know) you can just run
it from the command line:

```shell
u='https://gitlab.com/polettix/notechs/-/snippets/2039857/raw/master/ansi-color.sh'
curl -L "$u" | sh
```

Demo time:

<script id="asciicast-373037" src="https://asciinema.org/a/373037.js" async></script>

I think it works even better in my terminal:

![ansi-color output]({{ '/assets/images/ansi-color.png' | prepend: site.baseurl }})

Life needs some color... and remember to stay safe please!

[ANSI colorschemes scripts]: https://crunchbang.org/forums/viewtopic.php?id=13645
[Inconsolation]: https://inconsolation.wordpress.com/
[Local version here]: {{ '/assets/code/ansi-color.sh' | prepend: site.baseurl }}
[rich]: http://www.etalabs.net/sh_tricks.html
[post]: {{ '/2020/03/21/rich-s-posix-shell-hints/' | prepend: site.baseurl }}
[GitLab]: https://gitlab.com/
