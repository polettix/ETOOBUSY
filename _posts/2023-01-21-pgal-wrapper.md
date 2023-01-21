---
title: A wrapper/driver shell program for pgal
type: post
tags: [ shell, perl, coding, gallery ]
comment: true
date: 2023-01-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Things are usually a bit more complicated.

After finding the [Dungeon Crawl 32x32 tiles][] (while looking for [Repo
icons sources][]), it was pretty clear that finding any *specific*
icon's file from the [summary image][] would not be easy:

![Summary of icons for Dungeon Crawl 32x32 tiles](https://opengameart.org/sites/default/files/DungeonCrawl_ProjectUtumnoTileset_0.png)

Hence I decided to use [pgal][] and generate a (recursive) album out of
all the icons. Fact is, the *example* invocation in the original version
of that blog post does not work:

```shell
# THIS DOES NOT WORK!
PGAL='docker.pkg.github.com/polettix/pgal/pgal:latest'
ROOT='/path/to/album/root'
docker run --rm -v "$ROOT:/mnt" "$PGAL" -c -r
```

It turns out that the driver shell function hinted in the [repository
for pgal][] is better:

```shell
pgal() { docker -itv "$PWD:/mnt" --rm pgal "$@" ;}
```

Time and again I'm reminded to *test* everything. Anyway.

I wanted to provide a more  *Do What I Mean* way of invoking the
program, in the sense that I would like to run it in different
directories than `$PWD`. This is a bit tricky to do with Docker in the
way, because we have to make sure that the target directory is *mounted*
in the container's filesystem.

To make a long story short, here's what I came up with:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2487242.js"></script>

[Local version here][].

The *last* argument in the list is checked to see if it's a candidate
option or not. I know this is sub-optimal because it does not take care
about '--' or about the possibility that the last argument is a *value*
for a previous option, but whatever - it works for this particular
program... *in most cases* 🙄

Cheers!

[Perl]: https://www.perl.org/
[Dungeon Crawl 32x32 tiles]: https://opengameart.org/content/dungeon-crawl-32x32-tiles
[Repo icons sources]: {{ '/2023/01/18/repo-icons-sources/' | prepend: site.baseurl }}
[summary image]: https://opengameart.org/sites/default/files/DungeonCrawl_ProjectUtumnoTileset_0.png
[pgal]: {{ '/2020/06/09/pgal/' | prepend: site.baseurl }}
[repository for pgal]: https://github.com/polettix/pgal
[Local version here]: {{ '/assets/code/pgal' | prepend: site.baseurl }}
