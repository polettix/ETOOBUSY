---
title: Post status on Mastodon
type: post
tags: [ mastodon, octodon, perl, coding ]
comment: true
date: 2020-05-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where we see that it is *extremely* simple to post a status on a
> social based on [Mastodon][].

Here, of course, we're using [Perl][]:

<script src='https://gitlab.com/polettix/notechs/snippets/1980373.js'></script>

[Local version here][].

It's a kind of exercise in minimalism, most probably you should try and
use [Mojo::UserAgent][] instead but it's working.

It should work on any [Mastodon][] instance, I tried it with
[Octodon][], which is where I hang out as [polettix][].

To use the script, you need to *at least* set the OAuth 2 token, that
you can get from the (web) application. You can also do it from the
command line: [Obtaining client app access][]. Just set it in the
environment:

```shell
# this is optional and can be ignored (it's commented for a reason)
#MASTODON_URI='...'

# this you MUST populate
MASTODON_TOKEN='...'

perl postatus 'Hello... myself, this is private by default'
```

That's it for today!


[Mastodon]: https://mastodon.social/
[Perl]: https://www.perl.org/
[Local version here]: {{ '/assets/code/postatus' | prepend: site.baseurl }}
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Octodon]: https://octodon.social/
[polettix]: https://octodon.social/@polettix
[Obtaining client app access]: https://docs.joinmastodon.org/client/token/
