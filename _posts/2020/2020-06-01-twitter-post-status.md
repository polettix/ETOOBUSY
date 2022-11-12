---
title: Post status on Twitter
type: post
tags: [ twitter, perl, coding, mojolicious ]
comment: true
date: 2020-06-01 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Time to look about posting a new status to [Twitter][].

After looking at how to [Post status on Mastodon][] (with the addition
of [Post status on Mastodon - with Mojo::UserAgent][]), it's residually
useful to look at doing the same thing on [Twitter][].

I say *residually* because I'd really like [Mastodon][] to catch up
more. The idea of *not* needed to rely upon a company that makes
business on our data is very attractive to me. Alas, they were the first
and it's so easy to do.

Without further ado, let's meet the code:

<script src='https://gitlab.com/polettix/notechs/snippets/1981917.js'></script>

[Local version here][].

We meet again our old friend [MojoX::Twitter][], which we already met in
[Getting started with MojoX::Twitter][] (and a couple of follow-ups, to
be fair).

This module leverages the excellent *Mojo* toolkit that is shipped with
[Mojolicious][], which is our reason why we also saw an implementation
of sending a status update to [Mastodon][] using [Mojo::UserAgent][] -
if it's there, why not use it?!?


[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Mastodon]: https://mastodon.social/
[Post status on Mastodon]: {{ '/2020/05/30/mastodon-post-status' | prepend: site.baseurl }}
[Post status on Mastodon - with Mojo::UserAgent]: {{ '/2020/05/31/mastodon-post-status-mojo' | prepend: site.baseurl }}
[Local version here]: {{ '/assets/code/postatus2' | prepend: site.baseurl }}
[Twitter]: https://twitter.com/
[Local version here]: {{ '/assets/code/postatus3' | prepend: site.baseurl }}
[Getting started with MojoX::Twitter]: {{ '/2020/01/16/mojox-twitter' | prepend: site.baseurl | prepend: site.url }}
[MojoX::Twitter]: https://metacpan.org/pod/MojoX::Twitter
[Mojolicious]: https://metacpan.org/pod/Mojolicious
