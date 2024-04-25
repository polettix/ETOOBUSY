---
title: serve_this
type: post
tags: [ perl, Mojolicious ]
comment: true
date: 2023-05-31 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I [discovered][] [serve\_this][serve-this].

From time to time it is useful to explore a directory tree through the
browser, e.g. to make it accessible remotely. There are a lot of solutions
do do this around, in a plethora of languages; I recently [discovered][]
[serve\_this][serve-this].

The good thing is that it's based on [Mojolicious][], which is a breeze to
install, as long as the associated plugin for doing the fancy directory
indexing [Mojolicious::Plugin::Directory::Stylish][].

Another [Perl][]-based alternative is [`http_this`][], although these days I
don't usually fiddle with [Plack][], so it's somehow more *distant*. 

Why [Perl][], you might wonder, when there might be better tools to do this?
Well, I'm not really after anything fancy, and I'm pretty *sure* there will
be a [Perl][] wherever I go, or that I can bring it there with little
effort. So it's really a no-brainer for me.

There are some sharp edges that can use some sanding, though. Asking for
non-existent paths throws an exception, and the like; anyway, being some
*quick-and-dirty* tool, I think it's neat.

Cheers!

[Perl]: https://www.perl.org/
[discovered]: https://www.reddit.com/r/perl/comments/13lh3xl/serve_this_a_mojo_based_alternative_to_http_this/
[serve-this]: https://gist.github.com/lbe/1b0de949e14300ffa52bd9f1c6896895
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Mojolicious::Plugin::Directory::Stylish]: https://metacpan.org/pod/Mojolicious::Plugin::Directory::Stylish
[`http_this`]: https://metacpan.org/pod/http_this
[Plack]: https://metacpan.org/pod/Plack
