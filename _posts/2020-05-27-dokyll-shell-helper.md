---
title: 
type: post
tags: [ ]
comment: true
date: 
mathjax: false
published: true
---

**TL;DR**

> A helper shell script for [dokyll][].

In [Jekyll in Docker][] we took a look at [dokyll][], my little packaging of
[Jekyll][] in a [Docker][] image. It just seemed right to pack the shell
commands in a script:

<script src='https://gitlab.com/polettix/notechs/snippets/1979679.js'></script>

There is little to add, actually. One interesting thing might be that
I'm leveraging a couple of `config.yml` files for the local deployment,
so that I can override a few variables; this is why the environment
variable `multiconfig` is set to the specific value in line 3.

That's all!

[dokyll]: https://gitlab.com/polettix/dokyll
[Jekyll in Docker]: {{ '/2020/03/16/jekyll-in-docker' | prepend: site.baseurl }}
[Jekyll]: https://hub.docker.com/r/jekyll/jekyll
[GitLab]: https://gitlab.com/
