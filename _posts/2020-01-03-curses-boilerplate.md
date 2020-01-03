---
title: Curses boilerplate starter
type: post
tags: [ perl, curses ]
comment: true
date: 2020-01-03 08:40:19
---

**TL;DR**

> Playing with [Curses][] in [Perl][] is funny

From time to time I re-discover the [Curses][] library, mostly because I
always dreamt of doing a decent game of any kind. It's now time to blog an
example boilerplate starter so that I don't have to figure it out time and
again.

## Installing

I will now play the jolly card and let me be very, very lazy:

```
# save as "cpanfile"
requires 'Curses';

# ensure you have a system-wide ncurses library with dev stuff and
# run either of these:
# 
#    carton
#    cpanm -l local --installdeps .
```

Ok, ok... here's a few links to the tools used above (again, you only need
to choose one):

- [Carton][]
- [Cpanminus][]


## Boilerplate

This can be a handy starter:

<script src="https://gitlab.com/polettix/notechs/snippets/1926735.js"></script>

> If not shown for any reason, find the above snippet [locally][boilerplate].


## I guess this is it!

Hopefully, more on [Curses][] will follow, but until then... happy hacking!


[Carton]: https://metacpan.org/pod/Carton
[cpanm]: https://metacpan.org/pod/App-cpanminus
[boilerplate]: {{ '/assets/code/curses-program-starter.pl' | prepend: site.baseurl | prepend: site.url }}
[Curses]: https://metacpan.org/pod/Curses
[Perl]: https://www.perl.org/
