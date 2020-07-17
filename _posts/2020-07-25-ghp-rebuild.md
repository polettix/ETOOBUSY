---
title: Trigger rebuild of blog in GitHub Pages
type: post
tags: [ blog, github ]
comment: true
date: 2020-07-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Triggering the regeneration of the blog in [GitHub Pages][] through
> the API, for when the automatic way fails.

As I elaborated multiple times so far, this blog is hosted in [GitHub
Pages][].

The workflow is usually quite smooth: you push something to the
repository, [GitHub][] notices the change and rebuilds the site. This
allows using e.g. [Jekyll][] to use [Markdown][] instead of plain HTML.

Alas, things can go wrong from time to time, as it happened on July
13th:

![GitHub Incident on 2020-07-13]({{ '/assets/images/gh-incident-20209713.png ' | prepend: site.baseurl }})

Considering that [busypub][] for me attempts publishing at 07:30 AM in
Europe/Rome (i.e. 05:30 AM UTC at this time of the year), it's easy to
see that the blog was totally hit by the incident.

Some [DuckDuckGoing][] around led me to [this answer in
StackOverflow][answer]: use the API! So by all means take a look at the
answer for some instructions, and then you should be able to leverage
the following script:

<script src='https://gitlab.com/polettix/notechs/snippets/1996738.js'></script>

[Semi-local version here][].

The credentials you get are supposed to end up in a file located at
`~/.github/ghp-rebuild`, in the form of `<username>:<token>`, like
`polettix:90238102938deadbeef902320`. Otherwise, set environment
variable `GHP_CREDENTIALS` to a string with the same format.

The repository against which you want to trigger a rebuild must have a
form like `<username>/<reponame>`, like `polettix/ETOOBUSY` for this
very blog. Either set it through environment variable `GHP_FQREPO`
(a.k.a. *Fully Qualified Repo*) or make sure that the `origin` value in
your `_config.yml` file is set to something like
`https://github.com/<username>/<reponame>` (and have [teepee][]
installed!).

Now you're done: if [GitHub Pages][] misses its beat, just call it and
wait for the rebuild to happen!

[GitHub]: https://github.com/
[GitHub Pages]: https://pages.github.com/
[Jekyll]: https://jekyllrb.com/
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[DuckDuckGoing]: https://duckduckgo.com/?t=ffab&q=github+pages+trigger+regeneration&ia=web
[answer]: https://stackoverflow.com/a/54088985/334931
[Semi-local version here]: https://github.com/polettix/ETOOBUSY/blob/master/ghp-rebuild.sh
[teepee]: https://github.polettix.it/teepee/
[busypub]: {{ '/2020/05/29/busypub' | prepend: site.baseurl }}
