---
title: Stockpile of posts gets interactive
type: post
tags: [ blog, shell ]
comment: true
date: 2021-02-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Another enhancement to [stockpile.sh][] - interaction!

One additional enhancement recently added to program [stockpile.sh][] is
an *interactive mode*.

Now, when it is run, it will show a list of the available stockpile
items (just like sub-command `list` would do) and a prompt.

Apart from the `add` command, all other ones are available, both in
their extended form as well as a one-letter shortcut.

Well, this is not entirely true, to be honest. While at it, I added a
`head` command to show the *front-matter* of a stockpile item, which is
shortcutted both as `h` and as `s`.

Hence, if you want to `show` the whole item, you need to type `show` in
full. After all, you're asking for more output... so you can as well
provide more input!

A little demo:

<script id="asciicast-389536" src="https://asciinema.org/a/389536.js" async></script>

Stay safe and protect yourself!

[stockpile.sh]: https://github.com/polettix/ETOOBUSY/blob/master/stockpile.sh
[Stockpile of posts gets dates in listing]: {{ '/2021/02/19/stockpile-list-with-dates/' | prepend: site.baseurl }}
