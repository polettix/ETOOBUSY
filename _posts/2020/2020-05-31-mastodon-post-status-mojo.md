---
title: 'Post status on Mastodon - with Mojo::UserAgent'
type: post
tags: [ mastodon, octodon, perl, coding, mojolicious ]
comment: true
date: 2020-05-31 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's bite the bullet and use [Mojo::UserAgent][] to post a status on
> [Mastodon][].

If you're wondering what on earth I'm talking about, it's time to take a
look at [Post status on Mastodon][] - which is yesterday's entry, to be
fair. There... we hinted that pretty much the same thing might have been
done with [Mojo::UserAgent][].

# Why on earth?

Well... first, *because we can*.

Then because [Mojo::UserAgent][] comes with a lot of batteries included,
on of which is handling JSON in friendly terms. Which comes really
*handy* if you actually want to *do something* with the response from
the server.

Another reason will be evident in some future post, so for the time
being we'll just take the pleasure of *doing it because we can*.

# So, let's do it!

Here we are, a drop-in replacement for the last post's function:

<script src='https://gitlab.com/polettix/notechs/snippets/1981911.js'></script>

[Local version here][].

You will surely notice a lot of code coming from the previos
implementation. On the other hand, while we were dumping the whole
structure we got back - headers, body, etc. - now we can concentrate on
the payload alone and just ask the library to read it as JSON-encoded
data.

Which, I think we can agree, can be a lot useful these days that there's
so much JSON flying around.


[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Mastodon]: https://mastodon.social/
[Post status on Mastodon]: {{ '/2020/05/30/mastodon-post-status' | prepend: site.baseurl }}
[Local version here]: {{ '/assets/code/postatus2' | prepend: site.baseurl }}
