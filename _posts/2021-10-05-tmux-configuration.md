---
title: Configuration for tmux
type: post
tags: [ tmux ]
comment: true
date: 2021-10-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> My configuration for [tmux][].

This is my configuration for [tmux][] - with parts copied from here and there.

<script src="https://gitlab.com/polettix/notechs/-/snippets/2184572.js"></script>

[Local version here][].

A few remarks:

- `CTRL-B` is the prefix. That's it, different from screen, lets me go
  to the beginning of a command line but makes it harder to jump back by
  pages in the editor or the pager.
- The status line is basic but useful, with colors and the clock.
- `CTRL-B CTRL-B` toggles with the last window, streamlining jumping
  between two windows. It's the single thing that I wish were a default
  instead of needing explicit configuration.
- `CTRL-B |` divides into panes vertically, `CTRL-B -` divides into
  panes horizontally. It just makes so much sense!

Everything is *totally* not something I came up with on my own, but
unfortunately I don't know whom I should attribute the different bits.
Shame on me but... at least I'm not taking the merit!

It's easy to install it: put the file in a `.tmux.conf` file inside the
home directory, and nothing more is needed.

Stay safe everyone!

[tmux]: https://github.com/tmux/tmux/wiki
[Local version here]: {{ '/assets/other/tmux.conf' | prepend: site.baseurl }}
