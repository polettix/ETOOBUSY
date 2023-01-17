---
title: Repository icons attribution
type: post
tags: [ web ]
comment: true
date: 2023-01-17 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm still trying to understand how to do it.

Both [Codeberg][] and [GitLab][] allow using a custom icon (or *avatar*)
for each respository, which allows things to be fancier.

I'm not too much of an artist myself, which led to some embarrassing
icons/*avatars* like in [quenv][], [notechs][], and [dokyll][] (arguably
the worst of the lot).

This often means that I go looking for a different, *more pleasant* icon
to use for new projects, and this further leads me to the *attribution
problem*.

What's this? Easy said: finding a way to *properly* give attribution
about the icon.

The basic way, which I guess that people who care adopt, is to
acknowledge it somewhere in the repo's `README.md` file. Well, I don't
like this approach *at all*, because the `README.md` is about the
project itself, which might or might not live in [Codeberg][],
[GitLab][] or any other place allowing for an avatar.

The avatar is something that has to do with the hosting of the project
in the specific site. I might even want to duplicate the project
somewhere else and use separate avatars on separate sites. (I'm not
advocating that this makes sense, though).

So, I think that the sites should have a specific place for setting this
attribution, possibly close to where the avatar itself can be set, and
allow displaying the attribution so that it can be properly consumed by
people.

This is the gist behind [this issue on Codeberg][issue], although I
don't feel too positive about it by the tone of the only answer I got so
far. I mean, I *literally* copied the benefits I'm anticipating from the
original issue text, so either these benefits were drown in the rest of
the text I wrote in the issue, or they are not perceived as real
benefits, or something else that I'm missing.

This is slightly frustrating, but  puts my feet on the ground by
reminding me that almost nothing that is *evident* to me is *actually
evident* at all.

Cheers!

[Codeberg]: https://codeberg.org/
[GitLab]: https://gitlab.com/
[quenv]: https://gitlab.com/polettix/quenv
[dokyll]: https://gitlab.com/polettix/dokyll
[notechs]: https://gitlab.com/polettix/notechs
[issue]: https://codeberg.org/forgejo/forgejo/issues/251
